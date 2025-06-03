android {
    namespace = "com.example.flutter_application_manachyna_kusa_2_0"
    compileSdk = 34  // Cambia esto de flutter.compileSdkVersion a 34
    ndkVersion = "27.0.12077973"  // Reemplaza flutter.ndkVersion con el valor específico

    // ... resto del código sin cambios ...

    defaultConfig {
        applicationId = "com.example.flutter_application_manachyna_kusa_2_0"
        minSdk = 23  // Cambia esto de flutter.minSdkVersion a 23
        targetSdk = 34  // Cambia esto de flutter.targetSdkVersion a 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ... resto del código sin cambios ...
}