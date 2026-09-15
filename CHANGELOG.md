# Changelog

All notable changes to **DroneMapBulgaria** are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-09-15

### Added
- Initial public release.
- `drones_bg.html`: single-file Leaflet page rendering ГД ГВА drone
  zones on top of BGMountains / OpenTopoMap / OpenStreetMap basemaps.
  - Restriction-class colour coding (PROHIBITED, REQ_AUTHORISATION,
    CONDITIONAL, INACTIVE).
  - Filter by restriction class, "comments only", and "inactive today".
  - Popup shows official message, reason badges, lower/upper altitude
    band with vertical reference, applicability window, and any
    free-form ГД ГВА notes.
  - Quick-jump buttons for Sofia, Plovdiv, Varna, Burgas, all-BG.
- `regen_geojson.py`: converts the flat ГД ГВА JSON into a Leaflet-ready
  GeoJSON FeatureCollection. Circles are approximated as 64-vertex
  polygons; `uSpaceClass` is filtered out (always NO/no).
- `update_zones.bat`: end-to-end Windows pipeline — scrape the latest
  zip URL from caa.bg, download, unzip, regenerate `zones_geo.json`,
  start a local HTTP server on `127.0.0.1:8765` if free, open the map.
- `_caa_get_link.ps1`, `_port_check.ps1`: small PowerShell helpers used
  by the pipeline.
- `README.md`: project overview, restriction-colour table, two ways to
  run the map, data-update procedure, source attribution.
- `.gitignore`: excludes the regenerated `zones_geo.json`, the upstream
  `bgr_zones_*.zip` and `bgr_zones_*.json`, and pipeline scratch files.
- Standard community files: `LICENSE`, `CONTRIBUTING.md`,
  `SECURITY.md`, `CODE_OF_CONDUCT.md`, `.editorconfig`.
- GitHub templates under `.github/`: issue (bug report + feature
  request) and pull-request template; lightweight CI that sanity-checks
  the Python script's JSON conversion on a sample input.

[Unreleased]: https://github.com/totalik9/DroneMapBulgaria/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/totalik9/DroneMapBulgaria/releases/tag/v1.0.0