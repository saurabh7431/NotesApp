import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("Warning: key.properties file not found at: ${keystorePropertiesFile.path}")
}

android {
    namespace = "com.example.notesapp"
    compileSdk = 36  // Ya flutter.compileSdkVersion agar aapne define kiya hai

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.notesapp"
        minSdk = flutter.minSdkVersion  // Ya flutter.minSdkVersion agar define hai
        targetSdk = 33 // Ya flutter.targetSdkVersion agar define hai
        versionCode = 1 // Ya flutter.versionCode
        versionName = "1.0" // Ya flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Check karen ki sab keys null nahi hain
            val storeFilePath = keystoreProperties["storeFile"] as? String
            val storePassword = keystoreProperties["storePassword"] as? String
            val keyAlias = keystoreProperties["keyAlias"] as? String
            val keyPassword = keystoreProperties["keyPassword"] as? String

            if (storeFilePath == null || storePassword == null || keyAlias == null || keyPassword == null) {
                throw GradleException("Keystore properties not found or incomplete in key.properties")
            }

            storeFile = file(storeFilePath)
            this.storePassword = storePassword
            this.keyAlias = keyAlias
            this.keyPassword = keyPassword
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
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
