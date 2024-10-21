import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizz_test_task/src/core/utils/extensions/string_extension.dart';
import 'package:quizz_test_task/src/feature/game/bloc/game_bloc.dart';
import 'package:quizz_test_task/src/feature/game/widget/game_screen.dart';
import 'package:quizz_test_task/src/feature/game_manager/bloc/game_manager_bloc.dart';
import 'package:quizz_test_task/src/feature/quiz_config/widget/quiz_config_scope.dart';
import 'package:quizz_test_task/src/feature/quiz_config/widget/quiz_config_screen.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _refreshCategories(BuildContext context) {
    BlocProvider.of<GameManagerBloc>(context).add(const GameManagerEvent.getCategories());
  }

  void _selectCategory(BuildContext context, Category? category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(category: category),
      ),
    );
    final quizConfig = QuizConfigScope.configOf(context);
    _addEventToGameManagerBloc(
      context,
      GameManagerEvent.getCategoryQuestions(
        config: quizConfig,
        category: category,
      ),
    );
  }

  void _startGame(BuildContext context, List<Question> questions) {
    BlocProvider.of<GameBloc>(context).add(GameEvent.startGame(questions: questions));
  }

  void _addEventToGameManagerBloc(BuildContext context, GameManagerEvent event) {
    ScaffoldMessenger.of(context).clearSnackBars();
    BlocProvider.of<GameManagerBloc>(context).add(event);
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<GameManagerBloc, GameManagerState>(
        listener: (context, state) {
          state.mapOrNull(
            categorySelected: (value) {
              _startGame(context, value.questions);
            },
            error: (value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  children: [
                    Text('There is an error occured: ${value.error.toString().limit(100)},'),
                    if (value.event != null)
                      TextButton(
                        onPressed: () => _addEventToGameManagerBloc(context, value.event!),
                        child: const Text('Repeat'),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Select Category'),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (context) => const QuizConfigScreen(),
            ),),
          ),
          body: SingleChildScrollView(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (state.isLoading) const CircularProgressIndicator(),
                      if (state.categories.isEmpty && !state.isLoading)
                        MaterialButton(
                          child: const Text('Get Categories'),
                          onPressed: () {
                            _refreshCategories(context);
                          },
                        ),
                      ...state.categories.map(
                        (e) => TextButton(
                          child: Text(e.name),
                          onPressed: () => _selectCategory(context, e),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
