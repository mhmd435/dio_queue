## 0.1.4

- Fix pubspec.yaml description field

## 0.1.3

- Surface a clearer error when Hive hasn't been initialized before using
  `HiveQueueStorage` and document the requirement.
- Initialize Hive in the example and expand documentation for `HiveQueueStorage`.

## 0.1.2

- Allow `QueueJob.toJson` to handle `FormData` bodies by omitting them instead of throwing.

## 0.1.1

- Avoid serializing `FormData` bodies and skip persistence when present.
- Document `MultipartFile` usage for web and IO.

## 0.1.0

- Initial release.
