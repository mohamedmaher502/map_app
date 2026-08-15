# الصلاحيات المطلوبة

## Android — `android/app/src/main/AndroidManifest.xml`

ضيف السطور دي **قبل** وسم `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

وفي `android/app/build.gradle` تأكد إن:

```gradle
android {
    compileSdk = 34
    defaultConfig {
        minSdk = 21
    }
}
```

## iOS — `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to draw the driving route to your destination.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to draw the driving route to your destination.</string>
```

## تشغيل المشروع

```bash
flutter pub get
flutter run
```
