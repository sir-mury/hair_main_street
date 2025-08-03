# Keep Kotlin Parcelize
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
-keepnames class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Monnify SDK classes
-keep class com.teamapt.monnify.sdk.** { *; }
-keepclassmembers class com.teamapt.monnify.sdk.** { *; }

# Kotlin serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Kotlin general
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# ========== FLUTTER CORE RULES ==========
# Keep all Flutter classes and interfaces
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }

# Keep Flutter plugin registrants
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# Keep method channels and their handlers
-keep class * implements io.flutter.plugin.common.MethodCallHandler { *; }
-keep class * implements io.flutter.plugin.common.EventChannel$StreamHandler { *; }
-keep class * implements io.flutter.plugin.common.BinaryMessenger { *; }

# Keep all method channel related classes and methods
-keep class io.flutter.plugin.common.** { *; }
-keepclassmembers class * {
    @io.flutter.plugin.common.* <methods>;
}

# ========== PAYMENT SDK RULES ==========
# Keep Paystack SDK - More comprehensive rules
-keep class co.paystack.** { *; }
-keep interface co.paystack.** { *; }
-keepclassmembers class co.paystack.** { *; }
-dontwarn co.paystack.**

# Keep all classes with "Transaction" in the name
-keep class **Transaction** { *; }
-keep class **TransactionApi** { *; }
-keep class **TransactionApi$** { *; }
-keep interface **Transaction** { *; }
-keep interface **TransactionApi** { *; }
-keepclassmembers class **Transaction** { *; }
-keepclassmembers class **TransactionApi** { *; }

# Keep all classes with "Payment" in the name
-keep class **Payment** { *; }
-keep interface **Payment** { *; }
-keepclassmembers class **Payment** { *; }

# Keep all classes with "Verify" in the name
-keep class **Verify** { *; }
-keep interface **Verify** { *; }
-keepclassmembers class **Verify** { *; }

# ========== FLUTTER PLUGIN SPECIFIC RULES ==========
# Keep all plugin classes (broader approach)
-keep class plugins.flutter.** { *; }
-keep class com.flutter.** { *; }
-keep class dev.flutter.** { *; }

# Keep all classes that might be called via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# ========== RETROFIT & NETWORKING ==========
-keep class com.squareup.retrofit2.** { *; }
-keep interface com.squareup.retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

-keep class io.reactivex.** { *; }
-keep interface io.reactivex.** { *; }

# ========== FIREBASE ==========
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ========== GENERAL RULES FOR METHOD CHANNELS ==========
# Keep all classes that might be accessed via method channels
-keep public class * {
    public protected *;
}

# Keep all public methods that might be called from Flutter
-keepclassmembers class * {
    public <methods>;
}

# Keep all classes with specific annotations
-keep @interface * { *; }
-keep class * {
    @* <fields>;
    @* <methods>;
}

# ========== DEBUGGING RULES (Remove in production) ==========
# Uncomment these for debugging ProGuard issues
# -printmapping mapping.txt
# -verbose
# -dontshrink
# -dontoptimize

# Keep source file names and line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep generic signatures for better debugging
-keepattributes Signature

-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.squareup.okhttp.CipherSuite
-dontwarn com.squareup.okhttp.ConnectionSpec
-dontwarn com.squareup.okhttp.TlsVersion
-dontwarn java.lang.reflect.AnnotatedType