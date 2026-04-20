// このファイルは android/app/build.gradle.kts です。
// ユーザー提供のファイル形式に合わせてKotlin DSLで記述しています。

import java.util.Properties
import java.io.FileInputStream

// --- ここからが修正箇所です ---
// local.propertiesからFlutterのビルド設定を読み込みます。
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

// compileSdkのバージョンを35に更新しました。
val flutterCompileSdk = localProperties.getProperty("flutter.compileSdkVersion")?.toInt() ?: 35
val flutterMinSdk = localProperties.getProperty("flutter.minSdkVersion")?.toInt() ?: 23
val flutterTargetSdk = localProperties.getProperty("flutter.targetSdkVersion")?.toInt() ?: 35
val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
// --- ここまでが修正箇所です ---

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// --- 修正箇所: この行は不要になったため削除しました ---
// val flutter: groovy.util.ConfigObject by extra

android {
    namespace = "com.ryosuke.oshikatu"
    // --- 修正箇所: local.propertiesから読み込んだ値を使用します ---
    compileSdk = flutterCompileSdk
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Java 8+ API desugaringを有効にします。
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // リリース署名のための設定
    signingConfigs {
        create("release") {
            val keyProperties = Properties()
            val keyPropertiesFile = rootProject.file("key.properties")
            if (keyPropertiesFile.exists()) {
                keyProperties.load(FileInputStream(keyPropertiesFile))
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.ryosuke.oshikatu"
        // --- 修正箇所: local.propertiesから読み込んだ値を使用します ---
        minSdk = flutterMinSdk
        targetSdk = flutterTargetSdk
        versionCode = flutterVersionCode
        versionName = flutterVersionName

        // MultiDexを有効にします。
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // リリースビルドに上記で作成した署名設定を使用
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // coreLibraryDesugaringを有効にするために、以下の行を追加します。
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
