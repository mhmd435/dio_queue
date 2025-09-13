/// Data model representing a request scheduled for later execution.
import 'dart:convert';

import 'package:dio/dio.dart';

import 'queue_config.dart';
import 'http_method.dart';

/// Model representing an enqueued request.
class QueueJob {
  /// Unique identifier for the job.
  final String id;

  /// HTTP method to execute.
  final HttpMethod method;

  /// Target URL path.
  final String url;

  /// Optional request headers.
  final Map<String, dynamic>? headers;

  /// Request payload body.
  final dynamic body;

  /// Query parameters to append to the URL.
  final Map<String, dynamic>? query;

  /// Optional key used for deduplication across runs.
  final String? idempotencyKey;

  /// Arbitrary tags associated with the job.
  final Set<String> tags;

  /// Higher values are scheduled before lower ones.
  final int priority;

  /// Optional timeout applied to the request.
  final Duration? timeout;

  /// Current state of the job in the queue.
  JobState state;

  /// Number of attempts that have been made so far.
  int attempts;

  /// When the job was first enqueued.
  DateTime enqueuedAt;

  /// When execution started, if running.
  DateTime? startedAt;

  /// When execution finished, if completed.
  DateTime? finishedAt;

  /// Last error produced by the job, if any.
  Object? lastError;

  /// Whether this job represents the last request in a sequence.
  final bool isLastRequest;

  /// Creates a new [QueueJob].
  QueueJob({
    /// Identifier for this job.
    required this.id,

    /// HTTP method to use.
    required this.method,

    /// Endpoint URL path.
    required this.url,

    /// Optional request headers.
    this.headers,

    /// Request payload body.
    this.body,

    /// Query parameters for the request.
    this.query,

    /// Key used to deduplicate identical jobs.
    this.idempotencyKey,

    /// Tags associated with the job.
    this.tags = const {},

    /// Priority of the job; higher runs first.
    this.priority = 0,

    /// Request timeout.
    this.timeout,

    /// Initial state of the job.
    this.state = JobState.enqueued,

    /// Number of attempts already made.
    this.attempts = 0,

    /// Time the job was enqueued. Defaults to now.
    DateTime? enqueuedAt,

    /// When execution started.
    this.startedAt,

    /// When execution finished.
    this.finishedAt,

    /// Last error produced.
    this.lastError,

    /// Indicates if this is the last request in a batch.
    this.isLastRequest = false,
  }) : enqueuedAt = enqueuedAt ?? DateTime.now();

  /// Fingerprint used for deduplication.
  String get fingerprint {
    if (idempotencyKey != null) return idempotencyKey!;
    final payload = jsonEncode({
      'm': method.value,
      'u': url,
      'h': headers,
      // Use the object hash for FormData to avoid dedup collisions while
      // still producing a stable fingerprint for identical instances.
      'b': body is FormData ? body.hashCode : body,
      'q': query,
    });
    return base64Url.encode(utf8.encode(payload));
  }

  /// Serialises this job into a JSON compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method.value,
      'url': url,
      'headers': headers,
      // FormData cannot be JSON encoded; omit from serialization.
      'body': body is FormData ? null : body,
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
      'isLastRequest': isLastRequest,
    };
  }

  /// Creates a [QueueJob] from previously serialised JSON.
  static QueueJob fromJson(Map<String, dynamic> json) => QueueJob(
        id: json['id'] as String,
        method: HttpMethodX.fromString(json['method'] as String),
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
        isLastRequest: json['isLastRequest'] as bool? ?? false,
      );
}
