import 'dart:async';

import 'package:quizz_test_task/src/core/utils/refined_logger.dart';
import 'package:quizz_test_task/src/feature/initialization/logic/app_runner.dart';

void main() => runZonedGuarded(
      () => const AppRunner().initializeAndRun(),
      logger.logZoneError,
    );
