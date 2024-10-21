import 'package:freezed_annotation/freezed_annotation.dart';

part 'trivia_model.freezed.dart';
part 'trivia_model.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required int id,
    required String name,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class Question with _$Question {
@JsonSerializable(fieldRename: FieldRename.snake)
  const factory Question({
    required QuestionType type,
    required Difficulty difficulty,
    required String category,
    required String question,
    required String correctAnswer, // Maps to 'correct_answer' in JSON
    required List<String> incorrectAnswers, // Maps to 'incorrect_answers' in JSON
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
}

enum QuestionType { boolean, multiple }

enum Difficulty { easy, medium, hard }
