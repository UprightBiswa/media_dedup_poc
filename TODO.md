# TODO

## Now
- Split exact hash and perceptual hash into distinct services.
- Persist similarity edges and clusters.
- Add full cluster detail page with per-item scores and metadata diff.
- Add progress-safe batching for large folder scans.
- Add live counters for discovered, hashed, embedded, and clustered items.

## Next
- Integrate `photo_manager` for paginated gallery image scanning.
- Add candidate pre-filtering by file size before SHA-256.
- Add larger gallery-style cluster preview screen.
- Add open-in-system-file-view action where supported.
- Add cancelled/paused/resume-safe job state handling.

## Later
- Add isolate runners for hashing/comparison.
- Add resumable jobs and recovery on restart.
- Persist compare history and threshold settings.
- Revisit shrink-safe MediaPipe release configuration if this moves beyond POC.
