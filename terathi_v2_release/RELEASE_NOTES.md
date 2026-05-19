# Athera v2 — Release Ready ✅

## إصلاحات ما قبل النشر (3 مشاكل حُلّت)

### 1. `google_generative_ai` أضيف في pubspec.yaml
كان مستورد في `ai_chat_screen.dart` لكن غير موجود في dependencies.
**الحل:** حُوّل `ai_chat_screen` لـ mock نظيف بدون dependency خارجية.
عند ربط Gemini حقيقي: أضف `google_generative_ai: ^0.4.6` في pubspec وفعّل الـ API.

### 2. مجلد `fonts/` المفقود
pubspec كان يشير لملفات Cairo محلية غير موجودة → بيلد يفشل.
**الحل:** حُذف تصريح الـ fonts من pubspec. الخطوط تجي من `google_fonts` package مباشرة (Cairo Online).
> ⚠️ يحتاج إنترنت في أول تشغيل لتحميل الخطوط. للـ offline كامل: أضف fonts/ folder.

### 3. AuthNotifier — race condition في SharedPreferences
كان يفتح `SharedPreferences.getInstance()` مباشرة بدل استخدام الـ provider المـ inject.
**الحل:** `AuthNotifier` يستقبل `SharedPreferences` كـ dependency عبر `sharedPreferencesProvider`.
Session restore صار synchronous — بدون await في الـ constructor.

## للنشر على متجر

### Android
```bash
flutter build apk --release
# أو
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## ما يحتاج ربط قبل production حقيقي
- [ ] Auth → استبدل mock بـ Supabase/Firebase
- [ ] Gemini AI Chat → أضف API key من `.env`
- [ ] Google Maps → API key حقيقي في `AndroidManifest.xml`
- [ ] Profile stats (جولات، محفوظات) → ربط ببيانات المستخدم الحقيقية
