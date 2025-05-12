plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nawras.happyview"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nawras.happyview"
   //     minSdkVersion(23) // Parentheses are required in Kotlin DSL
     //   targetSdkVersion(34)
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
       // minSdk = flutter.minSdkVersion
       // targetSdk = flutter.targetSdkVersion
        versionCode = 11
        versionName = "3.0.3"
        minSdk=23
        targetSdk=34
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false     // Kotlin uses "isMinifyEnabled" instead of "minifyEnabled"
            isShrinkResources = false   // Kotlin uses "isShrinkResources" instead of "shrinkResources"
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

/* dependencies {
    implementation("com.google.android.play:core:2.0.3") {
        exclude(group = "com.google.android.play", module = "core-common")
    }
    implementation("com.google.android.play:core-ktx:2.0.3") {
        exclude(group = "com.google.android.play", module = "core-common")
    }
} */
