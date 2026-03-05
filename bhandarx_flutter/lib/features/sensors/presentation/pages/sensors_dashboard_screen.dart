import 'package:bhandarx_flutter/features/sensors/presentation/pages/accelerometer_screen.dart';
import 'package:bhandarx_flutter/features/sensors/presentation/pages/gyroscope_screen.dart';
import 'package:flutter/material.dart';

class SensorsDashboardScreen extends StatelessWidget {
  static const routeName = '/sensors';

  const SensorsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'Accelerometer',
        Icons.sensors,
        Colors.blue,
        () => Navigator.pushNamed(context, AccelerometerScreen.routeName)
      ),
      (
        'Gyroscope',
        Icons.explore_rounded,
        Colors.green,
        () => Navigator.pushNamed(context, GyroscopeScreen.routeName)
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors Dashboard'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: card.$4,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card.$3.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: card.$3.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: card.$3,
                    foregroundColor: Colors.white,
                    child: Icon(card.$2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      card.$1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
