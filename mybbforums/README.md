# MyBBForums MyBB plugin

This guide covers installation, first-time verification, listing management, and common recovery tasks from MyBB's Admin CP.

## Requirements

- MyBB 1.8.38 or later in the 1.8 series.
- PHP 8.1–8.4 with Sodium and cURL enabled.
- MySQL 5.7.8+ or MariaDB 10.3+ for activity collection (the database driver must support per-statement timeouts).
- A public HTTPS MyBB forum URL and an email inbox you can access.
- A configured MyBB task runner so the scheduled hourly metrics task can execute.

The plugin checks the API and proof protocol before service operations. Unsupported versions stop with an Admin CP error rather than sending listing changes.

## Install and activate

1. Back up the MyBB files and database, then download the plugin release.
2. Copy `mybbforums/mybbforums.php` to your forum's `inc/plugins/mybbforums.php`.
3. Copy `mybbforums/inc/plugins/lib.php` to `inc/plugins/mybbforums/lib.php`.
4. Copy `mybbforums/inc/tasks/mybbforums.php` to `inc/tasks/mybbforums.php`.
5. Copy `mybbforums/admin/modules/config/mybbforums.php` to `admin/modules/config/mybbforums.php`.
6. Copy `mybbforums/mybbforums-verify.php` to the MyBB forum's public base path. The service uses it to prove that this installation controls the configured forum URL.
7. In Admin CP, open **Configuration → Plugins**, install and activate **MyBBForums Toplist**.
8. Open **Configuration → MyBBForums**. Set the service URL to `https://mybbforums.com/api/v1`. Production URLs must use HTTPS.

The plugin stores its settings, signing keys, queued reports, and pending artwork in `../.mybbforums-private/`, outside the document root, with restrictive permissions. Keep this directory intact during server moves and backups. Set `MYBBFORUMS_DATA_DIR` only when you need to move it to another private path.

## Create and confirm a listing

1. In **Configuration → MyBBForums**, enter the public forum name, short description, owner email, up to three categories, and up to ten tags. Optionally upload a logo and banner.
2. Select **Save local draft** to keep editing locally, or **Start / resend email confirmation** to start the claim. The service sends a single-use, expiring link to the entered address.
3. The plugin can keep collecting your draft and aggregate statistics while confirmation and installation proof are pending. These stay private; no listing or plugin-submitted profile/media/statistics becomes public until the email is confirmed, the service verifies the installation, and you publish.
4. Open the confirmation email and follow its link. Return to the Admin CP and select **Sync and refresh status** if the status has not updated automatically.
5. Review the status and preview information in Admin CP, then select **Publish listing** when ready.

A forum URL by itself does not establish ownership. A new claim for a listed forum cannot view or change the existing owner's configuration before the new email confirms. Confirmation is tied to the pending site and action. Keep the private data directory so the same installation identity and keys survive routine upgrades.

## Manage the listing

Use **Configuration → MyBBForums** for all changes:

- **Profile and taxonomy:** edit the name, description, categories, and tags, then save or sync. Category and tag choices come from the service; if it is unavailable, local profile drafts can still be saved, while taxonomy changes wait for valid choices.
- **Logo and banner:** upload or remove artwork in the separate artwork controls. Supported images are JPEG, PNG, and WebP, up to 768 KiB; logo dimensions are at most 1,024 × 1,024 and banner dimensions at most 1,920 × 800. Pending artwork is private until the owner checks pass. Without a logo or banner, the site displays generated initials.
- **Statistics:** the plugin submits aggregate active-user and new-public-post counts for the 7-day and 30-day windows. The MyBB task is scheduled hourly. A local retry queue retains failed reports and sync retries them; queue status shows the count, oldest age, and exhausted retries. Public scores use accepted reports only. Implausible jumps are quarantined until moderator review.
- **Connection status:** check listing state, last sync, last accepted stats, current score, metric availability, queue warnings, quarantine policy, and the last error. Use **Sync and refresh status** to request an immediate sync and refresh status.
- **Privacy controls:** excluded member IDs can omit test or service accounts from active-user aggregates. Only aggregate counts are submitted; individual member identities are not sent.
- **Visibility:** **Publish listing** makes the verified profile public. **Unpublish** hides it while retaining the owner's configuration. Publishing never changes the organic score; paid placements do not affect ranking.
- **Credentials:** rotate the API credential after a suspected leak or as part of an operational key rotation. Revoke it to stop service access. Revocation requires a new verification/claim flow to reconnect.
- **Email and ownership:** **Confirm new owner email** requests a verified email change and keeps the current address authoritative until the new one confirms. **Transfer ownership to this email** starts a recipient-confirmed transfer and notifies the existing owner. A replacement installation can request recovery; review the request and explicitly approve or deny it in Admin CP.
- **Suspension and deletion:** a suspended listing can submit an appeal with a message visible to moderators. **Delete listing** requires checking the confirmation box, permanently removes the listing after the service retention window, and requires a new claim to list again.

## Lost access, reinstall, and removal

- **Still have the original MyBB installation and credentials:** use **Confirm new owner email** to verify a replacement address. The old email remains authoritative until the new address confirms.
- **Lost the email but still control the installed forum:** install/restore the plugin and verification file, preserve the private data directory if available, and use the recovery request flow. If reinstall created a new installation identity, the existing owner is asked to approve recovery by email; additional moderator review may apply. Recovery is not immediate, and a forum URL alone is insufficient.
- **Changing domain or base path:** update the canonical MyBB URL and sync. The service only moves the listing after the same installation key proves control at the new HTTPS origin. A failed proof leaves the current ownership and URL in place.
- **Deactivate:** deactivation disables the scheduled stats task and does not itself erase the listing.
- **Uninstall:** uninstall best-effort unpublishes the listing and revokes its credential, then removes the local signing keys, settings, queue, and artwork. If the service is offline, remote cleanup may not finish; remove or suspend the listing through its service owner/recovery process. Back up the private directory before uninstall if you may need ownership recovery.

## Abuse reports and moderation

Each public forum profile has a **Report abuse or a problem** form. Visitors can report spam or misleading listings, inaccurate information, unsafe content, or another issue, with an optional note. Reports are private to moderators, are limited to five per IP-derived privacy hash per day, and do not change a listing's score automatically. A moderator reviews and records a decision through the service's moderation workflow.

## Troubleshooting

- **Confirmation email not received:** verify the email spelling and service delivery setup, then use **Start / resend email confirmation**. A link expires and can only be used once; request a new one if needed.
- **Installation proof fails:** confirm the public URL is HTTPS, the verification file is reachable at the MyBB base path, and the plugin is installed on that same forum. Check redirects, web server access rules, and the displayed Admin CP error.
- **No metrics or “metrics unavailable”:** confirm MyBB version, PHP extensions, supported database version, and task-runner execution. Inspect the connection and metrics errors in Admin CP.
- **Queued stats are not clearing:** check outbound HTTPS access, service availability, and last error; sync retries pending reports. Duplicate or delayed reports are safely deduplicated by sample ID and sequence.
- **Artwork is missing:** check its status in Admin CP and run sync after confirmation. The directory uses generated initials when no image has synced.
- **Listing is suspended:** read the displayed reason, fix the issue, then submit an appeal in Admin CP. Only moderators can review it.

## Compatibility and developer checks

The plugin supports MyBB 1.8.38+ within the 1.8 series and PHP 8.1–8.4 with Sodium and cURL. Admin CP management, service synchronization, and metric submission fail closed with a clear error outside that runtime range. The full project suite has been exercised on PHP 8.1–8.4. A disposable live MyBB 1.8.39 installation on PHP 8.4/MariaDB 10.11.6 passed plugin activation, configuration-page rendering, task toggling, and aggregate metric collection against native MyBB tables. The metric collector also passes on MySQL 5.7.44; other MyBB versions remain unverified.

From the companion website repository root, set `MYBB_CORE_ROOT=/path/to/mybb` and run `php website/tests/mybb-plugin-system.php` to validate MyBB hook registration using MyBB's `pluginSystem` class. This source integration check does not boot Admin CP or its database.

For a read-only collector check against a disposable configured MyBB install, set `MYBB_METRICS_ROOT=/path/to/disposable-mybb` and run `php website/tests/mybb-metrics-live.php` from the companion website repository root. The check uses the configured `mysqli` or `mysql_pdo` driver and executes only bounded aggregate queries; it does not insert test rows. The full website `composer test` suite skips this check unless `MYBB_METRICS_ROOT` is set.

The verification endpoint is read-only: it signs a short-lived challenge with the installation Ed25519 key and returns no listing data. When the configured MyBB URL changes, the plugin asks the service to verify that same key at the new HTTPS origin; the service changes the listing URL only after proof succeeds. Categories and tags come from service taxonomy endpoints and are checked again when saved. If the service is unavailable, taxonomy changes wait while local profile drafts remain editable.

Before its first service operation in each PHP request, the plugin checks `/version` and requires API v1, request-signature protocol v1, and installation-proof protocol v1. It sends `X-MyBBForums-API-Version: 1` with service API requests. If the service requires a newer or incompatible protocol, the plugin stops and shows an actionable update error rather than sending claims or listing changes.
