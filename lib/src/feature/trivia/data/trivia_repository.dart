import 'package:quizz_test_task/src/feature/trivia/data/trivia_datasource.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart';

abstract interface class TriviaRepository {
  Future<List<Category>> getCategories();

  Future<List<Question>> getQuestions({
    int amount = 10,
    Category? category,
    Difficulty? difficulty,
    QuestionType? questionsType,
  });
}

class TriviaRepositoryImpl implements TriviaRepository {
  const TriviaRepositoryImpl({
    required TriviaRemoteDataSource remoteDataSource,
    required TriviaPersistentDatasource persistentDatasource,
  })  : _remoteDataSource = remoteDataSource,
        _persistentDatasource = persistentDatasource;

  final TriviaRemoteDataSource _remoteDataSource;
  final TriviaPersistentDatasource _persistentDatasource;

  @override
  Future<List<Category>> getCategories() async {
    try {
      var categories = await _persistentDatasource.getCategories();
      if (categories.isEmpty) {
        categories = await _remoteDataSource.getCategories();
        await _persistentDatasource.saveCategories(categories);
      }
      return categories;
    } catch (e) {
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
      var questions = <Question>[];

      questions = await _persistentDatasource.getQuestions(
        category: category,
        questionsType: questionsType,
        difficulty: difficulty,
        amount: amount,
      );

      if (questions.length < amount) {
        questions = await _remoteDataSource.getQuestions(
          amount: amount,
          category: category,
          questionsType: questionsType,
        );
        await _persistentDatasource.addQuestions(questions);
      }
      return questions;
    } catch (e) {
      rethrow;
    }
  }
}
