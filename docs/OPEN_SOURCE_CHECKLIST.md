# Open Source Checklist

If GXNUTool is to be publicly released later, it is recommended to check against the following checklist.

## License

- [ ] Choose a formal open source license.
- [ ] Add `LICENSE` file in the root directory.
- [ ] Declare the license in README.
- [ ] Confirm that third-party resources, icons, fonts, and images are allowed to be distributed with the project.

Common choices:

- MIT: Permissive, suitable for personal tool projects.
- Apache-2.0: Permissive, includes patent grant clauses.
- GPL series: Requires derivative works to comply with the same open source license; more restrictive.

Before making a clear choice, it is not recommended to add license text by default.

## Sensitive Information

- [ ] Repository history does not contain accounts, passwords, Cookies, Tokens.
- [ ] Repository history does not contain real course schedules, real interface responses, or traffic capture files.
- [ ] Issues, PRs, and Release attachments do not contain privacy data.
- [ ] Android signing files and keys are not in the repository.
- [ ] `.gitignore` covers build artifacts, symbols, keys, and cache files.

## Documentation

- [ ] README explains project purpose and limitations.
- [ ] README explains build methods.
- [ ] README explains privacy considerations.
- [ ] `CONTRIBUTING.md` is complete.
- [ ] `SECURITY.md` is complete.
- [ ] `CHANGELOG.md` has initial version records.

## Engineering Quality

- [ ] `flutter analyze` passes.
- [ ] `flutter test` passes or explains that no tests exist yet.
- [ ] Android debug build passes.
- [ ] Android release build passes.
- [ ] Windows build verified as needed.

## GitHub Settings

- [ ] Enable Issue templates.
- [ ] Enable PR template.
- [ ] Configure branch protection.
- [ ] Configure Dependabot or periodic dependency checks.
- [ ] Configure GitHub Security Advisories.
- [ ] Set repository description, topics, and project icon.

## Risk Warnings

Before public release, confirm that the project will not be misused for:

- Unauthorized access to school systems;
- Batch requests or stress testing of school interfaces;
- Collecting others' accounts or schedules;
- Bypassing unified identity authentication policies.

The README can explicitly state: This project is only for personal course schedule viewing and learning exchange; it does not provide any ability to bypass authentication or attack interfaces.
