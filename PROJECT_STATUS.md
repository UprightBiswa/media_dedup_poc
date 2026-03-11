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

## Current behavior
- App opens.
- Folder picker works.
- Analyze runs through the current local prototype pipeline.
- Similarity pipeline is still prototype-level:
  - file scan
  - cached thumbnails
  - exact hash
  - dHash-like perceptual hash
  - heuristic embedding
  - edge building
  - clustering
  - rule-based synthesis

## Not implemented yet
- ObjectBox entities and repositories
- Paginated gallery scan with `photo_manager`
- Thumbnail cache
- Incremental re-scan
- Native MediaPipe Image Embedder bridge
- Real embedding cache
- Cluster detail screen
- Settings/debug screen
- Isolate-based batching
- Resume interrupted jobs

## Immediate next milestone
- Finish Milestone 2: persisted summary loading, removed-file cleanup, and paginated media indexing
