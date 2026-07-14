import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'realtime_transport.dart';

/// Production implementation of [RealtimeChannel] backed by a real
/// WebSocket. Not used while `AppConfig.useMockData` is true — wire it
/// in by overriding the relevant provider (see `chat_provider.dart`)
/// once a real chat endpoint exists. Decodes/encodes newline-delimited
/// JSON frames into `T` via the provided [decode]/[encode] functions.
class WebSocketRealtimeChannel<T> implements RealtimeChannel<T> {
  WebSocketRealtimeChannel({
    required this.url,
    required this.decode,
    required this.encode,
  });

  final String url;
  final T Function(Map<String, dynamic> json) decode;
  final Map<String, dynamic> Function(T event) encode;

  WebSocketChannel? _channel;
  final _controller = StreamController<T>.broadcast();
  StreamSubscription? _sub;

  @override
  Stream<T> get events => _controller.stream;

  @override
  bool get isConnected => _channel != null;

  @override
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _sub = _channel!.stream.listen(
      (raw) {
        try {
          final json = jsonDecode(raw as String) as Map<String, dynamic>;
          _controller.add(decode(json));
        } catch (_) {
          // Malformed frame — drop it rather than crash the channel.
        }
      },
      onError: (_) {},
      onDone: () => _channel = null,
    );
  }

  @override
  Future<void> disconnect() async {
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  @override
  void send(T event) {
    _channel?.sink.add(jsonEncode(encode(event)));
  }
}
