import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';
import 'package:retrofit/retrofit.dart';

part 'trivia_rest_client.freezed.dart';
part 'trivia_rest_client.g.dart';

@RestApi(baseUrl: 'https://opentdb.com/')
abstract class TriviaRestClient {
  factory TriviaRestClient(Dio dio) = _TriviaRestClient;

  @GET('api_category.php')
  Future<CategoryResponseModel> getCategories();

  @GET('api.php')
  Future<QuestionsResponseModel> getQuestions({
    @Query('amount') int amount = 10,
    @Query('category') int? categoryId,
    @Query('difficulty') Difficulty? difficulty,
    @Query('type') QuestionType? questionsType,
  });
}

@freezed
class QuestionsResponseModel with _$QuestionsResponseModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory QuestionsResponseModel({
    required int responseCode, // The 'response_code' from the API
    required List<Question> results, // The list of questions (QuestionModel)
  }) = _QuestionsResponseModel;

  factory QuestionsResponseModel.fromJson(Map<String, dynamic> json) => _$QuestionsResponseModelFromJson(json);
}

@freezed
class CategoryResponseModel with _$CategoryResponseModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CategoryResponseModel({
    required List<Category> triviaCategories, // List of CategoryModel
  }) = _CategoryResponseModel;

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) => _$CategoryResponseModelFromJson(json);
}
