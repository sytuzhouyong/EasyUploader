
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class NativeImage extends ImageProvider<NativeImage> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const NativeImage(this.url, { this.scale = 1.0 })
      : assert(url != null),
        assert(scale != null);

  final String url;
  final double scale;

  @override
  Future<NativeImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NativeImage>(this);
  }

  @override
  ImageStreamCompleter load(NativeImage key) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<NativeImage>('Image key', key),
        ];
      },
    );
  }

  static final MethodChannel _sharedMethodChannel = MethodChannel('channel.method.native_image');

  static MethodChannel get _methodChannel {
    MethodChannel client = _sharedMethodChannel;
    return client;
  }

  Future<ui.Codec> _loadAsync(
      NativeImage key,
      StreamController<ImageChunkEvent> chunkEvents,
      ) async {
    try {
      assert(key == this);

      final Uint8List bytes = await _methodChannel.invokeMethod('getNativeImageBytes', url);
      print('getNativeImageBytes length: ${bytes.length}');
      if (bytes.lengthInBytes == 0)
        throw Exception('NativeImage is an empty file: $url');

      chunkEvents.add(ImageChunkEvent(cumulativeBytesLoaded: bytes.length, expectedTotalBytes: bytes.length));

      return PaintingBinding.instance.instantiateImageCodec(bytes);
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType)
      return false;
    final NativeImage typedOther = other;
    return url == typedOther.url
        && scale == typedOther.scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}