# TODO

## Now
- Build ObjectBox setup and entities for media items, embeddings, edges, clusters, and jobs.
- Add repository layer for pending scan/hash/embedding work.
- Replace direct folder scan flow with persisted scan job flow.
- Add thumbnail generation and cached thumbnail path storage.

## Next
- Integrate `photo_manager` for paginated gallery image scanning.
- Split exact hash and perceptual hash into distinct services.
- Add candidate pre-filtering by file size before SHA-256.
- Add cluster detail page.

## Later
- Add Android native MediaPipe Image Embedder bridge.
- Cache embeddings by content version key.
- Add cosine similarity persistence.
- Add isolate runners for hashing/comparison.
- Add resumable jobs and recovery on restart.
