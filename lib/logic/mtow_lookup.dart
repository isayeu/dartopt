import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';

Future<int?> getMtow({
  required String table,
  required List<int> tempSteps,
  required int prAlt,
  required int temperature,
}) async {
  final db = await DatabaseHelper.database;

  int tempLow =
      tempSteps.lastWhere((t) => t <= temperature, orElse: () => tempSteps.first);
  int tempHigh =
      tempSteps.firstWhere((t) => t >= temperature, orElse: () => tempSteps.last);

  // Protect against out of range
  if (tempLow == tempHigh) {
    final idx = tempSteps.indexOf(tempLow);
    if (idx < tempSteps.length - 1) {
      tempHigh = tempSteps[idx + 1];
    } else if (idx > 0) {
      tempLow = tempSteps[idx - 1];
    }
  }

  final int altLow = (prAlt / 100).floor() * 100;
  final int altHigh = altLow + 100;

  final double tRatio = (temperature - tempLow) / (tempHigh - tempLow);
  final double aRatio = (prAlt - altLow) / (altHigh - altLow);

  final results = await Future.wait([
    db.query(table, where: 'pr_alt = ?', whereArgs: [altLow]),
    db.query(table, where: 'pr_alt = ?', whereArgs: [altHigh]),
  ]);

  if (results[0].isEmpty || results[1].isEmpty) {
    return null;
  }

  final Map<String, Object?> rowLow = results[0].first;
  final Map<String, Object?> rowHigh = results[1].first;

  int? getVal(Map<String, Object?> row, int temp) {
    final val = row['$temp'];
    if (val is int) return val;
    if (val is String) return int.tryParse(val);
    return null;
  }

  final q11 = getVal(rowLow, tempLow);
  final q12 = getVal(rowLow, tempHigh);
  final q21 = getVal(rowHigh, tempLow);
  final q22 = getVal(rowHigh, tempHigh);

  if ([q11, q12, q21, q22].contains(null)) {
    return null;
  }

  final interp = (1 - aRatio) * ((1 - tRatio) * q11! + tRatio * q12!) +
      aRatio * ((1 - tRatio) * q21! + tRatio * q22!);

  return interp.round();
}
