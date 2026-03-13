# Media Dedup POC Status

## Current milestone
- Milestone 2 in progress: local persistence and scan/index caching.

## Implemented so far
- Created a separate Flutter project with Android/iOS/web/desktop folders.
- Added feature-first Dart structure for scanning, hashing, similarity, and synthesis.
- Built the first dashboard flow:
  - select folder
  - analyze
  - show stage, progress, cluster cards
- Added central dependency wiring with GetX bindings.
- Added `ProcessingOrchestrator` as the single pipeline owner.
- Added `ProcessingJob` stage model for pipeline state.
- Added app logger.
- Added Android permission fallback for user-selected folder analysis.
- Added Android manifest media/storage permissions.
- Added ObjectBox local database initialization.
- Added ObjectBox Admin startup for Android debug builds.
- Added `MediaItemEntity` and `ProcessingJobEntity`.
- Added repositories for persisted media index and job snapshot state.
- Persisted scan results and reuse of unchanged hashed/embedded items by content version key.
- Added thumbnail cache generation during scan.
- Added visible cluster previews with representative and item thumbnails.
- Added nested-folder rescan reuse so unchanged files are not fully reindexed each time.
- Added stale-record cleanup for files removed from a rescanned source.
- Added dashboard reload from cached ObjectBox media index on app start.
- Added Android MediaPipe method-channel bridge for real image embeddings.
- Added official MobileNet-V3 small image-embedder model to Android assets.
- Fixed MediaPipe result accessors against the resolved Android API.
- Disabled Kotlin incremental compilation for this project to avoid the Windows cache-path compile bug.
- Added visible embedding-backend status in the dashboard.
- Added tap-to-preview image inspection with full view and file path copy.
- Fixed Android release build by pinning the MediaPipe dependency and adding release-safe R8 rules.
- Disabled release minification/resource shrinking because MediaPipe crashes under the current R8-obfuscated release build.

## Current behavior
- App opens.
- Folder picker works.
- Analyze runs through the current local prototype pipeline.
- Similarity pipeline is still prototype-level:
  - file scan
  - cached thumbnails
  - exact hash
  - dHash-like perceptual hash
  - Android MediaPipe embedding with heuristic fallback if native model is unavailable
  - edge building
  - clustering
  - rule-based synthesis

## Not implemented yet
- Paginated gallery scan with `photo_manager`
- Persisted similarity edges and clusters
- Removed-file cleanup reporting in UI
- Native MediaPipe runtime validation under an obfuscated/minified release build
- Real embedding cache
- Cluster detail screen
- Settings/debug screen
- Isolate-based batching
- Resume interrupted jobs

## Immediate next milestone
- Split exact/perceptual hash services and add cluster detail screen
- Validate MediaPipe embeddings on device and persist real embedding vectors
