import 'dart:convert';

import 'package:quizz_test_task/src/core/utils/persisted_entry.dart';
import 'package:quizz_test_task/src/feature/quiz_config/model/quiz_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template quiz_config_datasource}
/// [QuizConfigDatasource] sets and gets quiz configuration settings.
/// {@endtemplate}
abstract interface class QuizConfigDatasource {
  /// Set quiz configuration
  Future<void> setQuizConfig(QuizConfig quizConfig);

  /// Load [QuizConfig] from the source of truth.
  Future<QuizConfig?> getQuizConfig();

  Future<void> removeConfig();
}

/// {@macro quiz_config_datasource}
final class QuizConfigDatasourceImpl implements QuizConfigDatasource {
  /// {@macro quiz_config_datasource}
  QuizConfigDatasourceImpl({required this.sharedPreferences});

  /// The instance of [SharedPreferences] used to read and write values.
  final SharedPreferencesAsync sharedPreferences;

  late final _quizConfigPersistedEntry = QuizConfigPersistedEntry(
    sharedPreferences: sharedPreferences,
    key: 'quizConfig',
  );

  @override
  Future<QuizConfig?> getQuizConfig() => _quizConfigPersistedEntry.read();

  @override
  Future<void> setQuizConfig(QuizConfig quizConfig) => _quizConfigPersistedEntry.set(quizConfig);

  @override
  Future<void> removeConfig() => _quizConfigPersistedEntry.remove();
}

/// Persisted entry for [QuizConfig]
class QuizConfigPersistedEntry extends SharedPreferencesEntry<QuizConfig> {
  /// Create [QuizConfigPersistedEntry]
  QuizConfigPersistedEntry({required super.sharedPreferences, required super.key});

  late final _config = StringPreferencesEntry(
    sharedPreferences: sharedPreferences,
    key: key,
  );

  @override
  Future<QuizConfig?> read() async {
    final config = await _config.read();

    if (config == null) {
      return null;
    }

    return QuizConfig.fromJson(jsonDecode(config) as Map<String, dynamic>);
  }

  @override
  Future<void> remove() => _config.remove();

  @override
  Future<void> set(QuizConfig value) async => await _config.set(jsonEncode(value.toJson()));
}
