# 🎨 تحديث الأيقونة — Logo Update Guide

## ما تم تغييره / What Was Changed

تم استبدال اللوغو القديم بالجديد في كل المنصات.

### المصدر الرئيسي / Source Image
`web/icons/turathi_icon_1024.png` — صورة 1024×1024 RGBA (شفافة)

---

## الأحجام المُولَّدة / Generated Sizes

### 🤖 Android — `android/app/src/main/res/`

| المجلد | ic_launcher | ic_launcher_foreground | ic_launcher_background |
|--------|-------------|------------------------|------------------------|
| mipmap-mdpi | 48×48 | 108×108 | 108×108 |
| mipmap-hdpi | 72×72 | 162×162 | 162×162 |
| mipmap-xhdpi | 96×96 | 216×216 | 216×216 |
| mipmap-xxhdpi | 144×144 | 324×324 | 324×324 |
| mipmap-xxxhdpi | 192×192 | 432×432 | 432×432 |

**ic_launcher_background** = لون `#1A1A2E` (أزرق داكن)
**ic_launcher_foreground** = اللوغو مع padding 33%

### 🍎 iOS — `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

| الملف | الحجم |
|-------|-------|
| AppIcon-20@2x | 40×40 |
| AppIcon-20@3x | 60×60 |
| AppIcon-29 | 29×29 |
| AppIcon-29@2x | 58×58 |
| AppIcon-29@3x | 87×87 |
| AppIcon-40@2x | 80×80 |
| AppIcon-40@3x | 120×120 |
| AppIcon@2x | 120×120 |
| AppIcon@3x | 180×180 |
| AppIcon~ipad | 76×76 |
| AppIcon@2x~ipad | 152×152 |
| AppIcon-83.5@2x~ipad | 167×167 |
| AppIcon~ios-marketing | 1024×1024 |

### 🌐 Web — `web/icons/`
- `icon-192.png` / `Icon-192.png` → 192×192
- `icon-512.png` / `Icon-512.png` → 512×512
- `icon-192-maskable.png` / `Icon-maskable-192.png` → 192×192
- `icon-512-maskable.png` / `Icon-maskable-512.png` → 512×512
- `play_store_512.png` → 512×512 (Google Play)
- `turathi_icon_1024.png` → 1024×1024 (master)

### 🖼️ Assets — `assets/logo/`
- `turathi_logo.png` → 512×512 (للاستخدام داخل التطبيق)

---

## بعد النسخ / After Copying

```bash
# تأكد من تشغيل هذا الأمر لتطبيق الأيقونات:
flutter pub run flutter_launcher_icons
```

## pubspec.yaml
تم تحديثه ليشير إلى `web/icons/turathi_icon_1024.png` مع:
- `adaptive_icon_foreground` للأيقونة التكيفية
- `adaptive_icon_background: "#1A1A2E"` للخلفية الداكنة
