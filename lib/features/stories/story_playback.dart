/// What one story on screen has been through: whether its media is really
/// there, how far along it is, and whether it has been watched.
///
/// Choosing a story is not watching it. A story counts as watched — marked
/// seen on the phone, reported to its author — once its media has been
/// *showing* for [countAfter], not paused, not behind a sheet, not in the
/// background and (for a video) actually playing, not buffering. A picture
/// that never loads, a video that fails to start, a swipe past it: none of
/// those is a view.
///
/// The widget owns the timer and the media; it tells this class what it sees
/// and does what it answers. Time only ever comes in through [advance], so
/// the rules are testable without a clock.
class StoryPlayback {
  /// How long a picture stays.
  final Duration photoDuration;

  /// How long the media must really have been showing to count.
  final Duration countAfter;

  StoryPlayback({
    this.photoDuration = const Duration(seconds: 5),
    this.countAfter = const Duration(seconds: 1),
  });

  bool _ready = false;
  bool _failed = false;
  bool _counted = false;
  Duration? _videoLength;
  Duration _shown = Duration.zero;
  double _progress = 0;

  /// The user is holding the story (long press, a sheet is open).
  bool paused = false;

  /// The app is not in the foreground.
  bool inBackground = false;

  /// 0 to 1, for the bar at the top.
  double get progress => _progress;

  /// The media is on screen.
  bool get isReady => _ready;

  /// The media could not be shown.
  bool get hasFailed => _failed;

  /// Already counted as watched.
  bool get isCounted => _counted;

  /// How long it has really been showing.
  Duration get shown => _shown;

  /// A new story begins: nothing carries over from the last one.
  void reset() {
    _ready = false;
    _failed = false;
    _counted = false;
    _videoLength = null;
    _shown = Duration.zero;
    _progress = 0;
  }

  /// The picture is decoded and on screen.
  void pictureShown() {
    _videoLength = null;
    _ready = true;
  }

  /// The video is initialised and can play; [length] is its duration.
  void videoShown(Duration length) {
    _videoLength = length;
    _ready = true;
  }

  /// The media will not show (download or decoding failed, the player
  /// refused it).
  void mediaFailed() {
    _ready = false;
    _failed = true;
  }

  /// [elapsed] time has passed. For a video, say what the player reports.
  ///
  /// Returns whether the story has just become watched ([PlaybackStep.count])
  /// and whether it is over ([PlaybackStep.done]).
  PlaybackStep advance(
    Duration elapsed, {
    Duration position = Duration.zero,
    bool playing = true,
    bool buffering = false,
    bool completed = false,
  }) {
    if (!_ready || _failed) return PlaybackStep.none;
    final length = _videoLength;
    final isVideo = length != null && length > Duration.zero;
    final holding = paused || inBackground;
    // A picture shows as long as it is not held; a video, as long as it is
    // really playing.
    final showing = !holding && (!isVideo || (playing && !buffering));
    if (showing) _shown += elapsed;

    final span = isVideo ? length : photoDuration;
    final threshold = countAfter < span ? countAfter : span;
    final count = !_counted && _shown >= threshold;
    if (count) _counted = true;

    final bool done;
    if (isVideo) {
      _progress = (position.inMilliseconds / length.inMilliseconds).clamp(
        0.0,
        1.0,
      );
      done = completed || position >= length;
    } else {
      _progress = (_shown.inMilliseconds / photoDuration.inMilliseconds).clamp(
        0.0,
        1.0,
      );
      done = _shown >= photoDuration;
    }
    return PlaybackStep(count: count, done: done);
  }
}

/// What [StoryPlayback.advance] found.
class PlaybackStep {
  /// The story has just been watched long enough to count.
  final bool count;

  /// The story is over: move on.
  final bool done;
  const PlaybackStep({required this.count, required this.done});

  static const none = PlaybackStep(count: false, done: false);
}
