# ProGuard / R8 rules for Project Toji
-keep class es.antonborri.home_widget.** { *; }
-dontwarn es.antonborri.home_widget.**
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**
-keep class com.kavya.project_toji.** { *; }
-keepclassmembers class com.kavya.project_toji.** { *; }
-keep class io.flutter.app.** { *; }
-dontwarn io.flutter.app.**
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.plugin.**
-keep class io.flutter.util.** { *; }
-dontwarn io.flutter.util.**
-keep class io.flutter.view.** { *; }
-dontwarn io.flutter.view.**
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Play Core deferred components suppression
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
