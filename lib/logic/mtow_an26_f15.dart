import 'mtow_lookup.dart';

Future<int?> getMtowAn26F15({
  required int prAlt,
  required int temperature,
}) {
  const tempSteps = [
    -50,
    -40,
    -30,
    -20,
    -15,
    -10,
    -5,
    0,
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45
  ];

  return getMtow(
    table: 'F15OPT',
    tempSteps: tempSteps,
    prAlt: prAlt,
    temperature: temperature,
  );
}
