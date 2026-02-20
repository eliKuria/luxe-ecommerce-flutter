/// Converts raw error/exception strings to user-friendly messages.
///
/// Use this when displaying errors to users to ensure no technical
/// details (stack traces, exception class names) are ever shown.
String friendlyError(dynamic error) {
  final raw = error.toString();

  // Strip common prefixes
  var msg = raw
      .replaceFirst(RegExp(r'^Exception:\s*'), '')
      .replaceFirst(RegExp(r'^AuthException:\s*'), '')
      .replaceFirst(RegExp(r'^PostgrestException:\s*'), '')
      .replaceFirst(RegExp(r'^FunctionException.*?:\s*'), '')
      .replaceFirst(RegExp(r'^SocketException.*?:\s*'), '')
      .replaceFirst(RegExp(r'^ClientException.*?:\s*'), '');

  final lower = msg.toLowerCase();

  // Auth-specific errors
  if (lower.contains('invalid login credentials') || lower.contains('invalid_credentials')) {
    return 'Incorrect email or password. Please try again.';
  }
  if (lower.contains('email not confirmed') || lower.contains('not confirmed')) {
    return 'Please verify your email before signing in.';
  }
  if (lower.contains('user already registered') || lower.contains('already registered')) {
    return 'An account with this email already exists. Try logging in instead.';
  }
  if (lower.contains('password') && lower.contains('characters')) {
    return 'Password must be at least 8 characters long.';
  }
  if (lower.contains('invalid email') || lower.contains('unable to validate email')) {
    return 'Please enter a valid email address.';
  }
  if (lower.contains('rate limit') || lower.contains('too many requests')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }

  // Network errors
  if (lower.contains('socket') || lower.contains('network') || lower.contains('connection')) {
    return 'No internet connection. Please check your network and try again.';
  }
  if (lower.contains('timeout') || lower.contains('timed out')) {
    return 'The request timed out. Please try again.';
  }

  // JWT / Auth session errors
  if (lower.contains('jwt') || lower.contains('unauthorized') || lower.contains('401')) {
    return 'Your session has expired. Please log in again.';
  }

  // If the message is already user-friendly (starts with uppercase, has a period)
  if (msg.isNotEmpty && msg[0] == msg[0].toUpperCase() && !msg.contains('Exception')) {
    return msg;
  }

  // Fallback
  return 'Something went wrong. Please try again.';
}
