# TODO

## Now
- Extend entities for embeddings, similarity edges, and clusters.
- Replace direct folder-only scan flow with persisted paginated media-source indexing.
- Split exact hash and perceptual hash into distinct services.
- Add cluster detail page with larger thumbnails and metadata.
- Add progress-safe batching for large folder scans.

## Next
- Integrate `photo_manager` for paginated gallery image scanning.
- Add candidate pre-filtering by file size before SHA-256.
- Add larger gallery-style cluster preview screen.
- Persist similarity edges and clusters.

## Later
- Add Android native MediaPipe Image Embedder bridge.
- Cache embeddings by content version key.
- Add cosine similarity persistence.
- Add isolate runners for hashing/comparison.
- Add resumable jobs and recovery on restart.
