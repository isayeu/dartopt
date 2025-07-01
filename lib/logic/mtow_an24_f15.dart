import 'mtow_lookup.dart';

Future<int?> getMtowAn24F15({
  required int prAlt,
  required int temperature,
}) {
  const tempSteps = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45];

  return getMtow(
    table: 'AN24RV_F15_ATM',
    tempSteps: tempSteps,
    prAlt: prAlt,
    temperature: temperature,
  );
}
