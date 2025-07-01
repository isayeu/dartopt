double calculatePressureAltitude(dynamic feet, double qnhValue) {
  final elevationInMeters = (feet is int ? feet : int.tryParse(feet.toString()) ?? 0) * 0.3048;
  final deltaHpa = 1013 - qnhValue;
  final deltaInMeters = deltaHpa * 8;
  return elevationInMeters + deltaInMeters;
}
