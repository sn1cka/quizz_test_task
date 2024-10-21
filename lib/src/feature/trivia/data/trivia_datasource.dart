import 'package:quizz_test_task/src/core/database/database.dart' as app_database;
import 'package:quizz_test_task/src/feature/trivia/data/trivia_rest_client.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

abstract final class TriviaDatasource {
  Future<List<Category>> getCategories();

  Future<List<Question>> getQuestions({
    int amount = 10,
    Category? category,
    Difficulty? difficulty,
    QuestionType? questionsType,
  });
}

final class TriviaRemoteDataSource implements TriviaDatasource {
  final TriviaRestClient _client;

  TriviaRemoteDataSource({required TriviaRestClient client}) : _client = client;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final result = await _client.getCategories();
      return result.triviaCategories;
    } on Object {
      rethrow;
    }
  }

  @override
  Future<List<Question>> getQuestions({
    int amount = 10,
    Category? category,
    Difficulty? difficulty,
    QuestionType? questionsType,
  }) async {
    try {
      final result = await _client.getQuestions(
        amount: amount,
        categoryId: category?.id,
        questionsType: questionsType,
      );
      return result.results;
    } on Object {
      rethrow;
    }
  }
}

final class TriviaPersistentDatasource implements TriviaDatasource {
  final app_database.AppDatabase _db;

  TriviaPersistentDatasource({required app_database.AppDatabase appDataBase}) : _db = appDataBase;

  @override
  Future<List<Category>> getCategories() => _db.getAllCategories();

  @override
  Future<List<Question>> getQuestions({
    int amount = 10,
    Category? category,
    Difficulty? difficulty,
    QuestionType? questionsType,
  }) =>
      _db.getQuestions(questionAmount: amount, category: category?.name);

  Future<void> saveCategories(List<Category> categories) => _db.addCategories(categories);

  Future<void> addQuestions(List<Question> questions) => _db.addQuestions(questions);
}
