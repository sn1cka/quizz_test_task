import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:quizz_test_task/src/core/constant/config.dart';
import 'package:quizz_test_task/src/core/database/database.dart';
import 'package:quizz_test_task/src/core/utils/error_tracking_manager.dart';
import 'package:quizz_test_task/src/core/utils/refined_logger.dart';
import 'package:quizz_test_task/src/feature/game/bloc/game_bloc.dart';
import 'package:quizz_test_task/src/feature/game_manager/bloc/game_manager_bloc.dart';
import 'package:quizz_test_task/src/feature/initialization/model/dependencies_container.dart';
import 'package:quizz_test_task/src/feature/quiz_config/bloc/quiz_config_bloc.dart';
import 'package:quizz_test_task/src/feature/quiz_config/data/quiz_config_datasource.dart';
import 'package:quizz_test_task/src/feature/quiz_config/data/quiz_config_repository.dart';
import 'package:quizz_test_task/src/feature/trivia/data/trivia_datasource.dart';
import 'package:quizz_test_task/src/feature/trivia/data/trivia_repository.dart';
import 'package:quizz_test_task/src/feature/trivia/data/trivia_rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template composition_root}
/// A place where all dependencies are initialized.
/// {@endtemplate}
///
/// {@template composition_process}
/// Composition of dependencies is a process of creating and configuring
/// instances of classes that are required for the application to work.
///
/// It is a good practice to keep all dependencies in one place to make it
/// easier to manage them and to ensure that they are initialized only once.
/// {@endtemplate}
final class CompositionRoot {
  /// {@macro composition_root}
  const CompositionRoot(this.config, this.logger);

  /// Application configuration
  final Config config;

  /// Logger used to log information during composition process.
  final RefinedLogger logger;

  /// Composes dependencies and returns result of composition.
  Future<CompositionResult> compose() async {
    final stopwatch = clock.stopwatch()..start();

    logger.info('Initializing dependencies...');
    // initialize dependencies
    final dependencies = await DependenciesFactory(config, logger).create();
    logger.info('Dependencies initialized');

    stopwatch.stop();
    final result = CompositionResult(
      dependencies: dependencies,
      msSpent: stopwatch.elapsedMilliseconds,
    );

    return result;
  }
}

/// {@template factory}
/// Factory that creates an instance of [T].
/// {@endtemplate}
abstract class Factory<T> {
  /// Creates an instance of [T].
  T create();
}

/// {@template async_factory}
/// Factory that creates an instance of [T] asynchronously.
/// {@endtemplate}
abstract class AsyncFactory<T> {
  /// Creates an instance of [T].
  Future<T> create();
}

/// {@template dependencies_factory}
/// Factory that creates an instance of [DependenciesContainer].
/// {@endtemplate}
class DependenciesFactory extends AsyncFactory<DependenciesContainer> {
  /// {@macro dependencies_factory}
  DependenciesFactory(this.config, this.logger);

  /// Application configuration
  final Config config;

  /// Logger used to log information during composition process.
  final RefinedLogger logger;

  @override
  Future<DependenciesContainer> create() async {
    final sharedPreferences = SharedPreferencesAsync();

    final gameBloc = GameBlocFactory().create();
    final errorTrackingManager = await ErrorTrackingManagerFactory(config, logger).create();
    final quizConfigBloc = await QuizConfigBlocFactory(sharedPreferences).create();
    final gameManagerBloc = await GameManagerBlocFactory().create();

    return DependenciesContainer(
      quizConfigBloc: quizConfigBloc,
      errorTrackingManager: errorTrackingManager,
      gameManagerBloc: gameManagerBloc,
      gameBloc: gameBloc,
    );
  }
}

/// {@template error_tracking_manager_factory}
/// Factory that creates an instance of [ErrorTrackingManager].
/// {@endtemplate}
class ErrorTrackingManagerFactory extends AsyncFactory<ErrorTrackingManager> {
  /// {@macro error_tracking_manager_factory}
  ErrorTrackingManagerFactory(this.config, this.logger);

  /// Application configuration
  final Config config;

  /// Logger used to log information during composition process.
  final RefinedLogger logger;

  @override
  Future<ErrorTrackingManager> create() async {
    final errorTrackingManager = SentryTrackingManager(
      logger,
      sentryDsn: config.sentryDsn,
      environment: config.environment.value,
    );

    if (config.enableSentry && foundation.kReleaseMode) {
      await errorTrackingManager.enableReporting();
    }

    return errorTrackingManager;
  }
}

class QuizConfigBlocFactory extends AsyncFactory<QuizConfigBloc> {
  /// {@macro quiz_bloc_factory}
  QuizConfigBlocFactory(this.sharedPreferences);

  /// Shared preferences instance
  final SharedPreferencesAsync sharedPreferences;

  @override
  Future<QuizConfigBloc> create() async {
    final quizConfigRepository = QuizConfigRepositoryImpl(
      datasource: QuizConfigDatasourceImpl(sharedPreferences: sharedPreferences),
    );

    final quizConfig = await quizConfigRepository.getConfig();
    final initialState = QuizConfigState.idle(config: quizConfig);

    return QuizConfigBloc(
      quizConfigRepository: quizConfigRepository,
      initialState: initialState,
    );
  }
}

class GameBlocFactory extends Factory<GameBloc> {
  @override
  GameBloc create() => GameBloc(const GameState(
        questions: [],
        currentQuestionIndex: 0,
        selectedAnswer: null,
        correctCount: 0,
        currentVariants: [],
        isGameEnded: false,
      ),);
}

class GameManagerBlocFactory extends AsyncFactory<GameManagerBloc> {
  @override
  Future<GameManagerBloc> create() async {
    final repository = TriviaRepositoryImpl(
      remoteDataSource: TriviaRemoteDataSource(client: TriviaRestClient(Dio())),
      persistentDatasource:  TriviaPersistentDatasource(appDataBase: AppDatabase.defaults()),
    );

    final categoriesFuture = repository.getCategories();

    late final GameManagerState initialState;

    try {
      final categories = await categoriesFuture;
      initialState = GameManagerState.idle(categories: categories);
    } catch (e, stack) {
      logger.error('Getting categories was issued by: $e', stackTrace: stack);
      initialState = GameManagerState.error(categories: [], error: e);
    }

    return GameManagerBloc(repository: repository, initialState: initialState);
  }
}

/// {@template composition_result}
/// Result of composition
///
/// {@macro composition_process}
/// {@endtemplate}
final class CompositionResult {
  /// {@macro composition_result}
  const CompositionResult({
    required this.dependencies,
    required this.msSpent,
  });

  /// The dependencies container
  final DependenciesContainer dependencies;

  /// The number of milliseconds spent
  final int msSpent;

  @override
  String toString() => '$CompositionResult('
      'dependencies: $dependencies, '
      'msSpent: $msSpent'
      ')';
}
