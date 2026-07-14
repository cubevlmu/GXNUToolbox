# GXNU Class Tool UI Documentation Index

It is recommended to copy this directory directly into the project:

```text
docs/ui/
```

File descriptions:

- `UI_STYLE_GUIDE.md`: Overall design style, colors, spacing, prohibited items, acceptance criteria.
- `UI_COMPONENT_SPEC.md`: Project custom UI component specifications and page replacement scope.
- `UI_ICON_GUIDE.md`: Icon library selection, `AppIcons` encapsulation, Material Icons migration table.
- `UI_REFACTOR_AGENT_TASKS.md`: Detailed execution task list for code agents.

Design direction for this round:

```text
GXNU Blue Minimal / Campus Tool Lightweight Interface
```

Core requirements:

- No longer directly use Material high-level visual components.
- No longer directly use `Icons.*`.
- All business pages only compose project custom UI primitives.
- Unified blue primary brand, light borders, low decoration, no obvious ripple effects, no large primaryContainer color blocks.
