import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Force Java 11 for all Android modules
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_11.toString()
        targetCompatibility = JavaVersion.VERSION_11.toString()
    }
    
    // Force Kotlin 11 for all Kotlin compilation tasks
    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions { jvmTarget = "11" }
    }
    
    // Enforce compileSdk for all plugins (covers isar_flutter_libs)
    afterEvaluate {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                compileSdk = 35
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
