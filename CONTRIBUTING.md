# Contributing to Pyago

Thank you for your interest in contributing! This document explains how to get
set up, the standards we hold code to, and the process for getting a change
merged.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Environment Setup](#environment-setup)
3. [Flavors & Configuration](#flavors--configuration)
4. [Development Workflow](#development-workflow)
5. [Code Standards](#code-standards)
6. [Testing](#testing)
7. [Pull Request Process](#pull-request-process)
8. [Commit Message Format](#commit-message-format)

---

## Getting Started

```bash
# 1. Fork the repository on GitHub, then clone your fork
git clone https://github.com/<your-handle>/pyago.git
cd pyago

# 2. Add the upstream remote
git remote add upstream https://github.com/your-org/pyago.git

# 3. Install Flutter (3.x stable) if you haven't already
# https://docs.flutter.dev/get-started/install

# 4. Install dependencies
flutter pub get

# 5. Run the code generator (required after any model or provider change)
dart run build_runner build --delete-conflicting-outputs

# 6. Verify everything is green
flutter analyze
flutter test
```

---

## Environment Setup

### Pre-commit hooks (recommended)

We use [Lefthook](https://github.com/evilmartians/lefthook) to enforce
formatting and static analysis locally before every commit:

```bash
# Install Lefthook (macOS / Linux)
brew install lefthook        # macOS
# or: npm install -g @evilmartians/lefthook

# Windows (Scoop)
scoop install lefthook

# Activate the hooks in this repo
lefthook install
```

After installation, `dart format` and `flutter analyze` run automatically on
every `git commit`. CI enforces the same checks — fixing them locally is faster.

### VS Code

Open the repo in VS Code and accept the recommended extensions prompt
(`.vscode/extensions.json`). The `.vscode/launch.json` file provides three
pre-configured launch profiles — **Pyago (dev)**, **Pyago (staging)**, and
**Pyago (production)** — each passing the correct `--dart-define` flags.

### Android Studio / IntelliJ

Create a run configuration manually and add:
```
--dart-define=PYAGO_FLAVOR=dev
```
to the "Additional run args" field. See `.dart_defines/dev.json` for the full
set of environment values used in each flavor.

---

## Flavors & Configuration

| Flavor | `PYAGO_FLAVOR` | Backend | Mock data |
|---|---|---|---|
| dev | `dev` (default) | n/a | ✅ |
| staging | `staging` | `https://staging.api.pyago.app` | ❌ |
| production | `production` | `https://api.pyago.app` | ❌ |

The **only file** you need to touch to point the app at a real backend is
`lib/core/config/app_config.dart`. Everything upstream is interface-driven and
will work without any further changes.

---

## Development Workflow

1. Pull latest from `upstream/develop`: `git pull upstream develop`
2. Create a branch: `git checkout -b feat/my-feature` or `fix/issue-123`
3. Make your changes (see Code Standards below)
4. Run `dart run build_runner build --delete-conflicting-outputs` if you
   changed any annotated providers or models
5. Run `flutter test` — all tests must pass
6. Run `dart format .` and `flutter analyze --fatal-infos`
7. Push and open a PR against `develop` (not `main`)

---

## Code Standards

### Architecture

Every feature lives under `lib/features/<feature>/` with three layers:

```
lib/features/<feature>/
├── data/
│   ├── models/          # DTOs (json_serializable / freezed)
│   └── repositories/    # Implementations of domain interfaces
│       ├── mock_<x>_repository.dart
│       └── http_<x>_repository.dart   (when backend exists)
├── domain/
│   ├── models/          # Pure domain models (freezed)
│   └── repositories/    # Abstract interfaces
└── presentation/
    ├── providers/        # Riverpod notifiers (@riverpod annotation)
    ├── screens/          # One file per route
    └── widgets/          # Feature-specific widgets
```

Shared UI components belong in `lib/core/shared/widgets/`.
Cross-feature utilities belong in `lib/core/`.
**Nothing in `presentation/` should import from another feature's
`data/` or `domain/` layer directly** — go through providers.

### Dart style

- Use `package:` imports everywhere (enforced by `always_use_package_imports`)
- Avoid `dynamic` (enforced by `avoid_dynamic_calls`)
- All `Stream` subscriptions must be cancelled (enforced by `cancel_subscriptions`)
- All `StreamController`s must be closed (enforced by `close_sinks`)
- `await` every `Future` that matters (enforced by `unawaited_futures`)
- Run `dart format .` — line length is 100

### Riverpod

- Use `@riverpod` annotation + code generation for all providers
- Prefer `@Riverpod(keepAlive: true)` only for truly global singletons (router, config)
- Never call `ref.read` inside `build()` — use `ref.watch`
- Business logic belongs in `Notifier`/`AsyncNotifier`, not in widgets

---

## Testing

| Type | Location | Command |
|---|---|---|
| Unit | `test/` | `flutter test` |
| Widget | `test/widgets/` | `flutter test` |
| Golden | `test/golden/` | `flutter test --update-goldens` (first run only) |
| Integration | `integration_test/` | `flutter test integration_test/` |

**Golden baseline workflow:** golden `.png` files live in `test/golden/goldens/`.
If you change a widget that has a golden test, regenerate baselines with
`flutter test --update-goldens test/golden/` and commit the new PNGs.

Coverage is uploaded to Codecov on every CI run. We don't enforce a hard
minimum yet, but please don't reduce coverage for the files you touch.

---

## Pull Request Process

1. **Title** — follow Conventional Commits: `feat: add X`, `fix: correct Y`, `docs: update Z`
2. **Description** — fill in the PR template. Link the related issue with `Closes #<number>`
3. **Size** — keep PRs small and focused. A PR that changes > 400 lines of
   non-generated code will be asked to split
4. **Review** — at least one approval is required before merge
5. **CI must be green** — all three CI jobs (analyze + test, build, integration) must pass
6. **No merge commits** — rebase against `develop` before merging; we use squash merges

---

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>

[optional body]

[optional footer: Closes #issue]
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`

**Examples:**
```
feat(feed): add session-cap "you're caught up" notice
fix(chat): cancel stream controllers on provider dispose
docs(readme): add architecture diagram and badge row
chore(deps): upgrade flutter_riverpod to 2.6.0
```
