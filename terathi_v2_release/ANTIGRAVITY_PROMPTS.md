# 🏛️ Athera 3D — Antigravity Prompts (مرتبة بالترتيب)

---

## ▸ الخطوة الأولى — Colors System (أول شي تبدأ به)

**Prompt 1 — تحديث نظام الألوان:**

```
Replace the entire content of `lib/core/theme/app_colors.dart` with the following Heritage Immersion color system. This palette is warm cream + deep teal + gold, inspired by the Algerian landscape.

Primary (Deep Teal): #1E5B5A
Primary Container: #2C7873
Secondary (Gold): #B2874E
Secondary Container: #FED977
Background (Warm Cream): #FFF8F5
Surface: #FFFFFF
Surface Container Low: #FFF1E7
Surface Container: #FFEAD9
Surface Container High: #FAE4D3
On-Surface (Warm Black): #2B2B2B
Text Secondary: #3F4947
Text Tertiary: #6F7978
Outline Variant: #BEC9C7
Nav Active: #1C1208
Nav Inactive: #B0A898
Shadow: rgba(28,18,8,0.08)
UNESCO Gold: #C9A84C

Update all hardcoded color references in the project to use this new AppColors class. Make sure AppColors has static const Color fields for all of the above. Do not change any logic or layout, only the color values.
```

---

## ▸ الخطوة الثانية — Typography

**Prompt 2 — Cairo Font:**

```
Add the Cairo Google Font as the default font family for the entire app.

1. Add `google_fonts: ^6.2.1` to pubspec.yaml dependencies.
2. In `lib/core/theme/app_theme.dart`, set `fontFamily: GoogleFonts.cairo().fontFamily` as the default for the ThemeData's textTheme.
3. Apply `GoogleFonts.cairoTextTheme()` to the base textTheme.
4. Make sure Directionality is set to RTL (TextDirection.rtl) at the MaterialApp level inside `lib/app.dart`.
5. Do not break any existing text styles; only apply Cairo as the default font.
```

---

## ▸ الخطوة الثالثة — Bottom Navigation Bar

**Prompt 3 — Navigation Bar بنظام Heritage Immersion:**

```
Completely redesign `lib/shared/widgets/Athera_bottom_nav.dart` to match the Heritage Immersion design system.

Requirements:
- Fixed 72px height container
- White (#FFFFFF) background with a top border using outlineVariant at 50% opacity
- Soft ambient shadow: blurRadius 24, offset (0, -4), color rgba(28,18,8,0.08)
- 4 items: الرئيسية (home), استكشاف (explore), المحفوظات (bookmark), حسابي (person)
- Each item: icon on top + label text below (11px, Cairo)
- Active state: icon color = #1C1208 (warm black), label bold weight 600, pill-shaped background indicator using primaryContainer at 12% opacity
- Inactive state: icon + label color = #B0A898 (muted sand)
- Use GestureDetector with AnimatedContainer for smooth 250ms transitions between states
- Do NOT use Flutter's NavigationBar widget — build it manually with Row + custom _NavItem widget
- Keep the existing StatefulNavigationShell logic unchanged
```

---

## ▸ الخطوة الرابعة — Splash Screen

**Prompt 4 — Splash Screen مع الشعار:**

```
Redesign `lib/features/splash/presentation/screens/splash_screen.dart` completely.

Design:
- Background: solid AppColors.primary (#1E5B5A)
- Add a subtle diagonal line pattern using CustomPainter (lines at 45°, white at 4% opacity, spacing 80px)
- Center content:
  1. Logo container: 100x100, borderRadius 28, backgroundColor white at 12% opacity, border white at 15%, contains the Arabic letter "ث" in #F5F0E8, Cairo bold, size 52
  2. Below logo: app name "Athera 3D" in white, Cairo 700, size 36
  3. Below name: tagline "اكتشف تراث الجزائر" in white at 65% opacity, Cairo 400, size 16
- Bottom: small CircularProgressIndicator (white 40% opacity, strokeWidth 2) + text "التراث الجزائري بين يديك" at white 40%
- Animations using flutter_animate:
  - Logo: fade 700ms + scale from 0.7 to 1.0 with elasticOut curve
  - App name: fade delay 400ms + slideY from 0.3
  - Tagline: fade delay 600ms
  - Bottom content: fade delay 1000ms
- Auto-navigate to /onboarding after 2400ms using Future.delayed in initState
- Set status bar to transparent with light icons using SystemChrome
```

---

## ▸ الخطوة الخامسة — Onboarding Screen

**Prompt 5 — Onboarding بتصميم Immersive:**

```
Redesign `lib/features/onboarding/presentation/screens/onboarding_screen.dart` completely.

The onboarding uses a full-screen animated gradient background that changes color with each slide.

Slides data (3 slides):
1. title: "مرحباً في Athera 3D", subtitle: "رحلة افتراضية غامرة\nفي قلب التراث الجزائري العريق", symbol: "ث", symbolColor: #B4FDF7, gradientFrom: #024A47, gradientTo: #2C7873, tag: "127 معلماً تاريخياً"
2. title: "استكشف بتقنية 360°", subtitle: "جولات افتراضية غامرة\nداخل أعرق المواقع الأثرية", symbol: "360", symbolColor: #FFEDD2, gradientFrom: #504531, gradientTo: #786B54, tag: "تجربة واقعية مذهلة"
3. title: "مرشدك الذكي الشخصي", subtitle: "تحدث بالدارجة والعربية\nواحصل على معلومات دقيقة وحصرية", symbol: "AI", symbolColor: #FED977, gradientFrom: #584400, gradientTo: #B2874E, tag: "ذكاء اصطناعي متقدم"

Layout (top to bottom):
- Top bar: dots indicator (active = white pill 24px wide, inactive = white 35% circle 8px) on the right, skip button on the left (white 75%, hidden on last slide)
- Center PageView: large circular symbol container (180x180, white 10% bg, white 20% border 2px), title (Cairo 700 28px white), subtitle (Cairo 400 16px white 75%)
- Bottom: animated tag chip (white 15% bg, white 25% border, pill shape) + full-width white button (58px height, borderRadius 16, foreground color = slide gradient start color, label changes to "ابدأ الاستكشاف 🏛️" on last slide)
- Wrap entire Scaffold in AnimatedContainer with gradient that transitions on page change (500ms)
- Use flutter_animate for slide entrance animations (fade + slideY) with isActive prop
- RTL direction using Directionality widget
- On finish: call onboardingProvider.markCompleted() then navigate to /login
```

---

## ▸ الخطوة السادسة — Home Screen

**Prompt 6 — الصفحة الرئيسية الجديدة:**

```
Redesign `lib/features/home/presentation/screens/home_screen.dart` completely using the Heritage Immersion design system.

Changes required:
- Background: AppColors.background (#FFF8F5) warm cream
- SliverAppBar: glassmorphism effect (BackdropFilter blur 12), background white at 85%, bottom border outlineVariant at 40%. Title row: small logo square (36x36, primary color bg, white "ث" letter) on the right, "Athera 3D" text center, search icon on the left
- Greeting section: name "صباح الخير، {name} 👋" in Cairo 700 size 26, textPrimary color. Below: monument count in textTertiary size 14
- Search bar: height 52, surfaceContainerLow background, outlineVariant border, borderRadius 999 (pill shape). Suffix: small teal circle button with mic icon
- Hero card: unchanged logic, keep HeroMonumentCard
- Section header "الأكثر زيارة": add a "عرض الكل" TextButton in primaryContainer color on the left
- Monument list: add SizedBox height 12 separator between items
- All text uses fontFamily: 'Cairo'
- All colors from AppColors (new Heritage palette)
- Animations via flutter_animate: fadeIn + slideY on all sections with staggered delays
```

---

## ▸ الخطوة السابعة — Profile Screen

**Prompt 7 — صفحة حسابي:**

```
Completely redesign `lib/features/profile/presentation/screens/profile_screen.dart` using Heritage Immersion design.

Layout using CustomScrollView + Slivers:

1. Hero Header (SliverToBoxAdapter):
   - Gradient container 220px height: colors [#024A47, #2C7873] topRight to bottomLeft
   - Top bar inside SafeArea: "حسابي" title in white Cairo 700 on the right, settings icon on the left
   - Avatar overlapping bottom: CircleAvatar radius 50, white border 5px, shadow. Edit icon badge (primaryContainer, 14px icon) at bottom-left of avatar
   - Avatar positioned with Positioned bottom: -60

2. Name & Email (SliverToBoxAdapter):
   - paddingTop 72 (to account for avatar overlap)
   - User name: Cairo 700 size 22, textPrimary
   - Email: Cairo 400 size 14, textTertiary

3. Stats Row (SliverToBoxAdapter):
   - 3 equal cards: جولة (12), دقيقة (480), محفوظة (8)
   - Each card: white bg, borderRadius 16, shadow. Shows icon + value (Cairo 700 22px textPrimary) + label (Cairo 500 11px textTertiary)

4. Progress Card (SliverToBoxAdapter):
   - White card, borderRadius 20, shadow
   - Row: explore icon in teal circle, "رحلة الاستكشاف" title, "12 / 127" counter in primaryContainer
   - LinearProgressIndicator: value 12/127, height 8, borderRadius 99, primaryContainer color
   - Subtext: "9% مكتمل · واصل الاستكشاف! 🏛️" in textTertiary

5. Premium Card (if not premium):
   - Gradient: [#B2874E, #C9A84C], borderRadius 20
   - Left: "⭐ الباقة المميزة" + subtitle. Right: white "اشترك" button

6. Menu Card:
   - White card, borderRadius 20, shadow
   - Items: ملفي الشخصي, الإشعارات, إنجازاتي, سجل الجولات, اشتراكي, المساعدة, تسجيل الخروج (red, destructive)
   - Each item: rounded icon container (10px radius, tint color at 10% opacity) + Cairo 600 15px label + chevron
   - Dividers between items: indent 60, color surfaceContainerHigh

All animations with flutter_animate: fadeIn + slideY with staggered delays (150ms increments).
```

---

## ▸ ملاحظات مهمة لـ Antigravity

- استخدم اللوغو (صورة PNG للشعار) في الـ assets: `assets/images/logo.png` وأضف `Image.asset('assets/images/logo.png')` في الـ splash عوض الـ CustomPainter إذا أضفت الصورة للـ pubspec
- في كل prompt تأكد أن الـ `fontFamily: 'Cairo'` موجود أو استخدم `GoogleFonts.cairo()`
- الـ TextDirection.rtl يجب أن يكون في `MaterialApp` مباشرة وليس في كل صفحة
- الـ shadowColor في كل مكان: `Color(0x141C1208)` (8% warm black)
