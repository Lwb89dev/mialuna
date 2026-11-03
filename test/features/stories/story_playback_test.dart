import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/features/stories/story_playback.dart';

const _tick = Duration(milliseconds: 50);

/// Runs [playback] for [total], in 50 ms ticks, and reports whether it
/// counted and whether it ended at any point.
({bool counted, bool done, Duration at}) run(
  StoryPlayback playback,
  Duration total, {
  Duration Function(Duration elapsed)? position,
  bool Function(Duration elapsed)? playing,
  bool Function(Duration elapsed)? buffering,
}) {
  var elapsed = Duration.zero;
  var counted = false;
  var done = false;
  while (elapsed < total && !done) {
    elapsed += _tick;
    final step = playback.advance(
      _tick,
      position: position?.call(elapsed) ?? Duration.zero,
      playing: playing?.call(elapsed) ?? true,
      buffering: buffering?.call(elapsed) ?? false,
    );
    counted |= step.count;
    done |= step.done;
  }
  return (counted: counted, done: done, at: elapsed);
}

void main() {
  group('a picture', () {
    test('is not watched until it is on screen', () {
      final p = StoryPlayback();
      final r = run(p, const Duration(seconds: 10));
      expect(r.counted, false);
      expect(r.done, false, reason: 'a picture that never loads never ends');
      expect(p.progress, 0);
    });

    test('counts after a second on screen, and ends after five', () {
      final p = StoryPlayback()..pictureShown();
      final soon = run(p, const Duration(milliseconds: 950));
      expect(soon.counted, false);
      final next = run(p, const Duration(milliseconds: 100));
      expect(next.counted, true);
      expect(p.isCounted, true);

      final rest = run(p, const Duration(seconds: 10));
      expect(rest.done, true);
      expect(p.progress, 1);
    });

    test('a failed picture is never watched', () {
      final p = StoryPlayback()..mediaFailed();
      final r = run(p, const Duration(seconds: 10));
      expect(r.counted, false);
      expect(r.done, false);
      expect(p.hasFailed, true);
    });

    test('swiping past it at once is not a view', () {
      final p = StoryPlayback()..pictureShown();
      expect(run(p, const Duration(milliseconds: 400)).counted, false);
      p.reset(); // the next story
      expect(p.isCounted, false);
      expect(p.shown, Duration.zero);
    });

    test('a pause stops the clock and the count', () {
      final p = StoryPlayback()..pictureShown();
      p.paused = true;
      final held = run(p, const Duration(seconds: 3));
      expect(held.counted, false);
      expect(p.progress, 0);

      p.paused = false;
      expect(run(p, const Duration(milliseconds: 1100)).counted, true);
      expect(p.progress, closeTo(0.22, 0.02));
    });

    test('the app in the background is not a view either', () {
      final p = StoryPlayback()..pictureShown();
      p.inBackground = true;
      expect(run(p, const Duration(seconds: 6)).counted, false);
      p.inBackground = false;
      expect(run(p, const Duration(milliseconds: 950)).counted, false);
      expect(run(p, const Duration(milliseconds: 100)).counted, true);
    });

    test('is counted once, however long it stays', () {
      final p = StoryPlayback()..pictureShown();
      var counts = 0;
      for (var i = 0; i < 200; i++) {
        if (p.advance(_tick).count) counts++;
      }
      expect(counts, 1);
    });
  });

  group('a video', () {
    const length = Duration(seconds: 8);

    test('is not watched while it is only loading', () {
      final p = StoryPlayback();
      expect(run(p, const Duration(seconds: 5)).counted, false);
    });

    test('counts after a second of real playback', () {
      final p = StoryPlayback()..videoShown(length);
      final r = run(p, const Duration(seconds: 2), position: (t) => t);
      expect(r.counted, true);
      expect(p.progress, closeTo(0.25, 0.01));
    });

    test('buffering is not watching', () {
      final p = StoryPlayback()..videoShown(length);
      final stalled = run(
        p,
        const Duration(seconds: 4),
        buffering: (_) => true,
        position: (_) => Duration.zero,
      );
      expect(stalled.counted, false);
      expect(p.progress, 0, reason: 'the bar follows the playback');
    });

    test('a video that did not start playing is not watched', () {
      final p = StoryPlayback()..videoShown(length);
      final r = run(p, const Duration(seconds: 4), playing: (_) => false);
      expect(r.counted, false);
    });

    test('pausing does not advance it', () {
      final p = StoryPlayback()..videoShown(length);
      run(p, const Duration(milliseconds: 500), position: (t) => t);
      p.paused = true;
      final held = run(
        p,
        const Duration(seconds: 3),
        position: (_) => const Duration(milliseconds: 500),
      );
      expect(held.counted, false);
      expect(p.progress, closeTo(0.0625, 0.01));
    });

    test('ends when the playback ends, not when a timer says so', () {
      final p = StoryPlayback()..videoShown(length);
      // Plays at half speed (a slow connection): 16 s of the clock.
      final r = run(p, const Duration(seconds: 30), position: (t) => t * 0.5);
      expect(r.done, true);
      expect(r.at, greaterThanOrEqualTo(const Duration(seconds: 16)));
    });

    test('ends when the player says it completed', () {
      final p = StoryPlayback()..videoShown(length);
      final step = p.advance(
        _tick,
        position: const Duration(seconds: 3),
        completed: true,
      );
      expect(step.done, true);
    });

    test('a video shorter than a second still counts, if it played', () {
      final p = StoryPlayback()..videoShown(const Duration(milliseconds: 600));
      final r = run(
        p,
        const Duration(seconds: 2),
        position: (t) => t > const Duration(milliseconds: 600)
            ? const Duration(milliseconds: 600)
            : t,
      );
      expect(r.counted, true);
      expect(r.done, true);
    });

    test('a failed video is never watched', () {
      final p = StoryPlayback()
        ..videoShown(length)
        ..mediaFailed();
      expect(run(p, const Duration(seconds: 5)).counted, false);
    });
  });
}
