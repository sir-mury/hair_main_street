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

# Keep Retrofit core classes
-keep interface retrofit2.Call
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# Optional: keep annotations used by Retrofit (e.g. @POST, @GET)
-keepattributes Signature
-keepattributes *Annotation*

-keep class com.squareup.retrofit2.** { *; }
-keep interface com.squareup.retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

-keep class com.paystack.android.core.api.** { *; }
-keep interface com.paystack.android.core.api.** { *; }
-keep class com.paystack.android.core.api.models.** {*;}
-keepattributes Signature
-keepattributes *Annotation*

-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.**

-keepattributes SourceFile,LineNumberTable
# # ========== DEBUGGING RULES (Remove in production) ==========
# # Uncomment these for debugging ProGuard issues
#-printmapping mapping.txt
#-dontobfuscate
# -verbose
# -dontshrink
# -dontoptimize