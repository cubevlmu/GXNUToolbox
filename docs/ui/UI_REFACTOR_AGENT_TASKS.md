# GXNU Class Tool UI Refactoring Task Book

> For use by code agents. Goal is to continue completing UI de-Material-ification without modifying Controller / Repo / Model / data.

---

## 0. Overall Constraints

Must follow:

1. Do not modify `lib/data/**`.
2. Do not modify any Controller's business logic, unless it is only adding a read-only getter for UI value passing with no behavioral change, and must be documented.
3. Do not modify Model fields and parsing logic.
4. Do not modify network requests, caching, login flow.
5. Do not introduce large UI frameworks.
6. Do not introduce animation frameworks.
7. Do not replace one Material visual component with another Material visual component.
8. All new UI components go into `lib/ui/`.
9. All pages prioritize reusing `AppSurface`, `AppSection`, `AppTile`.
10. After each batch, run `flutter analyze`.

---

## 1. Existing UI Foundation in Project

Already exists:

```text
lib/ui/app_tokens.dart
lib/ui/app_surface.dart
lib/ui/app_tile.dart
lib/ui/app_section.dart
lib/ui/app_bottom_tab_bar.dart
```

Do not create duplicate components with the same name. Prioritize extending existing components.

Current theme entry point:

```text
lib/class_tool_app.dart
```

Already done:

- Brand color purple changed to blue
- Card 28 -> 14
- Input 22 -> 12
- Button 22 -> 12
- BottomSheet 28 -> 18
- NoSplash replaces InkSparkle
- NavigationBar replaced with AppBottomTabBar
- settings/features/home partially replaced

---

## 2. Batch One: Icon System

### 2.1 Modify pubspec

Add:

```yaml
fluentui_system_icons: ^1.1.273
```

Temporarily keep:

```yaml
uses-material-design: true
```

After the entire project's `Icons.*` is cleared, change to false.

### 2.2 Add New File

Add:

```text
lib/ui/app_icons.dart
```

Reference content from `docs/ui/UI_ICON_GUIDE.md`.

### 2.3 Replacement Scope

Project-wide replacement:

```bash
rg -n "Icons\." lib
```

All `Icons.*` in pages, widgets, utils should become `AppIcons.*`.

Note:

- Do not import `fluentui_system_icons` in pages.
- Only allow `lib/ui/app_icons.dart` to import third-party icon library.
- Default chevron inside `AppTile` should also change to `AppIcons.chevronRight`.
- `AppBottomTabBar` items continue to use IconData; do not change the structure.

Acceptance:

```bash
rg -n "Icons\." lib
rg -n "fluentui_system_icons" lib/pages lib/widgets lib/utils
flutter analyze
```

---

## 3. Batch Two: Fill in Basic Components

Add or extend the following files:

```text
lib/ui/app_button.dart
lib/ui/app_icon_button.dart
lib/ui/app_combo_box.dart
lib/ui/app_segmented_control.dart
lib/ui/app_tag.dart
lib/ui/app_empty_state.dart
lib/ui/app_rail.dart
```

### 3.1 AppButton

Replaces:

```text
FilledButton
FilledButton.icon
FilledButton.tonalIcon
OutlinedButton.icon
ElevatedButton
```

Requirements:

- Support `primary / secondary / danger` three variants.
- Support icon.
- Height 44 or 46.
- Border radius 12.
- No shadow.
- danger default should not have large red background; prefer red text or red border.

### 3.2 AppIconButton

Replaces:

```text
IconButton
IconButton.filled
IconButton.filledTonal
```

Requirements:

- Support `ghost / soft / outline`.
- Size 36x36.
- Icon 18/20.
- Border radius 10.
- No ripple effects.

### 3.3 AppComboBox

Replaces:

```text
DropdownButtonFormField
DropdownButton
DropdownMenu
```

Requirements:

- Generic `AppComboBox<T>`.
- Selected value displayed inside `AppSurface` style shell.
- Right `AppIcons.chevronDown`.
- On tap opens unified bottom sheet.
- Options use `AppTile`.
- Currently selected item trailing shows `AppIcons.check`.
- Do not use Material Dropdown components.

### 3.4 AppSegmentedControl

Replaces:

```text
SegmentedButton
```

Requirements:

- Generic `AppSegmentedControl<T>`.
- Outer layer light surface.
- Selected item primary alpha 0.08.
- Animation 120-180ms.

### 3.5 AppTag

Replaces:

```text
Chip
FilterChip
ChoiceChip
```

Requirements:

- Support neutral / primary / success / warning / danger.
- Height 24-28.
- Border radius pill.
- Font 12 w600.

### 3.6 AppEmptyState

Replaces scattered empty states, error states, retry areas across pages.

Requirements:

- Support icon/title/subtitle/action.
- action uses `AppButton.secondary`.
- Icon uses `AppIcons`.

### 3.7 AppRail

Can implement first; not necessarily integrated.

Requirements:

- Custom component; do not use `NavigationRail`.
- Use the same set of `AppBottomTabItem` or similar structure as `AppBottomTabBar`.
- Width 76.
- Selected state consistent with bottom tab.

---

## 4. Batch Three: Page Replacement

### 4.1 main/view.dart

Goal:

- `AppBottomTabItem` icons all change from `Icons.*` to `AppIcons.*`.
- If doing wide-screen adaptation, use `AppRail`; do not use `NavigationRail`.

Check:

```bash
rg -n "Icons\.|NavigationBar|NavigationRail|BottomNavigationBar" lib/pages/main/view.dart
```

### 4.2 features/view.dart

Goal:

- All feature icons → `AppIcons`.
- Keep `AppSection + AppTile`.
- Do not add Card.

### 4.3 settings/view.dart

Goal:

- All icons → `AppIcons`.
- Logout button → `AppButton.danger` or `AppButton.secondary` danger text.
- `_ThemeModeSelector` can be kept, but internally should use `AppSegmentedControl` or project custom buttons; do not fall back to `SegmentedButton`.

### 4.4 home/view.dart

Goal:

- All `Card` in skeleton → `AppSurface`.
- If `_StatTile` still has Card, also → `AppSurface`.
- Prohibit `primaryContainer` large color blocks.

Check:

```bash
rg -n "Card\(|primaryContainer|Icons\." lib/pages/home/view.dart
```

### 4.5 info/view.dart

Goal:

- `_SectionCard` rename or change implementation to `AppSurface`.
- All `Card` in skeleton → `AppSurface`.
- Retry → `AppEmptyState`.
- Refresh button → `AppIconButton`.
- Icons → `AppIcons`.

Check:

```bash
rg -n "Card\(|FilledButton\.tonalIcon|IconButton|Icons\." lib/pages/info/view.dart
```

### 4.6 time/view.dart

Goal:

- `SegmentedButton<int>` → `AppSegmentedControl<int>`.
- All `Card` → `AppSurface`.
- Retry → `AppEmptyState`.
- Refresh → `AppIconButton`.
- Icons → `AppIcons`.

Check:

```bash
rg -n "SegmentedButton|Card\(|FilledButton\.tonalIcon|IconButton|Icons\." lib/pages/time/view.dart
```

### 4.7 exams/view.dart

Goal:

- AppBar filter/refresh → `AppIconButton`.
- Filter sheet `DropdownButtonFormField` → `AppComboBox`.
- `_ExamCard` → `AppSurface`.
- Skeleton cards → `AppSurface`.
- Retry → `AppEmptyState`.
- Icons → `AppIcons`.

Check:

```bash
rg -n "DropdownButtonFormField|DropdownMenuItem|Card\(|FilledButton\.tonalIcon|IconButton|Icons\." lib/pages/exams/view.dart
```

### 4.8 credit/view.dart

Goal:

- `_SemesterDropdown` → `AppComboBox<String>`.
- SummaryCard → `AppSurface`; do not use `primaryContainer` large background.
- Table footer card → `AppSurface`.
- Retry → `AppEmptyState`.
- Icons → `AppIcons`.

Check:

```bash
rg -n "DropdownButtonFormField|DropdownMenuItem|Card\(|primaryContainer|FilledButton\.tonalIcon|IconButton|Icons\." lib/pages/credit/view.dart
```

### 4.9 progress/view.dart

Goal:

- Semester dropdown → `AppComboBox<String>`.
- `_GroupCard` → `AppSurface`.
- Skeleton group → `AppSurface`.
- Retry → `AppEmptyState`.
- Expand/collapse icon → `AppIcons.chevronDown / chevronUp`.

Check:

```bash
rg -n "DropdownButtonFormField|DropdownMenuItem|Card\(|FilledButton\.tonalIcon|IconButton|Icons\." lib/pages/progress/view.dart
```

### 4.10 query/view.dart

This is the key page for this round.

Goal:

- All filter dropdowns → `AppComboBox`.
- All summary / grade / skeleton cards → `AppSurface`.
- All `Chip` → `AppTag`.
- All buttons → `AppButton`.
- All appbar buttons → `AppIconButton`.
- All icons → `AppIcons`.
- Prohibit `primaryContainer` large color blocks.

Check:

```bash
rg -n "DropdownButtonFormField|DropdownMenuItem|Card\(|Chip\(|FilledButton|IconButton|primaryContainer|Icons\." lib/pages/query/view.dart
```

### 4.11 classes/view.dart

Goal:

- Header `Card` → `AppSurface`.
- Refresh button → `AppIconButton`.
- Icons → `AppIcons`.
- Schedule grid internal course blocks can keep custom Container; do not force AppSurface.

Check:

```bash
rg -n "Card\(|IconButton|Icons\." lib/pages/classes/view.dart
```

### 4.12 schedule_picker_sheet.dart

Goal:

- `ListTile` → `AppTile`.
- Selected trailing icon → `AppIcons.check`.

Check:

```bash
rg -n "ListTile|Icons\." lib/pages/classes/widgets/schedule_picker_sheet.dart
```

### 4.13 course_detail_sheet.dart

Goal:

- All icons → `AppIcons`.
- If internal field row styles are too Material, change to lightweight `_DetailRow`.

### 4.14 login/view.dart

Goal:

- Two `Card` → `AppSurface`.
- Login button → `AppButton.primary`.
- Password visibility button → `AppIconButton` or keep IconButton but must unify style; recommend `AppIconButton`.
- Prefix/suffix icons → `AppIcons`.

Check:

```bash
rg -n "Card\(|FilledButton|IconButton|Icons\." lib/pages/login/view.dart
```

### 4.15 settings/about_page.dart

Goal:

- `Card` → `AppSurface` / `AppSection`.
- `_InfoTile`'s `ListTile` → `AppTile`.
- Icons → `AppIcons`.

Check:

```bash
rg -n "Card\(|ListTile|Icons\." lib/pages/settings/about_page.dart
```

### 4.16 utils/shared_dialog.dart

Goal:

- Icons → `AppIcons`.
- `FilledButton` → `AppButton`.
- Dialog border radius uses AppRadius.lg.

---

## 5. Final Prohibited Items Check

After all changes, execute:

```bash
rg -n "Card\(|ListTile\(|DropdownButtonFormField|DropdownButton\b|DropdownMenu\b|SegmentedButton|Chip\(|FilterChip|ChoiceChip|NavigationBar|NavigationRail|BottomNavigationBar|FilledButton\.tonalIcon|IconButton\.filledTonal|Icons\." lib
```

Expected:

- No output; or only `lib/ui/**` internally with explicitly allowed basic implementations.
- If there is output, each item must be justified for why it was kept.

Then execute:

```bash
flutter analyze
```

Expected:

- No new warnings/errors.
- Existing 7 pre-existing infos may remain, but no new ones may be added.

---

## 6. Commit Message Suggestions

If committing in batches:

```text
refactor(ui): introduce unified non-material design primitives
refactor(ui): replace material icons with app icon tokens
refactor(ui): migrate selection controls to custom components
refactor(ui): replace remaining cards and chips with app components
```

If committing all at once:

```text
refactor(ui): complete unified lightweight design system migration
```
