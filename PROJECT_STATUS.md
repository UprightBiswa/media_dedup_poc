# Media Dedup POC Status

## Current milestone
- Milestone 1 complete: app foundation, bindings, orchestrator, source picker, basic dashboard.

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

## Current behavior
- App opens.
- Folder picker works.
- Analyze runs through the current local prototype pipeline.
- Similarity pipeline is still prototype-level:
  - file scan
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
- Milestone 2: local metadata persistence and paginated scan/index pipeline
