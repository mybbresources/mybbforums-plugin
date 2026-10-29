# Nova audit demo forums

This Dockerfile builds a disposable MyBB 1.8.41 forum with the MyBBForums plugin already copied into place. It is intended for Nova/EasyPanel audit demonstrations, not production forums. The forum files and the plugin's private data directory persist under `/var/lib/mybbforums-demo`; MyBB and the plugin are installed from the repository and official MyBB release package.

For each demo, create an independent MySQL or MariaDB service and an app service in the `com-mybbforums-demo` EasyPanel project. Do not use an EasyPanel Compose service. Build the app service from this repository with `demo/Dockerfile`, expose its HTTP port 80, and attach persistent storage at `/var/lib/mybbforums-demo`.

At the first visit, complete the MyBB installer using the app's generated HTTPS host name and the separate database service's credentials. Create a synthetic administrator and synthetic forum content only. Then:

1. Activate **MyBBForums Toplist** in Admin CP → Configuration → Plugins.
2. Set the service URL to `https://www.mybbforums.com/api/v1` in Admin CP → Configuration → MyBBForums.
3. Add a clearly labeled demo profile and use an address routed to the existing Mailpit test sink for email confirmation.
4. Sync once and publish only when the listing is intentionally being shown in the public directory.
5. Keep all site data synthetic. To demonstrate a mismatch, sync a baseline, change or remove the synthetic public posts, then request an audit from the website maintenance task after making the audit due. The weekly audit compares the last accepted report to current aggregate counts and only warns; it does not auto-suspend a listing.

The official MyBB archive is pinned to SHA-512 `00d4c742782e23319698c758293cd272d5fc9a6093caad739403fc99963331d8d7cfaafbd25d3acdf003c64b29b4f471568ce5c388b469947f756fee7917933e`.
