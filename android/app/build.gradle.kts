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
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nawras.happyview"
        minSdk = 24
        targetSdk = 35
        versionCode = 18
        versionName = "1.0.3"
    }

    signingConfigs {
        create("release") {
            storePassword = "201141"
            keyPassword = "201141"
            keyAlias = "happyview"
            storeFile = file("/Users/nawrasalabbas/Desktop/happyview-keystore.jks")
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Uncomment if you need Play Core services
    // implementation("com.google.android.play:core:1.10.3")
    // implementation("com.google.android.play:core-ktx:1.8.1")
}