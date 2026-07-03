# AI Agent Guidelines

This document is for reference when using AI agents to assist development, especially suitable for agents less proficient in large-scale engineering reasoning.

## Tasks Given to Agents Should Include

When issuing each task, try to include:

- Modules to modify;
- Modules not allowed to modify;
- Current problem;
- Target behavior;
- Verification commands;
- Whether refactoring is allowed;
- Whether public API changes are allowed;
- Whether UI screenshot comparison is involved.

## Recommended Task Template

```md
You are modifying GXNUTool, a Flutter/Dart course schedule application.

Goal: Fix duplicate schedule requests caused by repeated login restore triggers.

Scope:
- Allow modifying related files in lib/data, lib/pages/*/controller, lib/utils.
- Do not allow large-scale replacement of GetX, Dio, or Hive.
- Do not allow deletion of existing login, schedule, or settings features.

Requirements:
1. Login restore should only have one main flow.
2. Concurrent calls should reuse the same Future or explicitly lock.
3. Schedule sync must not be triggered repeatedly during initialization of multiple pages.
4. All logs must be sanitized.
5. Maintain buildability for Android and Windows.

After completion, run:
- dart format .
- flutter analyze
- flutter test

Output:
- List of modified files;
- Core change description;
- Risk points;
- Executed checks.
```

## Task Decomposition Principles

Do not give agents overly large mixed tasks at once. Recommended breakdown:

1. Analyze the problem and list items;
2. Fix data/api layer;
3. Fix repository;
4. Fix controller lifecycle;
5. Optimize UI;
6. Supplement tests;
7. Update documentation.

## High-Risk Tasks

For the following tasks, the agent must propose a plan before modifying code:

- Replacing state management;
- Replacing networking library;
- Modifying login flow;
- Modifying local storage structure;
- Introducing background tasks;
- Large-scale UI rewrite;
- Cross-platform build configuration adjustments.

## Code Review Focus Points

After agent generates code, focus on:

- Whether non-existent APIs are fabricated;
- Whether existing functionality is deleted;
- Whether business logic is stuffed into UI;
- Whether error handling is ignored;
- Whether sensitive logs are output;
- Whether overly heavy dependencies are introduced;
- Whether it only runs in Debug mode;
- Whether the Windows build is broken.

## Recommended Agent Output Format

```md
## Modification Overview

## Modified Files

## Key Implementation

## Verification Results

## Risks and Follow-up Suggestions
```

## Things Agents Must Not Do

- Submit real accounts and passwords for testing;
- Generate traffic captures or bypass school system security policies;
- Batch request school interfaces for stress testing;
- Place unsanitized logs directly into the repository;
- Add closed-source or unclear-license resources without confirmation.
