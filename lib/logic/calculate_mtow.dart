import '../db/database_helper.dart';
import '../logic/mtow_an26_f15.dart';
import '../logic/mtow_an26_f5.dart';
import '../logic/mtow_an24_f15.dart';
import 'package:dartopt/logic/calculate_pr_alt.dart';
import 'package:dartopt/logic/wind_calc.dart';

Future<String> calculateMtow({
  required String aircraft,
  required String flaps,
  required String icao,
  required String rwyHeading,
  required String temp,
  required String qnh,
  required String windDir,
  required String windSpeed,
}) async {
  final airport = await DatabaseHelper.getAirportByIcao(icao);
  if (airport == null) {
    return 'Аэродром с ICAO "$icao" не найден.';
  }

  final prAlt = calculatePressureAltitude(
    airport['alevation'],
    double.tryParse(qnh) ?? 1013,
  ).round();

  final tempInt = int.tryParse(temp) ?? 0;
  int? mtow;
  if (aircraft == 'Ан-26') {
    if (flaps == '15') {
      mtow = await getMtowAn26F15(prAlt: prAlt, temperature: tempInt);
    } else if (flaps == '5') {
      mtow = await getMtowAn26F5(prAlt: prAlt, temperature: tempInt);
    }
  }
  else if (aircraft == 'Ан-24') {
  if (flaps == '15') {
    mtow = await getMtowAn24F15(prAlt: prAlt, temperature: tempInt);
  }
}

  final headwind = calculateHeadwindComponent(
    windDirection: int.tryParse(windDir) ?? 0,
    windSpeed: int.tryParse(windSpeed) ?? 0,
    runwayHeading: int.tryParse(rwyHeading) ?? 0,
  );

  final correction = (mtow != null)
      ? calculateWindCorrection(
          headwindComponent: headwind,
          mtow: mtow,
          aircraft: aircraft,
          flaps: flaps,
        )
      : 0.0;

  if (correction == -1) {
    return '❌ Взлёт запрещён: Ограничение по ветру!';
  }

  final adjustedMtow = mtow != null ? (mtow + correction).round() : null;

  final airportInfo =
      'Аэродром: ${airport['name']} (${airport['ICAO']})\n'
      'Город: ${airport['city']}, ${airport['country']}\n'
      'Pressure Altitude: $prAlt м;';

  final windType = headwind >= 0 ? 'встречный' : 'попутный';

  final result = '$airportInfo \n\n'
      'MTOW для $aircraft, закрылки $flaps: ${adjustedMtow ?? "н/д"} кг\n'
      'Темп: $temp°C, QNH: $qnh hPa\n'
      'Ветер: $windType, ${headwind.abs().toStringAsFixed(1)} м/с';

  return result;
}
