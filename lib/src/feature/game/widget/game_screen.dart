import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizz_test_task/src/feature/game/bloc/game_bloc.dart';
import 'package:quizz_test_task/src/feature/game_manager/bloc/game_manager_bloc.dart';
import 'package:quizz_test_task/src/feature/quiz_config/widget/quiz_config_scope.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

/// {@template home_screen}
/// HomeScreen is a simple screen that displays a grid of items.
/// {@endtemplate}
class GameScreen extends StatefulWidget {
  /// {@macro home_screen}
  const GameScreen({
    required this.category,
    super.key,
  });

  final Category? category;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void _restart(BuildContext context) {
    BlocProvider.of<GameManagerBloc>(context).add(
      GameManagerEvent.getCategoryQuestions(
        category: widget.category,
        config: QuizConfigScope.configOf(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<GameBloc, GameState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: Text('Category: ${widget.category?.name ?? 'Any'}'),
            bottom: PreferredSize(
              preferredSize: const Size(double.maxFinite, 30),
              child: Expanded(
                child: ColoredBox(
                  color: Colors.grey,
                  child: Center(
                    child: Text(
                        'Question:${state.currentQuestionIndex + 1} / ${state.questions.length}\nCorrect: ${state.correctCount}/${state.questions.length}',),
                  ),
                ),
              ),
            ),
          ),
          body: BlocBuilder<GameManagerBloc, GameManagerState>(
            builder: (context, managerState) => AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: managerState.maybeMap(
                loading: (value) => const Center(
                  child: Expanded(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (value) => const Text('Error occured: read on previous page'),
                orElse: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.isGameEnded)
                      _GameOverScreen(
                        correct: state.correctCount,
                        total: state.questions.length,
                        onRestartPressed: () => _restart(context),
                      ),
                    if (state.isPlaying)
                      _PlayingScreen(
                        currentQuestion: state.currentQuestion,
                        selectedAnswer: state.selectedAnswer,
                        isResult: state.isResult,
                        variants: state.currentVariants,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _PlayingScreen extends StatelessWidget {
  const _PlayingScreen({
    required this.currentQuestion,
    required this.variants,
    required this.isResult,
    required this.selectedAnswer,
  });

  final Question currentQuestion;
  final List<String> variants;
  final bool isResult;
  final String? selectedAnswer;

  void _selectAnswer(BuildContext context, String answer) {
    BlocProvider.of<GameBloc>(context).add(GameEvent.selectAnswer(answer: answer));
  }

  void _moveToNextQuestion(BuildContext context) {
    BlocProvider.of<GameBloc>(context).add(const GameEvent.moveToNextQuestion());
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'Question category:\n${currentQuestion.category}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(currentQuestion.question, style: const TextStyle(fontSize: 30), textAlign: TextAlign.center),
          ),
          SizedBox(
            height: 200,
            child: GridView.builder(
              itemCount: variants.length,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 60,
                mainAxisSpacing: 40,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final buttonVariant = variants[index];
                final isCorrect = buttonVariant == currentQuestion.correctAnswer;
                final isSelected = buttonVariant == selectedAnswer;

                final color = !isResult
                    ? Colors.grey
                    : isCorrect
                        ? Colors.green
                        : isSelected
                            ? Colors.red
                            : Colors.grey;

                return MaterialButton(
                  color: color,
                  onPressed:
                      isResult ? () => _moveToNextQuestion(context) : () => _selectAnswer(context, buttonVariant),
                  child: Text(
                    variants[index],
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      );
}

class _GameOverScreen extends StatelessWidget {
  const _GameOverScreen({
    required this.correct,
    required this.total,
    required this.onRestartPressed,
  });

  final int correct;
  final int total;
  final VoidCallback onRestartPressed;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            'You scored: $correct of $total',
            style: const TextStyle(fontSize: 40),
          ),
          const Text(
            'Want to continue this category?',
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onRestartPressed,
                  child: const Text('Yes', style: TextStyle(fontSize: 25)),
                ),
              ),
              Expanded(
                child: TextButton(
                  child: const Text('No', style: TextStyle(fontSize: 25)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      );
}
