/// A transport-agnostic real-time channel. The UI/providers only ever
/// see a `Stream<T>` of decoded events — never raw socket frames — so
/// swapping [FakeRealtimeChannel] (used in the dev/mock flavor) for a
/// real `WebSocketChannel`-backed implementation later requires no
/// changes above this interface.
abstract interface class RealtimeChannel<T> {
  Stream<T> get events;
  void send(T event);
  Future<void> connect();
  Future<void> disconnect();
  bool get isConnected;
}
