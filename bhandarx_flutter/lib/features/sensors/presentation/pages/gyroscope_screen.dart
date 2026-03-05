import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeScreen extends StatefulWidget {
  static const routeName = '/sensors/gyroscope';

  const GyroscopeScreen({super.key});

  @override
  State<GyroscopeScreen> createState() => _GyroscopeScreenState();
}

class _GyroscopeScreenState extends State<GyroscopeScreen> {
  StreamSubscription<GyroscopeEvent>? _sub;
  GyroscopeEvent? _event;

  @override
  void initState() {
    super.initState();
    _sub = gyroscopeEventStream().listen((event) {
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text('Gyroscope'),
      ),
      body: Center(
        child: event == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Gyroscope',
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
