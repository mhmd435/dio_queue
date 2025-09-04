/// Simple pluggable logger.
abstract class QueueLogger {
  void log(String message);
}

/// Default logger using `print`.
class ConsoleQueueLogger implements QueueLogger {
  final bool enabled;
  ConsoleQueueLogger({this.enabled = true});
  @override
  void log(String message) {
    if (enabled) {
      // ignore: avoid_print
      print(message);
    }
  }
}
