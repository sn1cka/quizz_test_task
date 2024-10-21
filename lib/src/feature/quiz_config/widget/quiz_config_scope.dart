import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizz_test_task/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:quizz_test_task/src/feature/quiz_config/bloc/quiz_config_bloc.dart';
import 'package:quizz_test_task/src/feature/quiz_config/model/quiz_config.dart';

/// {@template quiz_config_scope}
/// QuizConfigScope widget.
/// {@endtemplate}
class QuizConfigScope extends StatefulWidget {
  /// {@macro quiz_config_scope}
  const QuizConfigScope({required this.child, super.key});

  /// The child widget.
  final Widget child;

  /// Get the [QuizConfigBloc] instance.
  static QuizConfigBloc of(BuildContext context, {bool listen = true}) {
    final quizConfigScope = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedQuizConfig>()
        : context.getInheritedWidgetOfExactType<_InheritedQuizConfig>();
    return quizConfigScope!.state._quizConfigBloc;
  }

  /// Get the [QuizConfig] instance.
  static QuizConfig configOf(BuildContext context, {bool listen = true}) {
    final quizConfigScope = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedQuizConfig>()
        : context.getInheritedWidgetOfExactType<_InheritedQuizConfig>();
    return quizConfigScope!.quizConfig ?? const QuizConfig(questionAmount: 10);
  }

  @override
  State<QuizConfigScope> createState() => _QuizConfigScopeState();
}

/// State for widget QuizConfigScope.
class _QuizConfigScopeState extends State<QuizConfigScope> {
  late final QuizConfigBloc _quizConfigBloc;

  @override
  void initState() {
    super.initState();
    _quizConfigBloc = DependenciesScope.of(context).quizConfigBloc;
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<QuizConfigBloc, QuizConfigState>(
    bloc: _quizConfigBloc,
    builder: (context, state) => _InheritedQuizConfig(
      quizConfig: state.config,
      state: this,
      child: widget.child,
    ),
  );
}

/// {@template inherited_quiz_config}
/// _InheritedQuizConfig widget.
/// {@endtemplate}
class _InheritedQuizConfig extends InheritedWidget {
  /// {@macro inherited_quiz_config}
  const _InheritedQuizConfig({
    required super.child,
    required this.state,
    required this.quizConfig,
    super.key, // ignore: unused_element
  });

  /// _QuizConfigScopeState instance.
  final _QuizConfigScopeState state;
  final QuizConfig? quizConfig;

  @override
  bool updateShouldNotify(covariant _InheritedQuizConfig oldWidget) => quizConfig != oldWidget.quizConfig;
}
