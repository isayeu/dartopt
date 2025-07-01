import 'dart:math';

/// Вычисление встречной составляющей ветра
double calculateHeadwindComponent({
  required int windDirection,
  required int windSpeed,
  required int runwayHeading,
}) {
  int angle = (windDirection - runwayHeading).abs() % 360;
  if (angle > 180) angle = 360 - angle;

  final angleRad = angle * pi / 180;
  final headwind = windSpeed * cos(angleRad);

  return headwind;
}

/// Расчёт ветровой поправки к MTOW в зависимости от конфигурации закрылков
double calculateWindCorrection({
  required double headwindComponent,
  required int mtow,
  required String aircraft,
  required String flaps,
}) {
  final clampedMtow = mtow.clamp(0, 25000);

  // Ограничение: если ветер вне допустимых пределов
  if (headwindComponent < -5 || headwindComponent > 30) {
    return -1; // ❌ превышены ограничения по ветру
  }

  final headwind = headwindComponent.clamp(-5, 30);

  if (flaps == '15') {
    if (headwindComponent >= 0) {
      // Встречный ветер (точная модель)
      final k = 0.0017857 * clampedMtow - 5.357;
      return headwindComponent * k;
    } else {
      // Попутный ветер до 5 м/с — нелинейная модель
      final clamped = headwind.clamp(-5, 0);
      final relativeMtow = (clampedMtow - 17500).clamp(0, 7500);
      final totalLossAt5ms = 275 + 0.03 * relativeMtow;
      final ratio = clamped.abs() / 5.0;
      return -totalLossAt5ms * ratio;
    }
  } else if (flaps == '5') {
    if (headwindComponent < 0) {
      return -1; // ❌ попутный ветер запрещён
    } else {
      final correction = 0.0075 * clampedMtow + 49.55 * headwind - 626;
      return correction;
    }
  }

  return 0.0; // Без ветровой поправки
}
