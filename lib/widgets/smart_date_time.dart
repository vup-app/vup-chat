import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SmartDateTimeWidget extends StatelessWidget {
  final DateTime dateTime;
  final double? fontSize;
  final Color? color;
  final int? mode; // null, default; 1, time only

  const SmartDateTimeWidget({
    super.key,
    required this.dateTime,
    this.fontSize,
    this.color,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDateTime(dateTime),
      style: TextStyle(
        fontSize: fontSize ?? 10,
        color: color,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (mode == 1) {
      // Mode 1: Only time
      return DateFormat.Hm().format(dateTime); // Returns only the time
    } else if (dateTime.isAfter(today)) {
      // Today
      return 'Today, ${DateFormat.Hm().format(dateTime)}';
    } else if (dateTime.isAfter(yesterday)) {
      // Yesterday
      return 'Yesterday, ${DateFormat.Hm().format(dateTime)}';
    } else {
      // Older dates
      return DateFormat('MMM d, y, H:m').format(dateTime);
    }
  }
}
