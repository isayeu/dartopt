import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    late String path;
    if (Platform.isAndroid || Platform.isIOS) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = p.join(documentsDirectory.path, 'data.db');

      final exists = await File(path).exists();

      if (!exists) {
        // Копируем из assets
        final data = await rootBundle.load('assets/data.db');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes);
      }

    } else {
      // Для десктопа
      path = p.join(Directory.current.path, 'assets/data.db');
    }

  return await databaseFactory.openDatabase(path);
}


  static Future<Map<String, dynamic>?> getAirportByIcao(String icao) async {
    // Убираем пробелы, переводим в верхний регистр, проверяем на валидность
    final normalized = icao.trim().toUpperCase();

    final valid = RegExp(r'^[A-Z]{4}$');
    if (!valid.hasMatch(normalized)) {
      print('❌ Некорректный ICAO-код: $icao');
      return null;
    }
    final db = await database;
    final result = await db.query(
      'airports',
      where: 'ICAO = ?',
      whereArgs: [normalized],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
