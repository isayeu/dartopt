import 'mtow_lookup.dart';

Future<int?> getMtowAn26F5({
  required int prAlt,
  required int temperature,
}) {
  const tempSteps = [
    -30,
    -25,
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
    table: 'F5OPT',
    tempSteps: tempSteps,
    prAlt: prAlt,
    temperature: temperature,
  );
}
