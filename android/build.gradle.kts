// android/build.gradle.kts (archivo raíz del proyecto Android)

buildscript {
    // Puedes definir variables como la versión de Kotlin aquí si es necesario
    // ext.kotlin_version = "1.7.10" // Ejemplo, ajusta a tu proyecto

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Aquí van las dependencias del proceso de construcción (build process)
        // Asegúrate que las versiones sean compatibles con tu versión de Flutter/Gradle
        // Puedes encontrar las versiones correctas en un proyecto Flutter nuevo o en la documentación.
        // Por ejemplo:
        // classpath("com.android.tools.build:gradle:7.3.0") // Reemplaza con la versión de tu proyecto
        // classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:${ext.kotlin_version}") // Reemplaza con la versión de tu proyecto
        
        // Esta es la línea importante para Firebase:
        classpath("com.google.gms:google-services:4.4.1") // o la última versión compatible
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// El resto de tu archivo parece estar bien, lo mantendré como lo tenías:
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir) // Usar .set() para asignar

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir) // Usar .set() para asignar
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}