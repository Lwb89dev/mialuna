import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'event.dart';
import 'filter.dart';

enum RelayConnectionState { disconnected, connecting, connected, failed }

typedef RelayMessageHandler = void Function(
  String subscriptionId,
  NostrEvent event,
);
typedef RelayEoseHandler = void Function(String subscriptionId);

/// A single relay WebSocket connection with automatic reconnect and
/// exponential backoff.
class Relay {
  final String url;
  final void Function(RelayConnectionState state)? onStateChanged;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  RelayConnectionState _state = RelayConnectionState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _disposed = false;

  final Map<String, List<NostrFilter>> _activeSubscriptions = {};
  RelayMessageHandler? onEvent;
  RelayEoseHandler? onEose;
  void Function(String eventId, bool ok, String message)? onPublishResult;

  Relay(this.url, {this.onStateChanged});

  RelayConnectionState get state => _state;
  bool get isConnected => _state == RelayConnectionState.connected;

  Future<void> connect() async {
    if (_disposed || isConnected) return;
    _setState(RelayConnectionState.connecting);
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;
      _setState(RelayConnectionState.connected);
      _reconnectAttempts = 0;
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (_) => _handleDisconnect(),
        onDone: _handleDisconnect,
      );
      // Restore subscriptions after reconnect.
      _activeSubscriptions.forEach((id, filters) {
        _send(['REQ', id, ...filters.map((f) => f.toJson())]);
      });
    } catch (_) {
      _setState(RelayConnectionState.failed);
      _scheduleReconnect();
    }
  }

  void subscribe(String subscriptionId, List<NostrFilter> filters) {
    _activeSubscriptions[subscriptionId] = filters;
    if (isConnected) {
      _send(['REQ', subscriptionId, ...filters.map((f) => f.toJson())]);
    } else {
      connect();
    }
  }

  void unsubscribe(String subscriptionId) {
    _activeSubscriptions.remove(subscriptionId);
    if (isConnected) _send(['CLOSE', subscriptionId]);
  }

  void publish(NostrEvent event) {
    if (!isConnected) {
      connect();
      onPublishResult?.call(event.id, false, 'relay not connected');
      return;
    }
    _send(['EVENT', event.toJson()]);
  }

  void _handleMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as List;
      switch (msg[0]) {
        case 'EVENT':
          final subId = msg[1] as String;
          final event = NostrEvent.fromJson(msg[2] as Map<String, dynamic>);
          onEvent?.call(subId, event);
        case 'EOSE':
          onEose?.call(msg[1] as String);
        case 'OK':
          onPublishResult?.call(
            msg[1] as String,
            msg[2] as bool,
            msg.length > 3 ? msg[3] as String : '',
          );
        case 'NOTICE':
          break; // surfaced via logs in a future iteration
      }
    } catch (_) {
      // Malformed relay message: ignore.
    }
  }

  void _send(List<dynamic> payload) {
    try {
      _channel?.sink.add(jsonEncode(payload));
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_disposed) return;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _setState(RelayConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    final delay = Duration(seconds: (1 << _reconnectAttempts.clamp(0, 6)));
    _reconnectAttempts++;
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      connect();
    });
  }

  void _setState(RelayConnectionState s) {
    _state = s;
    onStateChanged?.call(s);
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
  }
}
