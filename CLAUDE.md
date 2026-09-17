# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Conta Paga: a Flutter app for personal tracking of recurring bills to pay/receive, organized by month. Portuguese (pt-BR), BRL, offline-only, no login, Android-only launch (iOS deferred). Package name `contapaga`, applicationId `br.com.mutumsoft.contapaga`, minSdk 24.

The project is mid-implementation, tracked phase-by-phase in [PLANO_IMPLEMENTACAO_E_PUBLICACAO.md](PLANO_IMPLEMENTACAO_E_PUBLICACAO.md). Check that file's phase checklist before starting work to know what's actually built vs. planned. Phase 2 (Flutter base/tooling) is done; the financial domain, persistence schema, full UI flows, and recurrence engine (phases 3–6) are not yet implemented — only month navigation and settings exist today.

Key docs, read as needed rather than duplicated here:
- [CONTEXTO_DO_PROJETO.md](CONTEXTO_DO_PROJETO.md) — product context, gaps between the HTML prototype and approved rules.
- [docs/decisoes/FASE_0_PRODUTO.md](docs/decisoes/FASE_0_PRODUTO.md) — approved product/business rules.
- [docs/decisoes/ADR_001_BASE_LOCAL_E_EVOLUCAO_PRO.md](docs/decisoes/ADR_001_BASE_LOCAL_E_EVOLUCAO_PRO.md) — architecture decision record (local-first, future Pro/cloud path).
- [docs/decisoes/FASE_2_BASE_TECNICA.md](docs/decisoes/FASE_2_BASE_TECNICA.md) — technical base decisions and verification evidence.
- [handoff/README.md](handoff/README.md) — functional reference (flows, fields, copy) from the HTML prototype. The prototype's visual style (Industry/Barlow/Lucide) and its data-model shortcuts (in-memory state, month keys without year, sine-wave fake variable values) are **not** requirements — only the flows and field lists are.

## Commands

Flutter version is pinned: `.fvmrc` and CI both use `3.47.4`. If FVM is installed, prefix commands with `fvm`.

```sh
flutter pub get --enforce-lockfile
flutter run --dart-define=APP_ENV=development
```

Without `APP_ENV`, the app defaults to `production`. Each environment uses a separate SQLite file (`contapaga_development.db` vs `contapaga.db`) — never point dev tooling at the production DB name.

Verification pipeline (mirrors `.github/workflows/flutter.yml`):

```sh
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test
flutter test integration_test/storage_test.dart -d <device-id>   # requires a running emulator/device
flutter build apk --debug --dart-define=APP_ENV=development
```

Run a single test file: `flutter test test/month_controller_test.dart`. Run a single test by name: `flutter test --plain-name "test description"`.

The integration test uses its own `contapaga_integration_test.db` and deletes it on completion — safe to run repeatedly. `tool/notification_probe.dart` is a standalone debug entry point (not reachable from `lib/main.dart`, throws in release mode) for manually verifying local-notification scheduling, permission-denied behavior, and the reposting window; run it with `flutter run -t tool/notification_probe.dart -d <device-id>`.

## Architecture

Layering follows ADR 001: domain logic must stay independent of Flutter, SQLite, and any future login/network concerns, so it can be tested without a device and swapped onto remote adapters later without rewriting business rules.

- `lib/app/` — composition root: `bootstrap.dart` wires environment → storage → repository → controller and calls `runApp`; catches startup failures and shows a retry screen instead of crashing. `app_environment.dart` defines the development/production split and DB filenames.
- `lib/core/` — cross-cutting contracts and adapters, each behind an interface so tests can fake them:
  - `time/clock.dart` — `Clock` interface + `SystemClock`; inject rather than call `DateTime.now()` directly, since financial dates must be recalculated as civil dates, never derived from UTC.
  - `storage/key_value_store.dart` — `KeyValueStore` interface for small preferences only (never financial entities); `sqlite_key_value_store.dart` is the SQLite adapter.
  - `notifications/notification_scheduler.dart` — `NotificationScheduler` interface (`isEnabled`/`requestPermission`/`schedule`/`cancel`); `android_notification_scheduler.dart` implements it via `flutter_local_notifications`. Scheduling uses `inexactAllowWhileIdle` with a capped reposting window (~30 reminders) reconciled on app resume — there is no exact-alarm permission and no unbounded scheduling.
- `lib/features/<feature>/` — one directory per feature, split into `domain/` (repository interfaces), `data/` (concrete adapters), and `presentation/` (controller + page). Currently only `mes/` (month selection, backed by `MonthController extends ChangeNotifier`) and `ajustes/` (settings/about) exist. Follow this same three-way split for new features (e.g. a future `recorrencias/`, `historico/`).
- State management: `ChangeNotifier` injected by constructor (no service locator, no external state package). Navigation: `Navigator`/`MaterialPageRoute`, no routing package. Don't introduce a state/routing library without a demonstrated need — this was a deliberate phase-2 decision.
- `test/support/fakes.dart` — shared fakes for domain contracts (clock, repositories), used across unit tests instead of mocking frameworks.
- `integration_test/` — exercises real plugins (SQLite) end-to-end; requires a connected device/emulator, unlike `test/`.

## Domain rules to respect when extending the financial model

These are approved product decisions (see `docs/decisoes/FASE_0_PRODUTO.md` and `CONTEXTO_DO_PROJETO.md`), not the prototype's simplified behavior — do not copy the HTML prototype's shortcuts when implementing phases 3+:

- Money must use exact representation (integer cents or exact decimal) — never floating point.
- Dates are civil dates; a series/occurrence's identity must survive edits, and multiple occurrences of the same series can exist in the same month (don't key solely by series+month).
- Occurrence generation must be idempotent and bounded (don't materialize infinite daily series).
- Variable-value forecasts use the average of previously paid occurrences over the trailing six competências, not a synthetic/random value.
- A write to financial data must persist transactionally before any success confirmation is shown; notification reconciliation happens after the financial write succeeds, and its failure must not roll back that write.

## UI direction

Use stock Flutter Material widgets in their original form; the only customization is the color theme via `ThemeData`/`ColorScheme`. This supersedes the prototype's Industry visual style entirely — do not port its fonts, icon set, corner styles, or fixed pixel dimensions. Build custom widgets only when a real need can't be met by composing existing Material components.
