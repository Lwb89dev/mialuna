import 'event.dart';

/// NIP-01 subscription filter.
class NostrFilter {
  final List<String>? ids;
  final List<String>? authors;
  final List<int>? kinds;
  final Map<String, List<String>>? tagFilters; // e.g. {'#t': ['mialuna']}
  final int? since;
  final int? until;
  final int? limit;
  final String? search; // NIP-50

  const NostrFilter({
    this.ids,
    this.authors,
    this.kinds,
    this.tagFilters,
    this.since,
    this.until,
    this.limit,
    this.search,
  });

  NostrFilter copyWith({
    List<String>? ids,
    List<String>? authors,
    List<int>? kinds,
    Map<String, List<String>>? tagFilters,
    int? since,
    int? until,
    int? limit,
    String? search,
  }) => NostrFilter(
    ids: ids ?? this.ids,
    authors: authors ?? this.authors,
    kinds: kinds ?? this.kinds,
    tagFilters: tagFilters ?? this.tagFilters,
    since: since ?? this.since,
    until: until ?? this.until,
    limit: limit ?? this.limit,
    search: search ?? this.search,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ids != null) map['ids'] = ids;
    if (authors != null) map['authors'] = authors;
    if (kinds != null) map['kinds'] = kinds;
    tagFilters?.forEach((k, v) => map[k] = v);
    if (since != null) map['since'] = since;
    if (until != null) map['until'] = until;
    if (limit != null) map['limit'] = limit;
    if (search != null) map['search'] = search;
    return map;
  }

  /// Client-side check mirroring what a relay does. `limit` and `search` are
  /// relay-side only and ignored here.
  bool matches(NostrEvent e) {
    if (ids != null && !ids!.contains(e.id)) return false;
    if (authors != null && !authors!.contains(e.pubkey)) return false;
    if (kinds != null && !kinds!.contains(e.kind)) return false;
    if (since != null && e.createdAt < since!) return false;
    if (until != null && e.createdAt > until!) return false;
    if (tagFilters != null) {
      for (final entry in tagFilters!.entries) {
        final name = entry.key.substring(1); // strip '#'
        final values = e.tags
            .where((t) => t.isNotEmpty && t[0] == name)
            .map((t) => t.length > 1 ? t[1] : '')
            .toSet();
        if (!entry.value.any(values.contains)) return false;
      }
    }
    return true;
  }
}
