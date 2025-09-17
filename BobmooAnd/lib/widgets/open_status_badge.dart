import 'package:bobmoo/models/menu_model.dart';
import 'package:flutter/material.dart';

class OpenStatusBadge extends StatelessWidget {
  final Hours hours;
  final String mealType; // '아침' | '점심' | '저녁'
  final DateTime now;

  OpenStatusBadge({
    super.key,
    required this.hours,
    required this.mealType,
    DateTime? now,
  }) : now = now ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final hoursString = switch (mealType) {
      '아침' => hours.breakfast,
      '점심' => hours.lunch,
      '저녁' => hours.dinner,
      _ => '',
    };

    if (hoursString.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final status = getStatusForHours(hoursString, now);
    switch (status) {
      case OpenStatus.before:
        return _StatusBadge(
          text: '운영전',
          backgroundColor: const Color(0xFF909090),
          textColor: Colors.white,
        );
      case OpenStatus.open:
        return _StatusBadge(
          text: '운영중',
          backgroundColor: Colors.lightBlue.shade600,
          textColor: Colors.white,
        );
      case OpenStatus.after:
        return _StatusBadge(
          text: '운영종료',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      case OpenStatus.unknown:
        return const SizedBox.shrink();
    }
  }
}

enum OpenStatus { before, open, after, unknown }

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _StatusBadge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

/// 주어진 hours 문자열(예: "08:00-09:30", "11:30~14:00", "08:00-09:00/11:30-13:30")을 해석하여 현재 상태를 계산
OpenStatus getStatusForHours(String hoursString, DateTime now) {
  final ranges = parseTimeRanges(hoursString, now);
  if (ranges.isEmpty) return OpenStatus.unknown;

  ranges.sort((a, b) => a.$1.compareTo(b.$1));

  final isOpen = ranges.any((r) => now.isAfter(r.$1) && now.isBefore(r.$2));
  if (isOpen) return OpenStatus.open;
  final earliestStart = ranges.first.$1;
  if (now.isBefore(earliestStart)) return OpenStatus.before;

  final latestEnd = ranges
      .map((r) => r.$2)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  if (now.isAfter(latestEnd)) return OpenStatus.after;

  // 운영 중, 전, 후가 아닌 모든 경우 (예: 오전/오후 운영 사이의 쉬는 시간)
  // hoursString가 "08:00-09:00/11:30-13:30" 이런식일때
  return OpenStatus.unknown;
}

// 반환: List<(DateTime start, DateTime end)>
List<(DateTime, DateTime)> parseTimeRanges(String s, DateTime now) {
  final parts = s.split(RegExp(r"[\/,;]"));
  final result = <(DateTime, DateTime)>[];
  for (final raw in parts) {
    final seg = raw.trim();
    if (seg.isEmpty) continue;

    final split = seg.split(RegExp(r"\s*[-–~]\s*"));
    if (split.length != 2) continue;

    final startStr = split[0].trim();
    final endStr = split[1].trim();

    final start = parseTodayTime(startStr, now);
    final end = parseTodayTime(endStr, now);
    if (start == null || end == null) continue;
    if (!end.isAfter(start)) continue;

    result.add((start, end));
  }
  return result;
}

DateTime? parseTodayTime(String hhmm, DateTime now) {
  final m = RegExp(r"^(\d{1,2})(?::?(\d{2}))?").firstMatch(hhmm.trim());
  if (m == null) return null;
  final h = int.tryParse(m.group(1) ?? '0');
  final min = int.tryParse(m.group(2) ?? '0');
  if (h == null || min == null) return null;
  if (h < 0 || h > 23 || min < 0 || min > 59) return null;
  return DateTime(now.year, now.month, now.day, h, min);
}
