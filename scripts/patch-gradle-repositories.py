from pathlib import Path

settings = Path("android/settings.gradle.kts")
if not settings.exists():
    raise SystemExit("Generated Android settings.gradle.kts was not found")

source = settings.read_text()
mirror = 'maven { url = uri("https://maven-central.storage-download.googleapis.com/maven2/") }'
if mirror not in source:
    source = source.replace("repositories {", "repositories {\n        " + mirror, 2)
settings.write_text(source)

print("Configured Google-hosted Maven Central mirror for Gradle plugin and dependency resolution.")
