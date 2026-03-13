# TODO

## Now
- Extend entities for embeddings, similarity edges, and clusters.
- Replace direct folder-only scan flow with persisted paginated media-source indexing.
- Split exact hash and perceptual hash into distinct services.
- Add full cluster detail page with per-item scores and metadata diff.
- Add progress-safe batching for large folder scans.
- Validate Android MediaPipe build/run and persist real embedding vectors.

## Next
- Integrate `photo_manager` for paginated gallery image scanning.
- Add candidate pre-filtering by file size before SHA-256.
- Add larger gallery-style cluster preview screen.
- Persist similarity edges and clusters.
- Add open-in-system-file-view action where supported.

## Later
- Add Android native MediaPipe Image Embedder bridge.
- Cache embeddings by content version key.
- Add cosine similarity persistence.
- Add isolate runners for hashing/comparison.
- Add resumable jobs and recovery on restart.
