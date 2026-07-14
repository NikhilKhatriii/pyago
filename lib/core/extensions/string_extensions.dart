extension StringX on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isValidEmail =>
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(this);

  /// True for a password of at least 8 characters containing a letter
  /// and a number — Pyago's minimum bar, enforced client-side for
  /// immediate feedback (the server enforces the authoritative rule).
  bool get isValidPassword =>
      length >= 8 && RegExp(r'[A-Za-z]').hasMatch(this) && RegExp(r'\d').hasMatch(this);

  String initialsFrom({int max = 2}) {
    final parts = trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final letters = parts.take(max).map((p) => p[0].toUpperCase());
    return letters.join();
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength).trimRight()}…';
  }
}
