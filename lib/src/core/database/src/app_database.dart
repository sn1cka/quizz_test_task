import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:quizz_test_task/src/feature/trivia/model/trivia_model.dart' as models;

part 'app_database.g.dart';

/// {@template app_database}
/// The drift-managed database configuration
/// {@endtemplate}
@DriftDatabase(include: {'tables.drift'})
class AppDatabase extends _$AppDatabase {
  /// {@macro app_database}
  AppDatabase(super.e);

  /// {@macro app_database}
  AppDatabase.defaults()
      : super(
          driftDatabase(
            name: 'sizzle',
            native: const DriftNativeOptions(shareAcrossIsolates: true),
            // TODO(mlazebny): Update the sqlite3Wasm and driftWorker paths
            // to match the location of the files in your project if needed.
            // https://drift.simonbinder.eu/web/#prerequisites
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  Future<List<models.Category>> getAllCategories() async {
    // Query to select all categories
    final query = select(categoriesDto);

    // Execute the query and map the results to a list of models.Category objects
    return query
        .map(
          (row) => models.Category(
            id: row.id,
            name: row.name,
          ),
        )
        .get();
  }

  Future<void> addCategories(List<models.Category> categoriesModels) async {
    // Start a transaction to ensure data integrity
    await transaction(() async {
      for (final category in categoriesModels) {
        await into(categoriesDto).insert(
          CategoriesDtoCompanion(
            id: Value(category.id), // Assuming the id is provided; remove if auto-incremented
            name: Value(category.name),
          ),
        );
      }
    });
    }

  Future<void> addQuestions(List<models.Question> questionsModels) async {
    // Start a transaction to ensure data integrity
    await transaction(() async {
      for (final question in questionsModels) {
        await into(questionsDto).insert(
          QuestionsDtoCompanion(
            type: Value(question.type.name),
            difficulty: Value(question.difficulty.name),
            category: Value(question.category),
            question: Value(question.question),
            correctAnswer: Value(question.correctAnswer),
            incorrectAnswers: Value(jsonEncode(question.incorrectAnswers)),
          ),
        );
      }
    });
  }

  Future<List<models.Question>> getQuestions({
    required int questionAmount,
    required String? category,
    models.Difficulty? difficulty,
    models.QuestionType? questionType,
  }) async {
    // Start building the query
    final query = select(questionsDto)..limit(questionAmount);

    if (category != null) {
      query.where((tbl) => tbl.category.equals(category));
    }

    if (difficulty != null) {
      query.where((tbl) => tbl.difficulty.equals(difficulty.name));
    }

    if (questionType != null) {
      query.where((tbl) => tbl.type.equals(questionType.name));
    }

    return query
        .map(
          (row) => models.Question(
            type: models.QuestionType.values.byName(row.type),
            difficulty: models.Difficulty.values.byName(row.difficulty),
            category: row.category,
            question: row.question,
            correctAnswer: row.correctAnswer,
            incorrectAnswers: (jsonDecode(row.incorrectAnswers) as List<dynamic>).cast<String>(),
          ),
        )
        .get();
  }
}
