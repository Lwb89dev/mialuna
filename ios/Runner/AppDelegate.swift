import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerMediaChannel(engineBridge)
  }

  /// Video frame extraction (cover images) with AVFoundation. Mirrors the
  /// Android `MediaBridge`. NOTE: not compiled in CI yet — see
  /// docs/release.md ("iOS validation").
  private func registerMediaChannel(_ engineBridge: FlutterImplicitEngineBridge) {
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MialunaMedia") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "app.mialuna.social/media",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "videoThumbnail",
        let args = call.arguments as? [String: Any],
        let source = args["source"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      let maxWidth = args["maxWidth"] as? Int ?? 720
      let timeMs = (args["timeMs"] as? NSNumber)?.int64Value ?? 500
      DispatchQueue.global(qos: .userInitiated).async {
        let url: URL? = source.hasPrefix("http") ? URL(string: source) : URL(fileURLWithPath: source)
        guard let url = url else {
          DispatchQueue.main.async { result(FlutterError(code: "ARGS", message: "bad source", details: nil)) }
          return
        }
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: maxWidth, height: maxWidth * 4)
        generator.requestedTimeToleranceBefore = .positiveInfinity
        generator.requestedTimeToleranceAfter = .positiveInfinity
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let durationMs = durationSeconds.isFinite ? Int(durationSeconds * 1000) : 0
        let at = (durationMs > 0 && Int64(durationMs) <= timeMs) ? 0 : timeMs
        do {
          let cgImage = try generator.copyCGImage(
            at: CMTime(value: at, timescale: 1000), actualTime: nil)
          guard let data = UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.82) else {
            throw NSError(domain: "mialuna", code: 1)
          }
          DispatchQueue.main.async {
            result([
              "bytes": FlutterStandardTypedData(bytes: data),
              "width": cgImage.width,
              "height": cgImage.height,
              "durationMs": durationMs,
            ])
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "THUMB", message: error.localizedDescription, details: nil))
          }
        }
      }
    }
  }
}
