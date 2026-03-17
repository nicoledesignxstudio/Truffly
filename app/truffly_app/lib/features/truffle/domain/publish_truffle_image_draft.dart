final class PublishTruffleImageDraft {
  const PublishTruffleImageDraft({
    required this.localPath,
    required this.fileName,
    required this.contentType,
    required this.byteCount,
  });

  final String localPath;
  final String fileName;
  final String contentType;
  final int byteCount;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PublishTruffleImageDraft &&
            other.localPath == localPath &&
            other.fileName == fileName &&
            other.contentType == contentType &&
            other.byteCount == byteCount;
  }

  @override
  int get hashCode => Object.hash(localPath, fileName, contentType, byteCount);
}
