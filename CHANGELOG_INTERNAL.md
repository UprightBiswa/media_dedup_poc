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
- Added ObjectBox 5.x setup and generated model/code.
- Added ObjectBox Admin for Android debug builds.
- Added persisted media index with `MediaItemEntity`.
- Added persisted job snapshot with `ProcessingJobEntity`.
- Added repository layer for scan persistence and simple incremental reuse.
- Added thumbnail cache generation for scanned media.
- Added visible cluster previews on the dashboard.
- Added cached dashboard reload from ObjectBox on app start.
- Added stale-file cleanup for rescanned sources.
- Added nested-folder scan reuse for unchanged indexed files.
- Added Android MediaPipe Image Embedder method-channel bridge.
- Downloaded the official MobileNet-V3 small image-embedder model into Android assets.
- Fixed the MediaPipe Android result accessor to use `embeddingResult().embeddings().first().floatEmbedding()`.
- Disabled Kotlin incremental compilation in Gradle to work around the Windows cache-root compiler bug.
- Added repository tracking files:
  - `PROJECT_STATUS.md`
  - `TODO.md`
  - `CHANGELOG_INTERNAL.md`
