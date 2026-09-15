# Security Policy

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security reports.

Send a private report to the maintainer via GitHub's
[security advisory](https://github.com/totalik9/DroneMapBulgaria/security/advisories/new)
interface on this repository. You can expect an acknowledgement within
a few days and a fix or mitigation plan within a reasonable window
depending on severity.

If you cannot use GitHub's advisory form, open a low-key
"general question" issue asking the maintainer to contact you privately
without disclosing the underlying problem.

## Scope

This repository is a **static client-side map** of publicly published
civil aviation data (ГД ГВА / caa.bg). It has:

* No backend, no database, no user accounts.
* No build pipeline, no third-party runtime dependencies (Leaflet is
  loaded from unpkg via CDN).
* No telemetry, analytics, cookies, or local-storage writes.

As such, the realistic security surface is small:

* **Supply chain:** Leaflet is loaded from `unpkg.com` with an
  SRI `integrity` hash pinned to the version in use. Bumping Leaflet
  requires updating both the CSS and JS `<link>`/`<script>` tags
  together with their `integrity` attributes.
* **Data source:** The `update_zones.bat` pipeline downloads data from
  `https://www.caa.bg`. The CAA URL is hard-coded; if caa.bg serves
  malicious JSON that exploits a parser bug, that is the relevant
  attack path. `regen_geojson.py` uses `json.load` (safe by default)
  and the HTML page renders data through `escapeHtml` in the popup
  builder, so XSS via zone fields is not currently exploitable.
* **Local HTTP server:** `python -m http.server` binds to
  `127.0.0.1` only. Do not change the `--bind` flag without
  understanding the implications.

## Out of scope

* Issues with caa.bg itself or the upstream ГД ГВА feed.
* The accuracy or currentness of the published zone data — for
  authoritative flight decisions, consult caa.bg directly.
* Browser vulnerabilities unrelated to this project.

## Supported versions

Only the `main` branch is supported. Once v1.0.0 is tagged, security
fixes will land on `main` and be backported only at the maintainer's
discretion.