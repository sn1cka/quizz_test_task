import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quizz_test_task/src/feature/quiz_config/data/quiz_config_repository.dart';
import 'package:quizz_test_task/src/feature/quiz_config/model/quiz_config.dart';

part 'quiz_config_bloc.freezed.dart';

@freezed
class QuizConfigEvent with _$QuizConfigEvent {
  const QuizConfigEvent._();

  const factory QuizConfigEvent.updateConfig({required QuizConfig config}) = _UpdateQuizConfigEvent;

  const factory QuizConfigEvent.removeConfig() = _RemoveQuizConfigEvent;
}

@freezed
class QuizConfigState with _$QuizConfigState {
  const QuizConfigState._();

  const factory QuizConfigState.idle({required QuizConfig config}) = _IdleQuizConfigState;

  const factory QuizConfigState.loading({required QuizConfig config}) = _LoadingQuizConfigState;

  const factory QuizConfigState.error({
    required QuizConfig config,
    required Object error,
  }) = _ErrorQuizConfigState;
}

class QuizConfigBloc extends Bloc<QuizConfigEvent, QuizConfigState> {
  final QuizConfigRepository _quizConfigRepository;

  QuizConfigBloc({
    required QuizConfigRepository quizConfigRepository,
    required QuizConfigState initialState,
  })  : _quizConfigRepository = quizConfigRepository,
        super(initialState) {
    on<_UpdateQuizConfigEvent>(_updateConfig);
    on<_RemoveQuizConfigEvent>(_removeConfig);
  }

  Future<void> _updateConfig(
    _UpdateQuizConfigEvent event,
    Emitter<QuizConfigState> emit,
  ) async {
    try {
      emit(_LoadingQuizConfigState(config: state.config));
      await _quizConfigRepository.setConfig(event.config);
      emit(_IdleQuizConfigState(config: event.config));
    } catch (error) {
      emit(_ErrorQuizConfigState(config: event.config, error: error));
      rethrow;
    }
  }

  Future<void> _removeConfig(event, Emitter<QuizConfigState> emit) async {
    try {
      emit(_LoadingQuizConfigState(config: state.config));
      await _quizConfigRepository.removeConfig();
      final defaultConfig = await _quizConfigRepository.getConfig();
      emit(_IdleQuizConfigState(config: defaultConfig));
    } catch (error) {
      emit(_ErrorQuizConfigState(config: state.config, error: error));
      rethrow;
    }
  }
}
