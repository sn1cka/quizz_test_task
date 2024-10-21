import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

part 'game_bloc.freezed.dart';

@freezed
class GameEvent with _$GameEvent {
  const GameEvent._();

  const factory GameEvent.startGame({
    required List<Question> questions,
  }) = _StartGameEvent;

  const factory GameEvent.selectAnswer({
    required String answer,
  }) = _SelectAnswerGameEvent;

  const factory GameEvent.moveToNextQuestion() = _MoveToNexQuestiontGameEvent;
}

@freezed
class GameState with _$GameState {
  const factory GameState({
    required List<Question> questions,
    required int currentQuestionIndex,
    required String? selectedAnswer,
    required int correctCount,
    required List<String> currentVariants,
    required bool isGameEnded,
  }) = _GameState;

  const GameState._();

  Question get currentQuestion => questions[currentQuestionIndex];

  bool get isQuestion => selectedAnswer == null;

  bool get isResult => !isQuestion;

  bool get isPlaying => !isGameEnded && questions.isNotEmpty;
}

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(super.initialState) {
    on<_StartGameEvent>(_startGame);
    on<_SelectAnswerGameEvent>(_selectAnswer);
    on<_MoveToNexQuestiontGameEvent>(_moveToNextQuestion);
  }

  List<String> _getScrambledVariants(Question question) {
    final variants = [question.correctAnswer, ...question.incorrectAnswers];
    variants.swap(0, Random().nextInt(variants.length));
    return variants;
  }

  Future<void> _startGame(_StartGameEvent event, Emitter<GameState> emit) async {
    final variants = _getScrambledVariants(event.questions.first);
    emit(
      GameState(
        questions: event.questions,
        currentQuestionIndex: 0,
        selectedAnswer: null,
        correctCount: 0,
        currentVariants: variants,
        isGameEnded: false,
      ),
    );
  }

  Future<void> _selectAnswer(_SelectAnswerGameEvent event, Emitter<GameState> emit) async {
    final question = state.currentQuestion;
    final isCorrect = question.correctAnswer == event.answer;
    final correctAnswersCount = state.correctCount + (isCorrect ? 1 : 0);
    emit(state.copyWith(correctCount: correctAnswersCount, selectedAnswer: event.answer));
  }

  Future<void> _moveToNextQuestion(_MoveToNexQuestiontGameEvent event, Emitter<GameState> emit) async {
    final nextIndex = state.currentQuestionIndex + 1;
    final newState = state.copyWith(selectedAnswer: null, currentVariants: []);
    if (nextIndex >= state.questions.length) {
      emit(newState.copyWith(isGameEnded: true));
      return;
    }
    emit(
      newState.copyWith(
        currentQuestionIndex: nextIndex,
        currentVariants: _getScrambledVariants(state.questions[nextIndex]),
      ),
    );
  }
}
