# Contributing

Thanks for considering a contribution. This is a small, single-purpose repo
and the workflow is intentionally lightweight.

## How to contribute

1. **Open an issue first** for anything beyond a typo or one-line fix.
   Bug reports, schema-change proposals, and new filter ideas all benefit
   from a quick alignment before code lands.
2. **Fork** the repo and create a topic branch
   (`git checkout -b fix/something` or `feat/something`).
3. **Test locally** by running `update_zones.bat` end-to-end against the
   live caa.bg feed. The map should render and the popup should show
   reasonable text for at least the ГД ГВА seeded zones.
4. **Open a pull request** against `main` using the provided PR template.
   Reference the related issue with `Fixes #NNN` or `Closes #NNN`.

## Coding style

* Python (`regen_geojson.py`): PEP 8, stdlib-only, no external deps.
  Keep it readable — this script is the one piece in the pipeline that's
  likely to need editing when the ГД ГВА schema evolves.
* HTML / JS (`drones_bg.html`): single self-contained file, no build step.
  Match the existing style — flat `const` declarations at the top of the
  script block, then functions, then the boot sequence.
* Batch / PowerShell: keep scripts Windows-portable. Prefer
  `Invoke-WebRequest` / `Expand-Archive` over third-party tools.
* Editor config: see `.editorconfig` (LF for code, UTF-8, trim trailing
  whitespace, final newline).

## Commit messages

Short, imperative, descriptive. Format:

```
<scope>: <one-line summary>

<optional body explaining the what and why, not the how>
```

Good scopes for this repo: `map`, `data`, `pipeline`, `docs`, `infra`.

## Data updates

The repo deliberately does **not** track the regenerated
`zones_geo.json` or the upstream `bgr_zones_*.zip` / `bgr_zones_*.json`.
Those are produced by `update_zones.bat` from the live caa.bg feed. If
your change touches the data flow, update `regen_geojson.py` and the
README's "Updating the data" section in the same PR.

## Code of conduct

By participating you agree to follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).