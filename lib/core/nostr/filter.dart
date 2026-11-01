/// NIP-01 subscription filter.
class NostrFilter {
  final List<String>? ids;
  final List<String>? authors;
  final List<int>? kinds;
  final Map<String, List<String>>? tagFilters; // e.g. {'#t': ['mialuna']}
  final int? since;
  final int? until;
  final int? limit;

  const NostrFilter({
    this.ids,
    this.authors,
    this.kinds,
    this.tagFilters,
    this.since,
    this.until,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (ids != null) map['ids'] = ids;
    if (authors != null) map['authors'] = authors;
    if (kinds != null) map['kinds'] = kinds;
    tagFilters?.forEach((k, v) => map[k] = v);
    if (since != null) map['since'] = since;
    if (until != null) map['until'] = until;
    if (limit != null) map['limit'] = limit;
    return map;
  }

  bool matches(dynamic event) {
    final e = event as dynamic;
    if (ids != null && !ids!.contains(e.id as String)) return false;
    if (authors != null && !authors!.contains(e.pubkey as String)) return false;
    if (kinds != null && !kinds!.contains(e.kind as int)) return false;
    if (since != null && (e.createdAt as int) < since!) return false;
    if (until != null && (e.createdAt as int) > until!) return false;
    if (tagFilters != null) {
      for (final entry in tagFilters!.entries) {
        final name = entry.key.substring(1); // strip '#'
        final values = (e.tags as List<List<String>>)
            .where((t) => t.isNotEmpty && t[0] == name)
            .map((t) => t.length > 1 ? t[1] : '')
            .toSet();
        if (!entry.value.any(values.contains)) return false;
      }
    }
    return true;
  }
}
