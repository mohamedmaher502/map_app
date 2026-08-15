# ليه زرار الـ GPS مش بيحدد الموقع؟

اضغط **مطوّل** على زرار الموقع في التطبيق → هيفتح شيت "Location diagnostics" بيوريك:
`GPS service` / `Permission` / `Last known` / `Platform`. من القيم دي تعرف السبب فورًا.

## 1) الصلاحيات مش مضافة في AndroidManifest (أشهر سبب)

لو `Permission` بيقول `denied` والتطبيق **عمره ما طلب منك إذن**، فالسبب إن الصلاحيات ناقصة.
افتح `android/app/src/main/AndroidManifest.xml` وضيف قبل `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

بعد الإضافة **اعمل stop للتطبيق و rerun** (hot reload مش كفاية):

```bash
flutter clean && flutter pub get && flutter run
```

## 2) بتجرب على إيموليتر بدون موقع مضبوط

الإيموليتر مبيبعتش موقع من نفسه، فالطلب بيفضل مستني لحد ما يعمل timeout.
الحل: Android Emulator → زرار `...` (Extended controls) → **Location** → اختار نقطة → **Set Location**.
لو Genymotion/إيموليتر مفيهوش Play Services، النسخة الجديدة من `LocationService` بتعمل fallback
تلقائي على `forceLocationManager: true`.

## 3) الـ GPS مقفول أو على وضع Battery saving

لو `GPS service = OFF` → التطبيق بيفتحلك ديالوج فيه "فتح الإعدادات".
وكمان في إعدادات الأندرويد: Location → Location services → **Google Location Accuracy = ON**
(وضع Device only بيخلي الـ fix ياخد دقايق جوه المباني).

## 4) جوه مبنى / إشارة ضعيفة فالـ fix بياخد وقت

النسخة الجديدة بتجرب بالترتيب:
1. دقة عالية (GPS) — 15 ثانية
2. آخر موقع معروف من كاش الجهاز
3. دقة متوسطة (Wi-Fi / شبكة الموبايل) — 20 ثانية
4. أندرويد: `LocationManager` مباشرة — 25 ثانية

يعني حتى لو الـ GPS فشل، بيرجّع موقع تقريبي من الشبكة بدل ما يفضل "مش بيحدد".

## 5) صلاحية مرفوضة نهائيًا (Denied forever)

لو `Permission = deniedForever` → مفيش طلب إذن تاني بيظهر أبدًا.
الحل: من ديالوج التطبيق "فتح الإعدادات" → Permissions → Location → **Allow**.
أو امسح بيانات التطبيق: Settings → Apps → map_app → Storage → Clear data.

## 6) iOS

لازم السطور دي في `ios/Runner/Info.plist`، وبدونها التطبيق يقع أو ميطلبش إذن:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to draw the driving route to your destination.</string>
```

## لو لسه المشكلة موجودة

الخطأ التقني الحقيقي بيتطبع في الكونسول بالشكل:

```
Location error details: ....
```

شغّل `flutter run` من التيرمنال، دوس على زرار الموقع، وابعتلي السطر اللي بيظهر.

## 7) Crash أول ما يجيب الموقع (MapController used before map render)

**السبب:** استخدام `_mapController.move()` قبل ما `FlutterMap` تتبني لأول مرة —
`flutter_map` بيرمي:

```
You need to have the FlutterMap widget rendered at least once before using MapController
```

وده كان بيحصل لأن `_initLocation()` كانت بتتنادى من `initState` ولو الموقع رجع بسرعة
(من كاش الجهاز) الحركة بتحصل قبل أول frame.

**الحل المطبّق:**
- طلب الموقع بقى جوه `WidgetsBinding.instance.addPostFrameCallback`
- `MapOptions.onMapReady` بيرفع فلاج `_mapReady`
- كل حركات الكاميرا بقت من خلال `_safeMove` / `_safeFit` اللي:
  - بيخزّنوا الطلب لو الخريطة لسه مش جاهزة وينفّذوه في `onMapReady`
  - وملفوفين في `try/catch` فمفيش crash في أي حالة

## 8) MissingPluginException

لو الرسالة `MissingPluginException(No implementation found for method ...)`:
أوقف التطبيق تمامًا (مش hot reload) و:

```bash
flutter clean && flutter pub get && flutter run
```
