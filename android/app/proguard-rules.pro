# Keep Play Core classes
-keep class com.google.android.play.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.assetpacks.** { *; }

# Keep Flutter-related classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Flutter default rules (if not already present)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
# Add any project-specific rules below
# Example: Keep model classes if using JSON serialization
# -keep class com.your.package.model.** { *; }