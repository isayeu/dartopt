import 'package:flutter/material.dart';
import '../logic/calculate_mtow.dart';

class MtowFormPage extends StatefulWidget {
  const MtowFormPage({super.key});

  @override
  State<MtowFormPage> createState() => _MtowFormPageState();
}

class _MtowFormPageState extends State<MtowFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _aircraft = 'Ан-26';
  String _flaps = '15';
  final _icaoController = TextEditingController();
  final _tempController = TextEditingController();
  final _qnhController = TextEditingController();
  final _rwyHeadingController = TextEditingController();
  final _windDirController = TextEditingController();
  final _windSpeedController = TextEditingController();

  @override
  void dispose() {
    _icaoController.dispose();
    _tempController.dispose();
    _qnhController.dispose();
    _rwyHeadingController.dispose();
    _windDirController.dispose();
    _windSpeedController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() async {
    if (_formKey.currentState!.validate()) {
      final result = await calculateMtow(
        aircraft: _aircraft,
        flaps: _flaps,
        icao: _icaoController.text.trim(),
        rwyHeading: _rwyHeadingController.text.trim(),
        temp: _tempController.text.trim().isEmpty ? '15' : _tempController.text.trim(),
        qnh: _qnhController.text.trim().isEmpty ? '1013' : _qnhController.text.trim(),
        windDir: _windDirController.text.trim().isEmpty ? '0' : _windDirController.text.trim(),
        windSpeed: _windSpeedController.text.trim().isEmpty ? '0' : _windSpeedController.text.trim(),
      );

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Результат'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _aircraft,
                    decoration: const InputDecoration(labelText: 'Самолёт'),
                    items: const [
                      DropdownMenuItem(value: 'Ан-26', child: Text('Ан-26')),
                      DropdownMenuItem(value: 'Ан-24', child: Text('Ан-24')),
                    ],
                    onChanged: (value) => setState(() => _aircraft = value!),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _flaps,
                    decoration: const InputDecoration(labelText: 'Закрылки'),
                    items: const [
                      DropdownMenuItem(value: '15', child: Text('15°')),
                      DropdownMenuItem(value: '5', child: Text('5°')),
                    ],
                    onChanged: (value) => setState(() => _flaps = value!),
                  ),
                ),
              ],
            ),
            Row(
              children:[
                Expanded(
                  child: TextFormField(
                    controller: _icaoController,
                    decoration: const InputDecoration(labelText: 'ICAO индекс'),
                    validator: (v) => v == null || v.isEmpty ? 'Введите ICAO' : null,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: TextFormField(
                    controller: _rwyHeadingController,
                    decoration: const InputDecoration(labelText: 'Курс ВПП (°)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Введите курс ВПП' : null,
                  ),
                ),
              ],
            ),
            Row(
              children:[
                Expanded(
                  child: TextFormField(
                    controller: _tempController,
                    decoration: const InputDecoration(labelText: 'Температура (°C)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: TextFormField(
                    controller: _qnhController,
                    decoration: const InputDecoration(labelText: 'QNH (hPa)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children:[
                Expanded(
                  child: TextFormField(
                    controller: _windDirController,
                    decoration: const InputDecoration(labelText: 'δ ветра (°)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: TextFormField(
                    controller: _windSpeedController,
                    decoration: const InputDecoration(labelText: 'U ветра (м/с)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onCalculatePressed,
              child: const Text('Рассчитать MTOW'),
            ),
          ],
        ),
      ),
    );
  }
}
