import 'package:flutter/material.dart';
import 'package:quizz_test_task/src/feature/quiz_config/bloc/quiz_config_bloc.dart';
import 'package:quizz_test_task/src/feature/quiz_config/model/quiz_config.dart';
import 'package:quizz_test_task/src/feature/quiz_config/widget/quiz_config_scope.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

class QuizConfigScreen extends StatefulWidget {
  const QuizConfigScreen({super.key});

  @override
  State<QuizConfigScreen> createState() => _QuizConfigScreenState();
}

class _QuizConfigScreenState extends State<QuizConfigScreen> {
  final _difficulties = [...Difficulty.values, null];

  final _availableAmounts = [10, 15, 20];

  final _quiestionTypes = [...QuestionType.values, null];

  late QuizConfig config;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    config = QuizConfigScope.configOf(context, listen: false);
  }

  void _configure(BuildContext context, QuizConfig config) {
    QuizConfigScope.of(context).add(QuizConfigEvent.updateConfig(config: config));
  }

  void _removeConfig(BuildContext context) {
    QuizConfigScope.of(context).add(const QuizConfigEvent.removeConfig());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Quiz configuration'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MaterialButton(
          color: Colors.red,
          onPressed: () {
            _removeConfig(
              context,
            );
          },
          child: const Text('Reset Quiz Configuration'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Question type',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Row(
                children: [
                  ..._difficulties.map(
                    (e) => _ButtonSelection<Difficulty?>(
                      text: e != null ? e.name : 'Any',
                      onSelected: (value) => _configure(context, config.copyWith(difficulty: value)),
                      value: e,
                      selectedValue: config.difficulty,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Question amount',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Row(
                children: [
                  ..._availableAmounts.map(
                    (e) => _ButtonSelection<int>(
                      text: e.toString(),
                      onSelected: (value) => _configure(context, config.copyWith(questionAmount: value)),
                      value: e,
                      selectedValue: config.questionAmount,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Question type',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ..._quiestionTypes.map(
                      (e) => _ButtonSelection<QuestionType?>(
                        text: e != null ? e.name : 'Any',
                        onSelected: (value) => _configure(context, config.copyWith(questionType: value)),
                        value: e,
                        selectedValue: config.questionType,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _ButtonSelection<T> extends StatelessWidget {
  const _ButtonSelection({
    required this.onSelected,
    required this.text,
    required this.value,
    required this.selectedValue,
    super.key,
  });

  final T value;
  final T selectedValue;
  final String text;
  final void Function(T value) onSelected;

  @override
  Widget build(BuildContext context) => Expanded(
        child: MaterialButton(
          color: value == selectedValue ? Colors.green : Colors.white,
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
          onPressed: () => onSelected(value),
        ),
      );
}
