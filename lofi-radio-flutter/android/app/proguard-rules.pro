# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# audio_service
-keep class com.ryanheise.audioservice.** { *; }

# flutter_overlay_window
-keep class flutter.overlay.window.** { *; }

# ExoPlayer / Media3
-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Keep entry points
-keep class com.lofiradio.lofi_radio_flutter.** { *; }

# Play Core (referenced by Flutter deferred components, not used but needed for R8)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
