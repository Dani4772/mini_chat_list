# Mini Chat List

A small Flutter app that fetches posts from [JSONPlaceholder](https://jsonplaceholder.typicode.com/posts),
displays them as a chat-style list, caches them locally with Hive, and supports
pull-to-refresh, search/filter, and offline viewing.

## What's built

- **State management:** Riverpod (`StateNotifier` + derived `Provider`s for filtering).
- **Architecture:** Feature-first, layered as `domain` (entities + repository
  contract) → `data` (models, remote/local datasources, repository impl) →
  `presentation` (providers, screens, widgets). UI never talks to Dio or Hive
  directly — only to the repository interface.
- **Offline-first caching:** The repository checks real connectivity
  (`connectivity_plus`) before deciding whether to hit the network at all.
    - Online + API succeeds → fresh data shown, cache overwritten.
    - Online + API fails → falls back to cache if any exists.
    - Offline → skips the network call, reads cache directly.
    - In both fallback cases, the UI shows a visible "Offline — showing last
      saved data" banner rather than silently presenting stale data as live.
    - If there's no cache and no connection, a distinct error state with a
      retry button is shown — not a blank screen or raw exception.
- **States:** Loading, error (with retry), empty (with different messaging
  for "no data" vs "no search matches"), and populated are each their own
  widget.
- **Search:** Client-side filter over title + body, live as you type.

## Assumptions

- JSONPlaceholder has no real timestamp field, so `fetchedAt` (used for the
  timestamp display) is set to the moment data was fetched, not a
  server-provided time.
- "Sender" in the spec is mapped to `title` and "message body" to `body`,
  since JSONPlaceholder's `/posts` endpoint doesn't model a chat sender.
- Cache is a full overwrite on each successful fetch, not a merge/diff —
  acceptable for MVP scope with a small, non-paginated list.
- No pagination was implemented since JSONPlaceholder returns all 100 posts
  in one call and the spec didn't ask for infinite scroll.

## Running

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs  # regenerate Hive adapter if models change
flutter run
```
<img width="1080" height="2400" alt="image" src="https://github.com/user-attachments/assets/09a4d446-e280-4f61-b1e2-bb3021a16742" />
<img width="1080" height="2400" alt="image" src="https://github.com/user-attachments/assets/3b9dcde5-5063-406c-b777-21680dec8c5d" />
