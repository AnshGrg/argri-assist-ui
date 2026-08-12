class StringUtils {
  static String formatUsername(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    var name = raw.trim();
    if (name.contains('.')) {
      name = name.split('.').last;
    }
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }
}
