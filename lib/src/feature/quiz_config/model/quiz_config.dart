import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

part 'quiz_config.freezed.dart';
part 'quiz_config.g.dart';

@freezed
class QuizConfig with _$QuizConfig {
  const factory QuizConfig({
    required int questionAmount,
    Difficulty? difficulty,
    QuestionType? questionType,
  }) = _QuizConfig;

  factory QuizConfig.fromJson(Map<String, dynamic> json) => _$QuizConfigFromJson(json);
}
