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
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Release builds run lint's fatal checks (lintVital) on every plugin too, and
// lint in AGP 9.3.1 crashes on url_launcher_android's Javadoc
// (NoSuchMethodError in JavaDocParser, CommentDetector): a lint bug, not a
// finding. Plugins are third-party code we don't edit; the app's own lint
// still runs.
subprojects {
    if (path != ":app") {
        tasks.matching { it.name.startsWith("lintVital") }.configureEach { enabled = false }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
