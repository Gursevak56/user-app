# Flutter Installation & Setup Guide for Windows

## Prerequisites
- Windows 10 or later (21H2 or later recommended)
- 1.5 GB free disk space
- PowerShell 5.0 or later (or command prompt)
- Git (optional but recommended)

---

## Step 1: Download Flutter SDK

1. Go to [flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)
2. Click **Download Flutter SDK** (the latest stable version)
3. This downloads a `.zip` file (appx 700MB-1GB)

---

## Step 2: Extract Flutter SDK

1. Extract the downloaded `.zip` file to a location WITHOUT spaces in the path
   - **GOOD**: `C:\flutter`, `D:\Flutter`, `C:\dev\flutter`
   - **AVOID**: `C:\Program Files\flutter`, `C:\My Files\flutter`
2. You'll have a folder structure like: `C:\flutter\bin`, `C:\flutter\lib`, etc.

---

## Step 3: Add Flutter to System PATH

### Option A (Recommended - Easy, Persistent)
1. Press `Win + X` → Select **System**
2. Click **Advanced system settings** (or search for "Environment Variables")
3. Click **Environment Variables** button
4. Under **User variables**, click **New**
   - **Variable name**: `FLUTTER_PATH`
   - **Variable value**: `C:\flutter` (or your extraction path)
5. Click **OK**
6. Now edit the **Path** variable:
   - Select **Path** → Click **Edit**
   - Click **New** and add: `C:\flutter\bin`
   - Click **OK** → **OK** → **OK**
7. **Restart PowerShell/Command Prompt**

### Option B (Quick - Add to Current Session)
Open PowerShell and run:
```powershell
$env:PATH += ";C:\flutter\bin"
```
(Note: This only lasts for the current session)

---

## Step 4: Verify Flutter Installation

Open **PowerShell** and run:
```powershell
flutter --version
```

You should see output like:
```
Flutter 3.x.x • channel stable
```

---

## Step 5: Install Android SDK (For Android Development)

### Option A: Install Android Studio (Recommended)
1. Download from [developer.android.com/studio](https://developer.android.com/studio)
2. Run the installer and follow prompts
3. During setup, select:
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device (AVD)
4. Complete installation

### Option B: Command Line Only
If you only want command-line tools:
1. Download **Android SDK Command-line Tools** from [developer.android.com/studio](https://developer.android.com/studio)
2. Extract to `C:\Android\sdk\cmdline-tools\`
3. Add this to PATH (see Step 3)

---

## Step 6: Accept Android Licenses

Run in PowerShell:
```powershell
flutter doctor --android-licenses
```

Press `y` and `Enter` for each license agreement.

---

## Step 7: Run Doctor to Check Setup

Run:
```powershell
flutter doctor
```

This checks your entire setup. Output should look like:
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Windows toolchain - develop for Windows
[ ] Xcode - (not available, only needed for iOS on Mac)
[✓] Chrome - develop for the web
```

**Green checkmarks ✓** = Ready to use
**Exclamation ! or X** = May need attention (depends on platforms you target)

---

## Step 8: Get Project Dependencies

Navigate to your project folder and run:
```powershell
cd D:\Mangaale\user-app
flutter pub get
```

This downloads all dependencies listed in `pubspec.yaml`.

---

## Step 9: Run Your App

### For Android (Physical Device or Emulator)
```powershell
flutter run
```

### For Web
```powershell
flutter run -d chrome
```

### For Windows Desktop
```powershell
flutter run -d windows
```

### List Available Devices
```powershell
flutter devices
```

---

## Optional: Install VS Code Flutter Extension

1. Install **VS Code**: [code.visualstudio.com](https://code.visualstudio.com)
2. Install **Flutter** extension (ID: `Dart-Code.flutter`)
3. Optionally install **Dart** extension (ID: `Dart-Code.dart-code`)

This provides:
- Code completion
- Debugging
- Hot reload
- Widget inspector

---

## Troubleshooting

### "flutter: command not found"
- PATH not updated. Restart PowerShell or manually run: `$env:PATH += ";C:\flutter\bin"`

### "Android SDK not found"
- Run `flutter doctor` to see the issue
- Either install Android Studio or set `ANDROID_HOME` environment variable

### "Gradle error"
- Run: `flutter clean` then `flutter pub get`

### App won't run on Android
- Ensure Android device is connected: `flutter devices`
- Or create an Android emulator in Android Studio

### Other issues
- Run: `flutter doctor -v` for detailed diagnostics
- Check [flutter.dev/docs](https://flutter.dev/docs) for specific errors

---

## Next Steps
1. Navigate to your project: `cd D:\Mangaale\user-app`
2. Run `flutter doctor` to verify everything
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to launch your app

---

**Questions?**
- Official Flutter Docs: https://flutter.dev/docs
- Flutter Discord Community: https://discord.gg/flutter
- Stack Overflow: Tag with `flutter` and `dart`
