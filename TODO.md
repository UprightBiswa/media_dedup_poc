# TODO

## Now
- Add persisted dashboard summary loading from ObjectBox.
- Extend entities for embeddings, similarity edges, and clusters.
- Replace direct folder-only scan flow with persisted paginated media-source indexing.
- Add cleanup for removed files in a rescanned source.

## Next
- Integrate `photo_manager` for paginated gallery image scanning.
- Split exact hash and perceptual hash into distinct services.
- Add candidate pre-filtering by file size before SHA-256.
- Add cluster detail page.
- Add larger gallery-style cluster preview screen.

## Later
- Add Android native MediaPipe Image Embedder bridge.
- Cache embeddings by content version key.
- Add cosine similarity persistence.
- Add isolate runners for hashing/comparison.
- Add resumable jobs and recovery on restart.
