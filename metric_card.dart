import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final String unit;
  final double value;
  final Color accent;
  final String statusText;
  final Color statusColor;
  final double min;
  final double max;

  const MetricCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unit,
    required this.value,
    required this.accent,
    required this.statusText,
    required this.statusColor,
    this.min = 0,
    this.max = 100,
  });

  @override
  Widget build(BuildContext context) {
    final pct = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: TextStyle(fontSize: 18, color: accent)),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text(unit,
                    style: TextStyle(
                        color: accent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: const Color(0xFF374151),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(statusText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}