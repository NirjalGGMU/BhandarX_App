import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerScreen extends StatefulWidget {
  static const routeName = '/sensors/accelerometer';

  const AccelerometerScreen({super.key});

  @override
  State<AccelerometerScreen> createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {
  StreamSubscription<AccelerometerEvent>? _sub;
  AccelerometerEvent? _event;

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream().listen((event) {
      if (!mounted) {
        return;
      }
      setState(() {
        _event = event;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Accelerometer'),
      ),
      body: Center(
        child: event == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Accelerometer',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Text('X: ${event.x.toStringAsFixed(3)}'),
                  Text('Y: ${event.y.toStringAsFixed(3)}'),
                  Text('Z: ${event.z.toStringAsFixed(3)}'),
                ],
              ),
      ),
    );
  }
}
