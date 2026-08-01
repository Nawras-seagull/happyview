import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
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
        targetSdk = 36
        versionCode = 20
        versionName = "1.0.5"
    }

    signingConfigs {
        create("release") {
            storePassword = keystoreProperties.getProperty("storePassword") ?: ""
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: ""
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: "happyview"
            storeFile = rootProject.file(keystoreProperties.getProperty("storeFile") ?: "")
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