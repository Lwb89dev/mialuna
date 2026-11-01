import 'dart:async';

import 'event.dart';
import 'filter.dart';
import 'relay.dart';
import 'signer.dart';

class PublishReport {
  final String eventId;
  final Map<String, bool> relayResults; // url -> accepted
  const PublishReport(this.eventId, this.relayResults);

  int get acceptedCount => relayResults.values.where((ok) => ok).length;
  bool get publishedSomewhere => acceptedCount > 0;
}

/// Multi-relay pool: deduplicates events, manages subscription lifecycle,
/// verifies signatures, reports per-relay publish results.
class RelayPool {
  final List<String> relayUrls;
  final Map<String, Relay> _relays = {};
  final Set<String> _seenEventIds = {};
  final _eventController = StreamController<NostrEvent>.broadcast();
  int _subscriptionCounter = 0;

  /// When false (e.g. in tests), signatures are not verified.
  final bool verifySignatures;

  RelayPool(this.relayUrls, {this.verifySignatures = true}) {
    for (final url in relayUrls) {
      _relays[url] = Relay(url)
        ..onEvent = _handleEvent
        ..onPublishResult = _handlePublishResult;
    }
  }

  final _publishCompleters = <String, Map<String, Completer<void>>>{};
  final _publishResults = <String, Map<String, bool>>{};

  Stream<NostrEvent> get events => _eventController.stream;

  void connect() {
    for (final relay in _relays.values) {
      relay.connect();
    }
  }

  bool _handleEventSeen(String id) {
    if (_seenEventIds.contains(id)) return true;
    _seenEventIds.add(id);
    return false;
  }

  void _handleEvent(String subscriptionId, NostrEvent event) {
    if (_handleEventSeen(event.id)) return;
    if (event.isExpired()) return;
    if (verifySignatures && !verifyEventSignature(event)) return;
    _eventController.add(event);
  }

  void _handlePublishResult(String eventId, bool ok, String message) {
    // Relay url is resolved by matching pending completers.
    _publishResults[eventId]?.forEach((url, value) {
      if (!value && ok) _publishResults[eventId]![url] = true;
    });
    _publishCompleters[eventId]?.forEach((url, completer) {
      if (!completer.isCompleted) completer.complete();
    });
  }

  /// Subscribes on all relays. Returns a stream of deduplicated events
  /// matching the filters, plus the subscription id for unsubscribing.
  ({String id, Stream<NostrEvent> stream}) subscribe(
    List<NostrFilter> filters,
  ) {
    final id = 'mialuna-${_subscriptionCounter++}';
    final stream = _eventController.stream.where(
      (event) => filters.any((f) => f.matches(event)),
    );
    for (final relay in _relays.values) {
      relay.subscribe(id, filters);
    }
    return (id: id, stream: stream);
  }

  void unsubscribe(String id) {
    for (final relay in _relays.values) {
      relay.unsubscribe(id);
    }
  }

  /// Publishes to all relays and waits briefly for OK responses.
  /// A publication counts as successful when at least one relay accepts.
  Future<PublishReport> publish(
    NostrEvent event, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completers = <String, Completer<void>>{
      for (final url in _relays.keys) url: Completer<void>(),
    };
    _publishCompleters[event.id] = completers;
    _publishResults[event.id] = {for (final url in _relays.keys) url: false};

    for (final relay in _relays.values) {
      relay.publish(event);
    }

    await Future.wait(completers.values.map((c) => c.future))
        .timeout(timeout, onTimeout: () => []);

    final results = Map<String, bool>.from(_publishResults[event.id]!);
    _publishCompleters.remove(event.id);
    _publishResults.remove(event.id);
    return PublishReport(event.id, results);
  }

  Future<void> dispose() async {
    await _eventController.close();
    for (final relay in _relays.values) {
      await relay.dispose();
    }
  }
}
