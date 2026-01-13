import 'package:flutter/material.dart';
import 'dart:math' as math;

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ), // Duration for one wave cycle
      vsync: this,
    )..repeat(); // Continuously repeat the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.health_and_safety, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildDot(context, 0),
                const SizedBox(width: 4),
                _buildDot(context, 2 * math.pi / 3), // 120-degree phase shift
                const SizedBox(width: 4),
                _buildDot(context, 4 * math.pi / 3), // 240-degree phase shift
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, double phase) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate the vertical offset using a sine wave
        final offset = math.sin(_controller.value * 2 * math.pi + phase) * 3;
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
