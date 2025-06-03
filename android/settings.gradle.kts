pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

include(":app")

val flutterSdkPath = gradle.startParameter.projectProperties.get("flutter.sdk")
    ?: throw GradleException("flutter.sdk not set in gradle.properties")

apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
