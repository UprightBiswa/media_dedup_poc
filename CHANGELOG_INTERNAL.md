# Internal Change Log

## 2026-03-11
- Generated full Flutter project scaffolding in `media_dedup_poc`.
- Added app shell, routes, theme, dashboard, and initial analysis services.
- Refactored app startup to use `InitialBinding`.
- Added `ProcessingOrchestrator` and `ProcessingJob`.
- Added `AppLogger`.
- Added `MediaPermissionService` and `MediaSourceService`.
- Fixed Android folder-analysis permission flow by:
  - adding manifest permissions
  - allowing explicit user-selected folder analysis to continue on Android
- Added repository tracking files:
  - `PROJECT_STATUS.md`
  - `TODO.md`
  - `CHANGELOG_INTERNAL.md`
