# Media Dedup POC Status

## Current milestone
- Milestone 3 in progress: AI embedding persistence, semantic grouping clarity, and pipeline hardening.

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
- Added visible embedding-backend status in the dashboard.
- Added tap-to-preview image inspection with full view and file path copy.
- Fixed Android release build/runtime so MediaPipe works in both debug and release with release shrink disabled.
- Added first-class `EmbeddingRecordEntity` and `EmbeddingRepository` for persisted AI vectors.
- Reused cached embeddings by content version key and active model name.
- Updated semantic similarity so AI groups can still be built even when the same pair is also classified as near-duplicate.
- Added a dedicated `AI Semantic Groups` section on the dashboard.

## Current behavior
- App opens.
- Folder picker works.
- Analyze runs through the current local prototype pipeline.
- Similarity pipeline now includes:
  - file scan
  - cached thumbnails
  - exact hash
  - dHash-like perceptual hash
  - Android MediaPipe embedding with heuristic fallback if native model is unavailable
  - persisted embedding cache lookup
  - edge building for exact, near-duplicate, and semantic similarity
  - clustering
  - rule-based synthesis

## Not implemented yet
- Paginated gallery scan with `photo_manager`
- Persisted similarity edges and clusters
- Removed-file cleanup reporting in UI
- Cluster detail screen with per-item scores and metadata
- Settings/debug screen
- Isolate-based batching for hash/compare work
- Resume interrupted jobs
- Progress counters for discovered/hashed/embedded/clustered

## Immediate next milestone
- Split exact/perceptual hash services
- Persist similarity edges and clusters
- Add cluster detail screen with per-item semantic score
- Add batching and progress counters for large folder scans
