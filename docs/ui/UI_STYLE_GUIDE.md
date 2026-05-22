# GXNU Class Tool UI Design Specification

> Goal: Remove obvious Material Design visual traces and establish a lightweight, clean, stable interface system suitable for Guangxi Normal University course tool applications.  
> Scope: `lib/pages/**`, `lib/widgets/**`, `lib/ui/**`, `lib/class_tool_app.dart`.  
> Non-goal: Do not modify Controller, Repo, Model, data layers in this round; do not redo business processes; do not introduce complex animation frameworks.

---

## 1. Design Positioning

This UI is positioned as: **GXNU Blue Minimal / Campus Tool Lightweight Interface**.

Keywords:

- Clean
- Clear
- Moderate information density
- Low decoration
- Low shadow
- Light borders
- Blue primary brand
- No Material large rounded corners, ripples, splash effects, primaryContainer color block stacking

Do NOT make it:

- Material You large color block style
- Heavy card stacking Android system style
- Overly rounded, overly colorful, overly shadowed
- iOS glass morphism
- Windows Fluent full morphism
- School Logo element collage

Core principle:

> Business information comes first; decoration only serves as hierarchy cues. All pages should look like a unified campus tool, not pages cobbled together from a bunch of Material components.

---

## 2. Color System

### 2.1 Primary Color

The current project has already switched from purple to blue. It is recommended to continue using blue as the sole primary brand color. The primary color should not change frequently, and each page should not have its own color scheme.

Recommended primary color:

```dart
const AppBrandBlue = Color(0xFF3F63D8);
const AppBrandBlueDark = Color(0xFF8EA8FF);
```

If you later want a brighter color, you can change to:

```dart
const AppBrandBlue = Color(0xFF2F5FEA);
const AppBrandBlueDark = Color(0xFF8EA8FF);
```

It is recommended to keep `0xFF3F63D8` for this round to avoid introducing too many visual variables alongside the UI refactoring.

### 2.2 Light Palette

```dart
class AppLightColors {
  static const primary = Color(0xFF3F63D8);
  static const onPrimary = Color(0xFFFFFFFF);

  static const background = Color(0xFFF6F7F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F3F8);
  static const surfaceMuted = Color(0xFFEAF0FF);

  static const border = Color(0xFFE1E4EA);
  static const divider = Color(0xFFE8EBF0);

  static const text = Color(0xFF171A1F);
  static const textSecondary = Color(0xFF68707D);
  static const textMuted = Color(0xFF8A93A3);

  static const success = Color(0xFF168A5B);
  static const warning = Color(0xFFB7791F);
  static const danger = Color(0xFFD14343);
  static const info = Color(0xFF2F6FED);
}
```

### 2.3 Dark Palette

```dart
class AppDarkColors {
  static const primary = Color(0xFF8EA8FF);
  static const onPrimary = Color(0xFF0A1D64);

  static const background = Color(0xFF0F1115);
  static const surface = Color(0xFF171A20);
  static const surfaceAlt = Color(0xFF20242D);
  static const surfaceMuted = Color(0xFF1D2D66);

  static const border = Color(0xFF2A303A);
  static const divider = Color(0xFF252B34);

  static const text = Color(0xFFEEF0F4);
  static const textSecondary = Color(0xFFA6ACB8);
  static const textMuted = Color(0xFF7F8794);

  static const success = Color(0xFF62C997);
  static const warning = Color(0xFFE3B341);
  static const danger = Color(0xFFFF7676);
  static const info = Color(0xFF8EA8FF);
}
```

### 2.4 Color Usage Rules

Must follow:

- Page background only uses `surfaceContainerLowest / App background`.
- Container background only uses `surface` or very light `surfaceAlt`.
- Primary color is only used for: selected states, key buttons, accent lines, lightweight tags.
- Prohibit large areas of `primaryContainer` as card backgrounds.
- Success, warning, danger colors are only used for status, not for normal decoration.
- Do not use more than 3 high-saturation colors on a single page.

Recommended usage:

```dart
colorScheme.primary.withValues(alpha: 0.08)
colorScheme.surfaceContainerHighest.withValues(alpha: 0.24)
colorScheme.outlineVariant.withValues(alpha: 0.72)
```

Prohibited usage:

```dart
Card(color: colorScheme.primaryContainer)
Container(color: Theme.of(context).colorScheme.primaryContainer)
```

When emphasis is needed, prefer:

- A 3px blue vertical line on the left
- Small blue text
- Light blue background tags
- Light border highlighting

Do not use large solid blue backgrounds.

---

## 3. Border Radius, Spacing, Sizing

The current `AppTokens` direction is correct; keep converging toward the following set of values.

### 3.1 Border Radius

```dart
class AppRadius {
  const AppRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double pill = 999;
  static const double sheet = 18;
}
```

Usage rules:

- Small tags, progress bar internals: `xs = 6`
- Small buttons, icon buttons, input fields: `sm = 10` or `12`
- Normal containers, groups, list shells: `md = 14`
- BottomSheet / Dialog: `lg/sheet = 18`
- Capsule tags: `pill = 999`

Prohibited:

- Page normal Cards using large radii like 22, 24, 28.
- Having multiple different radii (10, 12, 14, 18, 24, 28) on the same page.

### 3.2 Spacing

```dart
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}
```

Page-level rules:

- Page horizontal padding: `16`
- Page top padding: `10` or `12`
- Page bottom padding: `24`
- Card internal padding: `14` or `16`
- List item left/right padding: `14`
- List item top/bottom padding: `12`
- Between sections: `16`
- Between section title and content: `8`

### 3.3 Sizes

```dart
class AppSize {
  const AppSize._();

  static const double bottomTabHeight = 58;
  static const double railWidth = 76;
  static const double tileMinHeight = 52;
  static const double buttonHeight = 44;
  static const double inputHeight = 46;
  static const double iconButton = 36;
  static const double icon = 20;
  static const double smallIcon = 18;
}
```

---

## 4. Typography and Text Hierarchy

Fonts continue to use system Chinese font fallback:

```dart
const fontFamilyFallback = <String>['Microsoft YaHei', 'PingFang SC'];
```

Recommended text hierarchy:

| Usage | Size | Weight | Color |
|---|---|---|---|
| Page title / AppBar title | 18 | 700 | onSurface |
| Section title | 15-16 | 700 | onSurface |
| Card main title | 14-15 | 600 | onSurface |
| Body text | 14 | 400/500 | onSurface |
| Auxiliary text | 12-13 | 400 | onSurfaceVariant |
| Tag / Status | 12 | 600 | primary / semantic |

Rules:

- Do not stack large font sizes. Tool-type app titles should not be oversized.
- Do not use `w700` for all text; only keep it for hierarchy emphasis.
- List item title uses `w600`, subtitle uses `bodySmall`.
- Numeric content can use `titleMedium + w700`, but not exceeding 22.

---

## 5. Containers and Hierarchy

This project subsequently uses `AppSurface` and `AppSection` uniformly; `Card` is no longer used directly.

### 5.1 AppSurface

Usage:

- Single content block
- Statistics block
- Form shell
- Empty state shell
- List group shell

Visual:

- Background: `colorScheme.surface`
- Border: `outlineVariant alpha 0.72`
- Shadow: none by default
- Border radius: `AppRadius.md`

A very small amount of shadow is allowed, but only for floating layers, not for normal page content.

### 5.2 AppSection

Usage:

- Settings page
- Features page
- About page
- Filter items
- Info page field groups

Rules:

- One section wraps a group of similar `AppTile` items.
- Section internally uses 1px divider.
- Section title uses `labelLarge w700 + onSurfaceVariant`.
- Do not have one Card per tile.

### 5.3 Page Structure Template

Normal page:

```dart
ListView(
  padding: AppInsets.page,
  children: [
    AppSurface(...),
    const SizedBox(height: AppSpacing.lg),
    AppSection(...),
  ],
)
```

Page with filters:

```dart
Column(
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: AppComboBox(...),
    ),
    Expanded(child: ...),
  ],
)
```

---

## 6. Interaction Style

### 6.1 Tap Feedback

The project already uses `NoSplash`; keep it.

Allowed:

- hover alpha `0.04`
- selected alpha `0.08`
- pressed alpha `0.10`
- `AnimatedContainer` 120ms-180ms

Prohibited:

- `InkSparkle`
- Obvious ripple effects
- Large area flashing
- Overly strong scale animations

### 6.2 Animation Duration

```dart
class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 180);
  static const Duration sheet = Duration(milliseconds: 220);
}
```

Rules:

- Button / tab selection: 120ms
- Card expand / segmented switch: 180ms
- Sheet popup: Flutter default is fine, at most ~220ms level
- No complex curves, no spring effects

---

## 7. Prohibited Items

The following components are not allowed to appear directly in page code:

```text
Card(
ListTile(
DropdownButtonFormField
DropdownButton
DropdownMenu
SegmentedButton
Chip(
FilterChip
ChoiceChip
NavigationBar
NavigationRail
BottomNavigationBar
FilledButton.tonalIcon
IconButton.filledTonal
Icons.
```

Exceptions:

- Inside `lib/ui/**`, basic constructs such as `Material`, `InkWell`, `Icon`, `AnimatedContainer` may be used.
- Business pages may only use custom project components such as `AppSurface`, `AppSection`, `AppTile`, `AppButton`, `AppIconButton`, `AppComboBox`, `AppSegmentedControl`, `AppTag`.

Check command:

```bash
rg -n "Card\(|ListTile\(|DropdownButtonFormField|DropdownButton\b|DropdownMenu\b|SegmentedButton|Chip\(|FilterChip|ChoiceChip|NavigationBar|NavigationRail|BottomNavigationBar|FilledButton\.tonalIcon|IconButton\.filledTonal|Icons\." lib
```

---

## 8. Acceptance Criteria for This Round

After this round of UI refactoring is complete, the following must be satisfied:

- `flutter analyze` produces no new warnings/errors.
- Controller / Repo / Model / data are not modified.
- All pages no longer directly use `Card`.
- All pages no longer directly use `ListTile`.
- All pages no longer directly use `DropdownButtonFormField`.
- All pages no longer directly use `SegmentedButton`.
- All pages no longer directly use `Chip`.
- All pages no longer directly use `FilledButton.tonalIcon`.
- All pages no longer directly use `Icons.*`.
- All navigation components use custom `AppBottomTabBar` / `AppRail`.
- All filter controls use `AppComboBox` or `AppFilterSheet`.
- Colors are only read from Theme / AppTokens / AppColors; do not hardcode large amounts of colors in pages.
