import 'dart:typed_data';

/// Stub for non-web platforms.
void downloadBytes(String filename, Uint8List bytes, String mime) {
  throw UnsupportedError('File download is only supported on Flutter Web.');
}
