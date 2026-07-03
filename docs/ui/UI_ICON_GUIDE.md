# GXNU Class Tool Icon Specification

> Goal: No longer directly use Flutter Material Icons; unify to a cleaner, lighter third-party icon library, and encapsulate it via `AppIcons` at the project level.

---

## 1. Conclusion

Primary recommendation:

```yaml
dependencies:
  fluentui_system_icons: ^1.1.273
```

Reasons for selection:

- The official package comes from the Microsoft ecosystem, with a more stable maintenance source.
- Icons are a modern system icon style, suitable for tool-type apps like schedule, settings, and grade inquiry.
- Simple dependencies; mainly depends on Flutter; does not require `flutter_svg`.
- The same semantic typically has `regular` and `filled` variants, suitable for bottom navigation and selected states.
- Visually lighter than Material Icons; does not naturally carry a Material You flavor.

Not recommended as primary choice for this project:

| Icon Library | Conclusion | Reason |
|---|---|---|
| Material Icons | No longer use | Style pulls the interface back to Material; `uses-material-design: true` also retains Material icon font |
| Lucide | Can be minimal alternative | Very nice-looking, but more linear/light decor; few filled states; navigation selected states less convenient than Fluent |
| Phosphor | Can be alternative | Multiple weights, but fewer icons; some school/academic semantics may need substitutes |
| Remix Icon | Very comprehensive coverage | Good style, but pub package maintenance source less stable than Fluent; suitable as alternative, not recommended to mix |
| Iconoir | Not primary choice | SVG widget approach introduces `flutter_svg`, higher migration cost |

Final rule:

> This project only allows business code to use `AppIcons.xxx`; pages must not directly import `fluentui_system_icons`, and must not continue writing `Icons.xxx` directly.

---

## 2. pubspec Modifications

Add:

```yaml
dependencies:
  fluentui_system_icons: ^1.1.273
```

When the project has completely removed all `Icons.*`, consider:

```yaml
flutter:
  uses-material-design: false
```

Note:

- `uses-material-design: false` does not mean `package:flutter/material.dart` cannot be imported.
- It primarily affects Material icon font and other resources.
- Must confirm the entire project has no `Icons.*` before turning it off, otherwise icons will break.

Check command:

```bash
rg -n "Icons\." lib
```

---

## 3. Unified Export: app_icons.dart

Add:

```text
lib/ui/app_icons.dart
```

Reference content:

```dart
/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/widgets.dart';

class AppIcons {
  const AppIcons._();

  // Navigation
  static const IconData home = FluentIcons.home_24_regular;
  static const IconData homeFilled = FluentIcons.home_24_filled;
  static const IconData calendar = FluentIcons.calendar_ltr_24_regular;
  static const IconData calendarFilled = FluentIcons.calendar_ltr_24_filled;
  static const IconData apps = FluentIcons.apps_24_regular;
  static const IconData appsFilled = FluentIcons.apps_24_filled;
  static const IconData settings = FluentIcons.settings_24_regular;
  static const IconData settingsFilled = FluentIcons.settings_24_filled;

  // Common actions
  static const IconData refresh = FluentIcons.arrow_clockwise_24_regular;
  static const IconData filter = FluentIcons.filter_24_regular;
  static const IconData search = FluentIcons.search_24_regular;
  static const IconData close = FluentIcons.dismiss_24_regular;
  static const IconData check = FluentIcons.checkmark_24_regular;
  static const IconData chevronRight = FluentIcons.chevron_right_24_regular;
  static const IconData chevronDown = FluentIcons.chevron_down_24_regular;
  static const IconData chevronUp = FluentIcons.chevron_up_24_regular;

  // Account / settings
  static const IconData user = FluentIcons.person_24_regular;
  static const IconData password = FluentIcons.lock_closed_24_regular;
  static const IconData visible = FluentIcons.eye_24_regular;
  static const IconData invisible = FluentIcons.eye_off_24_regular;
  static const IconData logout = FluentIcons.sign_out_24_regular;
  static const IconData info = FluentIcons.info_24_regular;
  static const IconData mail = FluentIcons.mail_24_regular;
  static const IconData device = FluentIcons.device_meeting_room_24_regular;
  static const IconData privacy = FluentIcons.shield_lock_24_regular;
  static const IconData palette = FluentIcons.color_24_regular;
  static const IconData bug = FluentIcons.bug_24_regular;
  static const IconData update = FluentIcons.arrow_download_24_regular;
  static const IconData notification = FluentIcons.alert_24_regular;
  static const IconData location = FluentIcons.location_24_regular;

  // Academic features
  static const IconData student = FluentIcons.person_accounts_24_regular;
  static const IconData exam = FluentIcons.clipboard_task_24_regular;
  static const IconData schedule = FluentIcons.clock_24_regular;
  static const IconData school = FluentIcons.hat_graduation_24_regular;
  static const IconData credit = FluentIcons.chart_pie_24_regular;
  static const IconData grade = FluentIcons.trophy_24_regular;
  static const IconData course = FluentIcons.book_24_regular;
  static const IconData teacher = FluentIcons.person_24_regular;
  static const IconData classroom = FluentIcons.building_24_regular;
  static const IconData date = FluentIcons.calendar_24_regular;

  // Theme mode
  static const IconData themeSystem = FluentIcons.desktop_24_regular;
  static const IconData themeLight = FluentIcons.weather_sunny_24_regular;
  static const IconData themeDark = FluentIcons.weather_moon_24_regular;

  // States
  static const IconData error = FluentIcons.error_circle_24_regular;
  static const IconData offline = FluentIcons.wifi_off_24_regular;
  static const IconData sync = FluentIcons.arrow_sync_24_regular;
  static const IconData empty = FluentIcons.box_24_regular;
}
```

Notes:

- The icon names above should be based on IDE autocomplete. If a specific Fluent icon name does not exist, prefer to find a synonymous icon; do not fall back directly to `Icons.*`.
- `AppIcons` is the sole export. When changing icon libraries later, only modify this one file.
- If a page temporarily cannot find an icon, first add a semantic name in `AppIcons`; do not import the icon library in the page.

---

## 4. Migration Mapping

| Current Material Icon | New Semantic Name | Usage |
|---|---|---|
| `Icons.home_outlined` | `AppIcons.home` | Bottom nav: Home |
| `Icons.home_rounded` | `AppIcons.homeFilled` | Bottom nav: Home selected |
| `Icons.calendar_view_week_outlined` | `AppIcons.calendar` | Bottom nav: Schedule |
| `Icons.calendar_view_week_rounded` | `AppIcons.calendarFilled` | Bottom nav: Schedule selected |
| `Icons.apps_outlined` | `AppIcons.apps` | Bottom nav: Features |
| `Icons.apps_rounded` | `AppIcons.appsFilled` | Bottom nav: Features selected |
| `Icons.settings_outlined` | `AppIcons.settings` | Bottom nav: Settings |
| `Icons.settings_rounded` | `AppIcons.settingsFilled` | Bottom nav: Settings selected |
| `Icons.refresh_outlined` / `Icons.refresh` | `AppIcons.refresh` | Refresh |
| `Icons.tune_outlined` | `AppIcons.filter` | Filter |
| `Icons.chevron_right_rounded` | `AppIcons.chevronRight` | List navigation |
| `Icons.keyboard_arrow_down_rounded` | `AppIcons.chevronDown` | Expand / Dropdown |
| `Icons.keyboard_arrow_up` | `AppIcons.chevronUp` | Collapse |
| `Icons.check_rounded` | `AppIcons.check` | Selected |
| `Icons.person_outline` / `Icons.account_circle_outlined` | `AppIcons.user` | User / Student info |
| `Icons.lock_outline_rounded` | `AppIcons.password` | Password |
| `Icons.visibility_outlined` | `AppIcons.visible` | Show password |
| `Icons.visibility_off_outlined` | `AppIcons.invisible` | Hide password |
| `Icons.logout_rounded` | `AppIcons.logout` | Log out |
| `Icons.info_outline_rounded` | `AppIcons.info` | About / Info |
| `Icons.email` | `AppIcons.mail` | Email |
| `Icons.school_outlined` | `AppIcons.school` | School / Progress |
| `Icons.assignment_outlined` | `AppIcons.exam` | Exam |
| `Icons.schedule_outlined` / `Icons.schedule_rounded` | `AppIcons.schedule` | Time |
| `Icons.pie_chart_outline` | `AppIcons.credit` | Credit progress |
| `Icons.workspace_premium_outlined` | `AppIcons.grade` | Grade |
| `Icons.calendar_month_rounded` / `Icons.today_rounded` | `AppIcons.date` | Date |
| `Icons.person_rounded` | `AppIcons.teacher` | Teacher |
| `Icons.place_rounded` | `AppIcons.location` | Location |
| `Icons.location_city_rounded` | `AppIcons.classroom` | Campus / Classroom |
| `Icons.brightness_auto_rounded` | `AppIcons.themeSystem` | Follow system |
| `Icons.light_mode_rounded` | `AppIcons.themeLight` | Light mode |
| `Icons.dark_mode_rounded` | `AppIcons.themeDark` | Dark mode |
| `Icons.error_outline_rounded` | `AppIcons.error` | Error |
| `Icons.wifi_off_rounded` | `AppIcons.offline` | Network error |
| `Icons.sync_rounded` | `AppIcons.sync` | Sync |

---

## 5. Code Rules

### 5.1 Pages Must Not Directly Import Icon Library

Prohibited:

```dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
```

Pages only allowed:

```dart
import 'package:class_tool/ui/app_icons.dart';
```

### 5.2 Must Not Continue Using Material Icons

Prohibited:

```dart
Icon(Icons.refresh_outlined)
```

Changed to:

```dart
Icon(AppIcons.refresh)
```

### 5.3 Bottom Navigation Must Use regular / filled Pairing

Example:

```dart
AppBottomTabItem(
  icon: AppIcons.home,
  selectedIcon: AppIcons.homeFilled,
  label: 'Home',
)
```

### 5.4 Normal List Icons Only Use regular

```dart
AppTile(
  icon: AppIcons.exam,
  title: 'Exam Schedule',
)
```

Do not use filled icons extensively in lists.

---

## 6. Completion Criteria

After completion, execute:

```bash
rg -n "Icons\." lib
rg -n "fluentui_system_icons" lib/pages lib/widgets lib/utils
flutter analyze
```

Expected:

- First command has no output.
- Second command has no output.
- `fluentui_system_icons` only appears in `lib/ui/app_icons.dart`.
- analyze produces no new issues.
