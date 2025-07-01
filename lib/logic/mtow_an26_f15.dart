import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';

Future<int?> getMtowAn26F15({
  required int prAlt,
  required int temperature,
}) async {
  final db = await DatabaseHelper.database;

  const List<int> tempSteps = [
    -50, -40, -30, -20, -15, -10, -5, 0, 5, 10, 15, 20,
    25, 30, 35, 40, 45
  ];

  int tempLow = tempSteps.lastWhere((t) => t <= temperature, orElse: () => tempSteps.first);
  int tempHigh = tempSteps.firstWhere((t) => t >= temperature, orElse: () => tempSteps.last);

  // защита от выхода за пределы
  if (tempLow == tempHigh) {
    final idx = tempSteps.indexOf(tempLow);
    if (idx < tempSteps.length - 1) {
      tempHigh = tempSteps[idx + 1];
    } else if (idx > 0) {
      tempLow = tempSteps[idx - 1];
    }
  }

  int altLow = (prAlt / 100).floor() * 100;
  int altHigh = altLow + 100;

  double tRatio = (temperature - tempLow) / (tempHigh - tempLow);
  double aRatio = (prAlt - altLow) / (altHigh - altLow);

  Future<int?> getVal(int alt, int temp) async {
    final result = await db.rawQuery(
      'SELECT "$temp" FROM F15OPT WHERE pr_alt = ?',
      [alt],
    );
    if (result.isEmpty) return null;
    final val = result.first['$temp'];
    if (val is int) return val;
    if (val is String) return int.tryParse(val);
    return null;
  }

  final q11 = await getVal(altLow, tempLow);
  final q12 = await getVal(altLow, tempHigh);
  final q21 = await getVal(altHigh, tempLow);
  final q22 = await getVal(altHigh, tempHigh);

  if ([q11, q12, q21, q22].contains(null)) {
    print('Одно из значений null: q11=$q11, q12=$q12, q21=$q21, q22=$q22');
    return null;
  }

  final interp = (1 - aRatio) * ((1 - tRatio) * q11! + tRatio * q12!) +
                 aRatio * ((1 - tRatio) * q21! + tRatio * q22!);

  return interp.round();
}
