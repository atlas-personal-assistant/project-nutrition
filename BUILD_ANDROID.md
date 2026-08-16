# Android Build Guide — Project Nutrition

## Voraussetzungen

### 1. Android SDK installieren
Lade Android Studio oder das Android SDK Command Line Tools herunter:
```bash
# Linux/macOS
mkdir -p ~/Android/cmdline-tools
cd ~/Android/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip
mv cmdline-tools latest

# Windows
# Lade von: https://developer.android.com/studio#command-tools
```

### 2. Umgebungsvariablen setzen
Füge zu `~/.bashrc`, `~/.zshrc` oder System-Umgebungsvariablen hinzu:

```bash
# Android SDK
export ANDROID_HOME=$HOME/Android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator

# Flutter
export PATH=$PATH:/data/.openclaw/flutter/bin  # oder dein Flutter-Pfad
```

### 3. SDK-Komponenten installieren
```bash
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### 4. Build ausführen
```bash
cd apps/client

# Debug APK
flutter build apk --debug

# Release APK (benötigt Signing)
flutter build apk --release

# App Bundle (für Play Store)
flutter build appbundle
```

## App-Konfiguration

| Eigenschaft | Wert |
|-------------|------|
| **Application ID** | `com.nutrition.app` |
| **Min SDK** | 21 (Android 5.0) |
| **Target SDK** | 34 |
| **Compile SDK** | 34 |

### Umgebungs-Konfiguration

#### Development (lokal)
Die App nutzt standardmäßig `http://localhost:8000/api/v1`.
Für Android Emulator: `http://10.0.2.2:8000/api/v1`

#### Staging/Production
Passe die API-URL in `lib/core/constants/api_constants.dart` an:
```dart
static const String baseUrl = 'https://api.nutrition.example.com';
```

## Signing

### Debug
Die Debug-APK wird automatisch mit dem Debug-Keystore signiert.

### Release
Erstelle einen Release-Keystore:
```bash
cd android/app
keytool -genkey -v -keystore release.keystore -storepass DEIN_PASSWORT \
  -alias release -keypass DEIN_PASSWORT -keyalg RSA -keysize 2048 \
  -validity 10000 -dname "CN=Project Nutrition,O=,C=DE"
```

Konfiguriere `android/key.properties`:
```properties
storeFile=release.keystore
storePassword=DEIN_PASSWORT
keyAlias=release
keyPassword=DEIN_PASSWORT
```

⚠️ **WICHTIG:** `android/key.properties` und `*.keystore` sind in `.gitignore` und dürfen niemals committed werden!

## Troubleshooting

### Kein Android SDK gefunden
```bash
export ANDROID_HOME=/path/to/android/sdk
flutter config --android-sdk $ANDROID_HOME
```

### Gradle-Probleme
```bash
cd android
./gradlew clean
flutter clean
flutter pub get
```

### Keystore-Fehler bei Debug-Build
Der Debug-Keystore wird automatisch von Flutter generiert. Falls Probleme auftreten:
```bash
rm -rf ~/.android/debug.keystore
flutter build apk --debug
```
