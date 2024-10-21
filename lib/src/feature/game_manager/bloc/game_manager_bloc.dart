import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quizz_test_task/src/feature/quiz_config/model/quiz_config.dart';
import 'package:quizz_test_task/src/feature/trivia/data/trivia_repository.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

part 'game_manager_bloc.freezed.dart';

@freezed
class GameManagerEvent with _$GameManagerEvent {
  const GameManagerEvent._();

  const factory GameManagerEvent.getCategories() = _GetCategoriesEvent;

  const factory GameManagerEvent.getCategoryQuestions({
    required Category? category,
    required QuizConfig config,
  }) = _GetQuestionsEvent;
}

@freezed
class GameManagerState with _$GameManagerState {
  const GameManagerState._();

  const factory GameManagerState.idle({
    required List<Category> categories,
  }) = _IdleGameManagerState;

  const factory GameManagerState.categorySelected({
    required List<Category> categories,
    required Category? category,
    required List<Question> questions,
  }) = _CategorySelectedGameManagerState;

  const factory GameManagerState.loading({
    required List<Category> categories,
  }) = _LoadingGameManagerState;

  const factory GameManagerState.error({
    required List<Category> categories,
    required Object error,
    GameManagerEvent? event,
  }) = _ErrorGameManagerState;

  bool get isLoading => maybeMap(orElse: () => false, loading: (value) => true);
}

class GameManagerBloc extends Bloc<GameManagerEvent, GameManagerState> {
  final TriviaRepository _repository;

  GameManagerBloc({
    required TriviaRepository repository,
    required GameManagerState initialState,
  })  : _repository = repository,
        super(initialState) {
    on<_GetCategoriesEvent>(_getCategories);
    on<_GetQuestionsEvent>(_getQuestions);
  }

  Future<void> _getCategories(_GetCategoriesEvent event, Emitter<GameManagerState> emit) async {
    try {
      emit(const GameManagerState.loading(categories: []));
      final categories = await _repository.getCategories();
      emit(GameManagerState.idle(categories: categories));
    } catch (e) {
      emit(GameManagerState.error(categories: [], error: e, event: event));
      rethrow;
    }
  }

  Future<void> _getQuestions(_GetQuestionsEvent event, Emitter<GameManagerState> emit) async {
    final categories = state.categories;
    try {
      emit(GameManagerState.loading(categories: categories));
      final config = event.config;
      final questions = await _repository.getQuestions(
          amount: config.questionAmount,
          difficulty: config.difficulty,
          questionsType: config.questionType,
          category: event.category,);
      emit(GameManagerState.categorySelected(
        categories: categories,
        questions: questions,
        category: event.category,
      ),);
    } catch (e) {
      emit(GameManagerState.error(categories: categories, error: e, event: event));
      rethrow;
    }
  }
}
