# GXNU Class Tool UI Component Specification

> Goal: Replace scattered Material components in pages with custom project components. Business pages only compose custom components, not directly stack Material-style controls.

---

## 1. Component Layering

Recommended directory:

```text
lib/ui/
  app_tokens.dart              # Border radius, spacing, sizing, opacity, animation duration
  app_colors.dart              # Optional: light/dark color constants, or merged into theme builder
  app_icons.dart               # Unified icon export; business pages must not directly reference third-party icon libraries
  app_surface.dart             # Lightweight container, replaces Card
  app_section.dart             # Group container, replaces multiple Card/ListTile
  app_tile.dart                # List item, replaces ListTile
  app_button.dart              # Primary/secondary/danger button
  app_icon_button.dart         # Small icon button, replaces IconButton.filledTonal etc.
  app_combo_box.dart           # Dropdown selector, replaces DropdownButtonFormField
  app_segmented_control.dart   # Segmented selector, replaces SegmentedButton
  app_tag.dart                 # Tag, replaces Chip
  app_bottom_tab_bar.dart      # Bottom navigation, replaces NavigationBar
  app_rail.dart                # Wide-screen side navigation, replaces NavigationRail
  app_empty_state.dart         # Empty/error/retry state
```

---

## 2. AppSurface

The current project already has `AppSurface`; the direction is correct.

Recommended supplements:

- `backgroundColor` optional parameter
- `borderColor` optional parameter
- `pressedOpacity` not handled at business layer
- `hoverColor` handled uniformly
- Do not mix with `CardTheme`

Reference interface:

```dart
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.md,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final Clip clipBehavior;
}
```

Usage:

```dart
AppSurface(
  padding: AppInsets.card,
  child: ...,
)
```

Prohibited:

```dart
Card(child: ...)
```

---

## 3. AppSection

The current project already has `AppSection`, used for groups of settings items or feature items.

Rules:

- Settings pages, feature pages, and about pages must prefer `AppSection`.
- Section internals only contain `AppTile` or lightweight controls of equivalent height.
- Do not wrap `Card` inside a section.

Example:

```dart
AppSection(
  title: 'Query',
  children: [
    AppTile(
      icon: AppIcons.exam,
      title: 'Exam Schedule',
      subtitle: 'View exam times, locations, and seat information',
      onTap: openExamPage,
    ),
    AppTile(
      icon: AppIcons.grade,
      title: 'Grade Inquiry',
      subtitle: 'View highest grades, GPA, credits, and grade breakdowns',
      onTap: openGradePage,
    ),
  ],
)
```

---

## 4. AppTile

The current project already has `AppTile`; continue using it as the sole list item component.

Recommended adjustments:

- `icon` still uses `IconData`, but must come from `AppIcons`.
- Default chevron must also come from `AppIcons.chevronRight`.
- Support `leading` to avoid all scenarios only being able to pass `IconData`.
- Support `minHeight` for more compact info page fields.

Recommended interface:

```dart
class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.showChevron = true,
    this.minHeight = AppSize.tileMinHeight,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showChevron;
  final double minHeight;
}
```

---

## 5. AppButton

Replaces:

```text
FilledButton
FilledButton.icon
FilledButton.tonalIcon
OutlinedButton.icon
ElevatedButton
```

Recommended three visual variants:

```dart
enum AppButtonVariant {
  primary,
  secondary,
  danger,
}
```

Rules:

- Key submission: `primary`
- Normal action: `secondary`
- Logout / Delete: `danger`, but default is not large red background; prefer red border or red text

Visual:

- Height: 44/46
- Border radius: 12
- Font weight: 600/700
- No shadow by default

Example:

```dart
AppButton(
  label: 'Retry',
  icon: AppIcons.refresh,
  onPressed: onRetry,
)
```

---

## 6. AppIconButton

Replaces:

```text
IconButton
IconButton.filled
IconButton.filledTonal
```

Recommended interface:

```dart
enum AppIconButtonVariant {
  ghost,
  soft,
  outline,
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.variant = AppIconButtonVariant.outline,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final AppIconButtonVariant variant;
}
```

Usage rules:

- AppBar refresh, filter: `ghost`
- Small buttons inside schedule page: `soft`
- Tool buttons that need boundary feel: `outline`

Sizing:

- Outer frame: 36x36
- Icon: 18/20
- Border radius: 10

---

## 7. AppComboBox

Replaces:

```text
DropdownButtonFormField
DropdownButton
DropdownMenu
```

This project heavily uses dropdown filters in grade, exam, progress, and credit pages. They should be unified into `AppComboBox<T>`.

### 7.1 Visual

Default is a lightweight input field:

- Height 46
- Background surface
- 1px border
- Border radius 12
- Optional left label
- Right chevron down
- Selected value ellipsis on one line

On tap:

- Phone: Opens `AppBottomSheet`, list uses `AppTile`
- Desktop/wide-screen: Can continue using the same BottomSheet; ensure consistency first; lightweight popup later

### 7.2 Recommended Interface

```dart
class AppComboBoxItem<T> {
  const AppComboBoxItem({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
}

class AppComboBox<T> extends StatelessWidget {
  const AppComboBox({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.placeholder = 'Please select',
    this.enabled = true,
  });

  final T? value;
  final List<AppComboBoxItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? label;
  final String placeholder;
  final bool enabled;
}
```

### 7.3 Page Replacement Scope

Must replace:

```text
lib/pages/credit/view.dart
lib/pages/progress/view.dart
lib/pages/exams/view.dart
lib/pages/query/view.dart
```

Any new Dropdown in the future must also use `AppComboBox`.

---

## 8. AppSegmentedControl

Replaces:

```text
SegmentedButton
```

Currently used in:

```text
lib/pages/time/view.dart
```

Visual:

- Shell: AppSurface-style light background
- Each button equal width
- Selected item: primary alpha 0.08 + primary text
- Unselected item: transparent + onSurfaceVariant
- Do not use Material segmented outer border style

Recommended interface:

```dart
class AppSegmentItem<T> {
  const AppSegmentItem({required this.value, required this.label});
  final T value;
  final String label;
}

class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<AppSegmentItem<T>> items;
  final ValueChanged<T> onChanged;
}
```

---

## 9. AppTag

Replaces:

```text
Chip
FilterChip
ChoiceChip
```

Currently used in:

```text
lib/pages/query/view.dart
```

Visual:

- Height 24-28
- Border radius pill
- Font size 12
- Font weight 600
- Background uses `primary alpha 0.08` or `surfaceAlt`
- Do not use Material Chip default padding and shape

Recommended interface:

```dart
enum AppTagVariant {
  neutral,
  primary,
  success,
  warning,
  danger,
}

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.variant = AppTagVariant.neutral,
    this.icon,
  });

  final String label;
  final AppTagVariant variant;
  final IconData? icon;
}
```

---

## 10. AppBottomTabBar

The current project already has `AppBottomTabBar`; keep it.

Recommended adjustments:

- `icon` and `selectedIcon` must come from `AppIcons`
- Selected item should not expand into Material navigation pill
- Only keep lightweight light blue background
- Icon size 22 can be kept
- Consider showing 2px top line or label when selected, but not mandatory for this round

---

## 11. AppRail

The current code does not have `NavigationRail`, but when adapting for tablets/desktop in the future, custom `AppRail` must be used; do not introduce Material `NavigationRail`.

Recommended trigger condition:

```dart
final useRail = MediaQuery.sizeOf(context).width >= 720;
```

Visual:

- Width: 76
- Background: surface alpha 0.96
- Right border: outlineVariant alpha 0.72
- Item: 48x44, border radius 12
- Selected: primary alpha 0.08 + primary icon
- Unselected: onSurfaceVariant icon

Layout:

```text
Row
 ├─ AppRail
 └─ Expanded(page stack)
```

Bottom navigation and rail should not appear simultaneously.

---

## 12. AppEmptyState / AppRetryState

Multiple pages currently have similar empty/error states; they should be unified.

Replacement scope:

```text
lib/pages/credit/view.dart
lib/pages/exams/view.dart
lib/pages/info/view.dart
lib/pages/progress/view.dart
lib/pages/time/view.dart
lib/pages/query/view.dart
lib/pages/splash/view.dart
```

Recommended interface:

```dart
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
}
```

Visual:

- Centered
- Icon 36-42, muted color
- Title 15/16 w700
- Subtitle 13 onSurfaceVariant
- Button uses `AppButton.secondary`

---

## 13. Page Replacement Checklist

### 13.1 Pages Already Modified But Need Further Cleanup

```text
lib/pages/home/view.dart
```

Need to continue:

- Skeleton internals: `Card` → `AppSurface`
- `_StatTile` internals: if still `Card` → `AppSurface`
- Confirm all color blocks do not use `primaryContainer`

```text
lib/pages/settings/view.dart
lib/pages/features/view.dart
lib/pages/main/view.dart
```

Need to continue:

- All `Icons.*` → `AppIcons.*`
- `AppTile` default chevron → `AppIcons.chevronRight`

### 13.2 Pages That Must Be Key Targets

```text
lib/pages/query/view.dart
```

Most problems:

- Many `Card`
- Many `DropdownButtonFormField`
- Many `Chip`
- Has `FilledButton.icon`
- Has `IconButton`
- Has `Icons.*`

It is recommended to do this page first, as it validates component coverage capability.

```text
lib/pages/exams/view.dart
```

Key points:

- Filter BottomSheet dropdown → `AppComboBox`
- ExamCard → `AppSurface`
- Skeleton cards → `AppSurface`
- Retry → `AppEmptyState`

```text
lib/pages/credit/view.dart
lib/pages/progress/view.dart
lib/pages/time/view.dart
```

Key points:

- Dropdown → `AppComboBox`
- Segmented → `AppSegmentedControl`
- SummaryCard / GroupCard / skeleton → all `AppSurface`

```text
lib/pages/info/view.dart
```

Key points:

- `_SectionCard` can directly become `AppSection` or `AppSurface`
- Field rows become compact `AppTile` or custom `_InfoRow`
- Skeleton → `AppSurface`

```text
lib/pages/classes/view.dart
lib/pages/classes/widgets/schedule_picker_sheet.dart
lib/pages/classes/widgets/schedule_table.dart
lib/pages/classes/widgets/course_detail_sheet.dart
```

Key points:

- Header `Card` → `AppSurface`
- Schedule picker `ListTile` → `AppTile`
- Refresh button → `AppIconButton`
- Detail sheet icons → `AppIcons`
- Course blocks can keep custom `Container`; no need to force AppSurface; the schedule is a special visual area

```text
lib/pages/login/view.dart
```

Key points:

- Login cards → `AppSurface`
- TextField can later use `AppTextField`
- Prefix/suffix icons → `AppIcons`
- Login button → `AppButton.primary`

```text
lib/pages/settings/about_page.dart
```

Key points:

- `Card` → `AppSurface` / `AppSection`
- `_InfoTile` from `ListTile` → `AppTile`
- Icons → `AppIcons`

```text
lib/utils/shared_dialog.dart
```

Key points:

- Dialog internal `FilledButton` → `AppButton`
- Icons → `AppIcons`

---

## 14. Allowed Flutter Material Basic Capabilities

This project is not about deleting `package:flutter/material.dart`; it is about removing the Material visual style.

Allowed:

```text
Scaffold
AppBar
SafeArea
ListView
CustomScrollView
Text
Icon
Material
InkWell
AnimatedContainer
TextField (preferably eventually wrapped in AppTextField)
Navigator / MaterialPageRoute
showDialog / showModalBottomSheet (must use project uniform style wrapping)
```

What is not allowed directly in business pages are those high-level components that carry strong Material visuals by default.

---

## 15. Recommended Refactoring Order

Do not change all pages at once. Recommended order:

1. Add `app_icons.dart`
2. Add `app_icon_button.dart`
3. Add `app_button.dart`
4. Add `app_tag.dart`
5. Add `app_segmented_control.dart`
6. Add `app_combo_box.dart`
7. Add `app_empty_state.dart`
8. Clean up `Icons.*`
9. Clean up `Card`
10. Clean up `DropdownButtonFormField`
11. Clean up `SegmentedButton`
12. Clean up `Chip`
13. Clean up `ListTile`
14. Run `flutter analyze`
15. Run global `rg` prohibited items check
