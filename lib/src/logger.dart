/// Simple pluggable logger.
abstract class QueueLogger {
  /// Writes a log [message].
  void log(String message);
}

/// Default logger using `print`.
class ConsoleQueueLogger implements QueueLogger {
  /// Whether logging should produce output.
  final bool enabled;

  /// Creates a logger that prints to the console when [enabled].
  ConsoleQueueLogger({this.enabled = true});

  @override
  void log(String message) {
    if (enabled) {
      // ignore: avoid_print
      print(message);
    }
  }
}
