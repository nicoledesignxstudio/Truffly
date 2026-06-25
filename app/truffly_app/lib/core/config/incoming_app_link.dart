Uri? normalizeIncomingAppLink(Uri uri) {
  if (uri.scheme != 'truffly') return null;
  if (uri.host != 'auth') return null;

  final path = uri.path.trim();
  if (path != '/reset-password' && path != '/verify-email') {
    return null;
  }

  return Uri(
    path: path,
    queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    fragment: uri.fragment.trim().isEmpty ? null : uri.fragment,
  );
}
