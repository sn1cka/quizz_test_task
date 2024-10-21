import 'package:quizz_test_task/src/core/utils/error_tracking_manager.dart';
import 'package:quizz_test_task/src/feature/game/bloc/game_bloc.dart';
import 'package:quizz_test_task/src/feature/game_manager/bloc/game_manager_bloc.dart';
import 'package:quizz_test_task/src/feature/initialization/logic/composition_root.dart';
import 'package:quizz_test_task/src/feature/quiz_config/bloc/quiz_config_bloc.dart';

/// {@template dependencies_container}
/// Composed dependencies from the [CompositionRoot].
///
/// This class contains all the dependencies that are required for the application
/// to work.
///
/// {@macro composition_process}
/// {@endtemplate}
base class DependenciesContainer {
  /// {@macro dependencies_container}
  const DependenciesContainer({
    required this.quizConfigBloc,
    required this.errorTrackingManager,
    required this.gameManagerBloc,
    required this.gameBloc,
  });

  /// [QuizConfigBloc] instance, used to manage quiz game configuration
  final QuizConfigBloc quizConfigBloc;

  /// [ErrorTrackingManager] instance, used to report errors.
  final ErrorTrackingManager errorTrackingManager;

  /// [GameBloc] instance, used to manage game.
  final GameManagerBloc gameManagerBloc;

  final GameBloc gameBloc;
}

/// {@template testing_dependencies_container}
/// A special version of [DependenciesContainer] that is used in tests.
///
/// In order to use [DependenciesContainer] in tests, it is needed to
/// extend this class and provide the dependencies that are needed for the test.
/// {@endtemplate}
base class TestDependenciesContainer implements DependenciesContainer {
  /// {@macro testing_dependencies_container}
  const TestDependenciesContainer();

  @override
  Object noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'The test tries to access ${invocation.memberName} dependency, but '
      'it was not provided. Please provide the dependency in the test. '
      'You can do it by extending this class and providing the dependency.',
    );
  }
}
