import 'package:quizz_test_task/src/feature/quiz_config/data/quiz_config_datasource.dart';
import 'package:quizz_test_task/src/feature/quiz_config/model/quiz_config.dart';

abstract interface class QuizConfigRepository {
  Future<void> setConfig(QuizConfig config);

  Future<void> removeConfig();

  Future<QuizConfig> getConfig();
}

class QuizConfigRepositoryImpl implements QuizConfigRepository {
  final QuizConfigDatasource _datasource;

  const QuizConfigRepositoryImpl({required QuizConfigDatasource datasource}) : _datasource = datasource;

  @override
  Future<QuizConfig> getConfig() async {
    final result = await _datasource.getQuizConfig();
    return result ?? const QuizConfig(questionAmount: 10);
  }

  @override
  Future<void> setConfig(QuizConfig config) => _datasource.setQuizConfig(config);

  @override
  Future<void> removeConfig() => _datasource.removeConfig();
}
