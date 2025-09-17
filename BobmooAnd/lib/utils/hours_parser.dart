// 시간 문자열 파싱 유틸리티
// 예시 입력: "08:00-09:30", "11:30~14:00", "08:00-09:00/11:30-13:30"

/// 반환: List<(DateTime start, DateTime end)>
List<(DateTime, DateTime)> parseTimeRanges(String s, DateTime now) {
  final parts = s.split(RegExp(r"[\/ ,;]"));
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
