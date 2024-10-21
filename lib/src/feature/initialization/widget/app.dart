import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizz_test_task/src/core/utils/layout/window_size.dart';
import 'package:quizz_test_task/src/feature/initialization/logic/composition_root.dart';
import 'package:quizz_test_task/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:quizz_test_task/src/feature/initialization/widget/material_context.dart';
import 'package:quizz_test_task/src/feature/quiz_config/widget/quiz_config_scope.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template app}
/// [App] is an entry point to the application.
///
/// If a scope doesn't depend on any inherited widget returned by
/// [MaterialApp] or [WidgetsApp], like [Directionality] or [Theme],
/// and it should be available in the whole application, it can be
/// placed here.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({required this.result, super.key});

  /// The result from the [CompositionRoot].
  final CompositionResult result;

  @override
  Widget build(BuildContext context) => DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: DependenciesScope(
          dependencies: result.dependencies,
          child: QuizConfigScope(
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: result.dependencies.gameManagerBloc),
                BlocProvider.value(value: result.dependencies.gameBloc),
              ],
              child: const WindowSizeScope(child: MaterialContext()),
            ),
          ),
        ),
      );
}
