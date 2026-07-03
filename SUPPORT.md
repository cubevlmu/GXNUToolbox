# Support

## Getting Help

You can provide feedback or suggestions through the following methods:

- Bug: Submit an Issue using the Bug Report template.
- New Feature: Submit an Issue using the Feature Request template.
- Performance Issues: Submit an Issue using the Performance Report template.
- Refactoring Tasks: Submit an Issue using the Refactor Task template.
- Simple Questions: Describe the background, current behavior, and expected outcome in an Issue.

## Please Confirm Before Submitting

Before submitting an issue, it is recommended to check:

- Whether you are using the latest version or the latest `main` / `dev` branch;
- Whether you have run `flutter pub get`;
- Whether `flutter analyze` passes;
- Whether the issue is caused by school interface, network environment, verification code, or unified identity authentication policy changes;
- Whether account, Cookie, Token, and schedule privacy information in logs has been removed.

## Issue Categories

### Login Related

Please describe:

- Device system version;
- App version or commit;
- Whether verification code, remote login, or password error limit is triggered;
- Whether it is a first-time login or automatic login restore;
- Sanitized error information.

Do not submit real student ID, password, verification code, Cookie, or complete traffic captures.

### Schedule Related

Please describe:

- Current semester and week;
- Whether you have manually refreshed;
- Whether only some courses are missing;
- Whether in offline mode;
- For course data examples, please use Mock content to replace real names, locations, and courses.

### UI/Experience Related

Please describe:

- Device model, system version, screen size;
- Dark/Light mode;
- Page path;
- Screenshots or recordings, making sure to obscure personal information.

### Performance Related

Please describe:

- Debug / Profile / Release mode;
- Page where the issue occurs;
- Specific symptoms, such as slow startup, scroll lag, page transition lag, duplicate requests, memory growth;
- Quantifiable data, such as time, frame rate, request count.

## Content Not Suitable for Discussion in Public Issues

- School system interface bypassing, attacks, batch requests, or stress testing;
- Unauthorized account access;
- Real login credentials and complete authentication data;
- Undisclosed security vulnerability details.
