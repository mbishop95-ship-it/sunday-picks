# Sunday Picks

Shared URL: https://mbishop95-ship-it.github.io/sunday-picks/

## One-time rollout

1. In the existing Supabase project's SQL Editor, paste **all** of the private `sunday-picks-setup.sql` delivered with the pull request (the public repository SQL is a placeholder template) and click Run once. This runs in one transaction, migrates the existing `family-2026` shared cloud league, preserves all picks, results, phases and bases, and retains the original table for recovery. If the existing league is missing or invalid, it aborts without changing data. Do not rerun a successful migration.
2. Merge the authenticated-picks pull request after SQL succeeds. GitHub Pages keeps the same URL. Between SQL and the new page deployment, the old page cannot save because its anonymous writes have been revoked.
3. Each player opens the shared URL, enters their registered email and opens the emailed link. The session persists on that device. Matthew receives commissioner controls.

The Site URL and allowed redirect URL have already been configured as the shared URL. Supabase's email provider must be enabled with the normal magic-link template (`{{ .ConfirmationURL }}`). The app allows first-time account creation by email verification. If email delivery fails, inspect Authentication logs: the default Supabase sender may restrict recipients/rate-limit messages; configure your own SMTP sender if required. No service-role key is used or needed.

## Permissions and storage

- Matthew (commissioner)
- Tanner
- Debora
- Tom

The database maps the verified `auth.uid()` to its confirmed email in `auth.users`; user-editable profile metadata never determines player or commissioner privileges. Emails are not placed in public standings tables.

Picks are individual `(race_id, player)` rows. Public standings, history and picks remain readable. RLS and table grants deny direct browser writes. The authenticated pick function derives the player server-side, validates driver/schedule/phase, enforces driver-use-once and, after migration 002, locks at the NASCAR scheduled race start using the database clock. The app displays the exact deadline in Eastern time. Matthew can correct past picks/results and manage all players. Normal submissions are serialized briefly by a league-row lock so concurrent players cannot overwrite one another. Commissioner operations are atomic and require the current revision; stale edits fail instead of overwriting newer picks.

League settings and race/result metadata remain separate from normalized pick rows. Schedule, driver list, 2026 results/backfill and results-update workflow are preserved. Existing numeric NASCAR IDs are matched to schedule IDs by date during migration. The original race IDs, picks, manual scores, historical phases and Chase base totals are retained.

Official results are derived from the existing public `data/results.json` feed for every viewer without anonymous database writes. Manual commissioner corrections remain stored. Missing picks score zero; partial race submissions do not prevent scoring submitted picks. Driver availability resets by phase; Chase standings use the existing 2100/2075/2065/2060 seeds and all-four-player behavior. Export and share remain public; restore/reset/Chase/manual correction require Matthew.

Local storage is only a read-only fallback/export cache. It is never automatically uploaded. If history exists only on a device rather than in the cloud, export it there first and restore it from Matthew's signed-in account after migration. Old service-worker caches are replaced; auth/API responses are never cached by the service worker.

## Validation

`npm install` followed by `npm test` runs migration/permission tests in PGlite (actual PostgreSQL) and interface/auth tests using Happy DOM, the real vendored Supabase SDK and mocked HTTP. Tests cover migration of the four saved races, all identities, anonymous/direct-write denial, independent submissions, driver reuse, race locking, unknown inputs/accounts, stale revisions, Chase reset, magic-link callback, session persistence, sign-out and commissioner UI.

These tests do not send real emails or connect to the production database. Full browser testing could not run in the local computer sandbox. After SQL and deployment, validate email delivery, login across devices and live RLS with the four accounts before relying on submissions. Supabase SDK 2.57.4 is vendored locally under its MIT license; no CDN is required at runtime.

Auth: https://supabase.com/docs/reference/javascript/auth-signinwithotp
RLS: https://supabase.com/docs/guides/database/postgres/row-level-security

## Scheduled race-start deadlines

Run `supabase/002-race-start-lock.sql` once in the existing Supabase SQL Editor after migration 001. This updates only schedule deadline metadata and the pick-lock function, without changing player mappings, picks, results or standings. Then deploy the corresponding app update.

Start times come from NASCAR race events (`run_type=3`, `start_time_utc`), with `race_date` interpreted in America/New_York when detailed events are unavailable. The results-update job enriches the curated schedule with UTC timestamps while preserving race IDs, names, dates and result history. On Matthew's next visit, the app synchronizes upcoming start-time changes into Supabase; everyone sees the authoritative database deadline. Other players cannot change deadlines. Once a stored deadline passes, synchronization cannot reopen that race. This uses scheduled starts, not a live green-flag detector; weather delays do not automatically reopen picks. Missing start times block ordinary submissions until Matthew updates the schedule.
