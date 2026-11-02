import 'package:flutter/material.dart';

import 'explore_screen.dart';

/// Opens the Discover search for `#[tag]` on top of the current screen. This
/// is what tapping a hashtag does anywhere in the app.
Future<void> openHashtagSearch(BuildContext context, String tag) =>
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExploreScreen(initialQuery: '#$tag')),
    );
