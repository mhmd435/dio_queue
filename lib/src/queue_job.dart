import 'dart:convert';

import 'queue_config.dart';

/// Model representing an enqueued request.
class QueueJob {
  final String id;
  final String method;
  final String url;
  final Map<String, dynamic>? headers;
  final dynamic body;
  final Map<String, dynamic>? query;
  final String? idempotencyKey;
  final Set<String> tags;
  final int priority;
  final Duration? timeout;

  JobState state;
  int attempts;
  DateTime enqueuedAt;
  DateTime? startedAt;
  DateTime? finishedAt;
  Object? lastError;

  QueueJob({
    required this.id,
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.query,
    this.idempotencyKey,
    this.tags = const {},
    this.priority = 0,
    this.timeout,
    this.state = JobState.enqueued,
    this.attempts = 0,
    DateTime? enqueuedAt,
    this.startedAt,
    this.finishedAt,
    this.lastError,
  }) : enqueuedAt = enqueuedAt ?? DateTime.now();

  /// Fingerprint used for deduplication.
  String get fingerprint {
    if (idempotencyKey != null) return idempotencyKey!;
    final payload = jsonEncode({
      'm': method,
      'u': url,
      'h': headers,
      'b': body,
      'q': query,
    });
    return base64Url.encode(utf8.encode(payload));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'url': url,
        'headers': headers,
        'body': body,
        'query': query,
        'idempotencyKey': idempotencyKey,
        'tags': tags.toList(),
        'priority': priority,
        'timeout': timeout?.inMilliseconds,
        'state': state.index,
        'attempts': attempts,
        'enqueuedAt': enqueuedAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
        'lastError': lastError?.toString(),
      };

  static QueueJob fromJson(Map<String, dynamic> json) => QueueJob(
        id: json['id'] as String,
        method: json['method'] as String,
        url: json['url'] as String,
        headers: (json['headers'] as Map?)?.cast<String, dynamic>(),
        body: json['body'],
        query: (json['query'] as Map?)?.cast<String, dynamic>(),
        idempotencyKey: json['idempotencyKey'] as String?,
        tags: Set<String>.from(json['tags'] as List? ?? []),
        priority: json['priority'] as int? ?? 0,
        timeout: json['timeout'] != null
            ? Duration(milliseconds: json['timeout'] as int)
            : null,
        state: JobState.values[json['state'] as int? ?? 0],
        attempts: json['attempts'] as int? ?? 0,
        enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        finishedAt: json['finishedAt'] != null
            ? DateTime.parse(json['finishedAt'] as String)
            : null,
        lastError: json['lastError'],
      );
}
