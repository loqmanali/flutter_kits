import 'package:animation_kit/animation_kit.dart';
import 'package:animation_kit/config/transition_config.dart' as config;
import 'package:flutter/material.dart';

/// Basic Animations Example
///
/// Demonstrates basic animation widgets from Animation Kit.
///
/// This example shows:
/// - Fade transition
/// - Slide transition
/// - Scale transition
/// - Rotation transition
/// - Pulse animation
/// - Shake animation
/// - Bounce animation
/// - Heartbeat animation
class BasicAnimationsExample extends StatelessWidget {
  const BasicAnimationsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Animations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Transition Animations'),
          _buildFadeExample(),
          _buildSlideExample(),
          _buildScaleExample(),
          _buildRotationExample(),
          const SizedBox(height: 32),
          _buildSectionTitle('Micro-animations'),
          _buildPulseExample(),
          _buildShakeExample(),
          _buildBounceExample(),
          _buildHeartbeatExample(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFadeExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fade Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            FadeTransitionWidget(
              config: AnimationConfig.fade(),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text(
                  'Fade In/Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Slide Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SlideTransitionWidget(
              config: config.TransitionConfig.slide(
                type: TransitionType.slideRight,
              ),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.green,
                alignment: Alignment.center,
                child: const Text(
                  'Slide From Right',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scale Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ScaleTransitionWidget(
              config: AnimationConfig.scale(
                curve: AnimationCurve.elasticOut,
              ),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.orange,
                alignment: Alignment.center,
                child: const Text(
                  'Scale In/Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotationExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rotation Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RotationTransitionWidget(
              config: AnimationConfig.rotation(
                duration: const Duration(milliseconds: 500),
              ),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.purple,
                alignment: Alignment.center,
                child: const Text(
                  'Rotate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pulse Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            PulseWidget(
              config: AnimationConfig.pulse(),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.red,
                alignment: Alignment.center,
                child: const Text(
                  'Pulsing',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShakeExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shake Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ShakeWidget(
              config: AnimationConfig.shake(),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.teal,
                alignment: Alignment.center,
                child: const Text(
                  'Shake Me',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBounceExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bounce Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            BounceWidget(
              config: AnimationConfig.bounce(),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.pink,
                alignment: Alignment.center,
                child: const Text(
                  'Bounce',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartbeatExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Heartbeat Animation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            HeartbeatWidget(
              config: AnimationConfig.heartbeat(),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.deepOrange,
                alignment: Alignment.center,
                child: const Text(
                  '❤️ Heartbeat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
