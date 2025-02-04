import 'dart:async';

import 'package:flutter/material.dart';

class CoffeeTimeAgoWidget extends StatefulWidget {
  const CoffeeTimeAgoWidget({
    required this.date,
    super.key,
    this.enableTimeAgoTimer = true,
  });

  final DateTime date;
  final bool enableTimeAgoTimer;

  @override
  State<CoffeeTimeAgoWidget> createState() => _CoffeeTimeAgoState();
}

class _CoffeeTimeAgoState extends State<CoffeeTimeAgoWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Update every minute
    if (widget.enableTimeAgoTimer) {
      _timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(widget.date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes != 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours != 1 ? 's' : ''} ago';
    } else {
      final days = difference.inDays;
      return '$days day${days != 1 ? 's' : ''} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getTimeAgo(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
