/// Returns a warm, time-appropriate greeting ("Good morning", etc).
String greetingForHour([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 5) return 'Still up?';
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  if (hour < 21) return 'Good evening';
  return 'Winding down?';
}
