# DroneMapBulgaria

Interactive Leaflet map of Bulgaria's official drone (UAS / БЛС / БВС) flight
zones, sourced live from the Bulgarian Civil Aviation Authority (ГД ГВА).

The page opens at any static HTTP server (e.g. `python -m http.server 8765`)
and renders restriction polygons directly on top of an OpenStreetMap-family
basemap — no build step, no backend, no API keys.

![status](https://img.shields.io/badge/data%20source-caa.bg-blue)
![status](https://img.shields.io/badge/no%20build%20step-required-brightgreen)
![status](https://img.shields.io/badge/license-MIT-lightgrey)

## What it does

`drones_bg.html` is a single self-contained Leaflet page that loads
`zones_geo.json` (the regenerated GeoJSON feature collection) and draws every
ГД ГВА zone as a colored polygon on the map.

Each zone is classified by restriction level:

| Color           | Restriction          | Meaning                                |
| --------------- | -------------------- | -------------------------------------- |
| Red             | `PROHIBITED`         | Flight forbidden                       |
| Orange          | `REQ_AUTHORISATION`    | Flight requires authorization          |
| Yellow          | `CONDITIONAL`        | Conditional / requires notification    |
| Gray (dotted)   | Inactive today       | Permanent zone inactive on the run date |

The control panel lets you:

* Switch basemap between **BGMountains** (default — `bgmtile.kade.si`),
  **OpenTopoMap**, and **OpenStreetMap**.
* Toggle individual restriction classes on/off.
* Filter to zones that carry free-form ГД ГВА comments or non-permanent
  applicability windows.
* Fly to major cities (София, Пловдив, Варна, Бургас) or zoom out to all of
  Bulgaria.

Clicking a polygon opens a popup with the official message, reason badges,
height band (lower/upper limit in meters with vertical reference), applicability
window, and any ГД ГВА free-form notes.

## Project layout

```
.
├── drones_bg.html         # The map page (single-file Leaflet app)
├── regen_geojson.py       # ГД ГВА flat-JSON → GeoJSON FeatureCollection
├── update_zones.bat       # Windows end-to-end pipeline (see below)
├── _caa_get_link.ps1      # Helper: scrapes the latest zones zip URL from caa.bg
├── _port_check.ps1        # Helper: checks whether 127.0.0.1:8765 is bound
└── .gitignore             # Excludes regenerated data artifacts
```

The two large data files (`bgr_zones_*.json` and `zones_geo.json`) are
**deliberately not tracked** — they're regenerated on demand by the pipeline.

## Quick start

Prerequisites: **Python 3.11+** and **PowerShell** (Windows ships with it).

### 1. Fetch the latest zones and open the map

```bat
update_zones.bat
```

This runs the full five-step pipeline:

1. Scrape `https://www.caa.bg/bg/category/633/7062` for the latest zipped
   JSON download (PowerShell helper `_caa_get_link.ps1`).
2. Download the zip.
3. Extract the JSON.
4. Run `regen_geojson.py` to convert the flat ГД ГВА schema into Leaflet-ready
   GeoJSON (circles approximated as 64-vertex polygons).
5. Start `python -m http.server 8765 --bind 127.0.0.1` if the port is free,
   then open the map at
   `http://127.0.0.1:8765/drones_bg.html?v=<random>#updated`.

To stop the local server, close the `DroneBG-Server` console window.

### 2. Just open the page (you already have `zones_geo.json`)

If you only need to view the map and someone gave you a fresh
`zones_geo.json`:

```bat
python -m http.server 8765 --bind 127.0.0.1
```

Then visit `http://127.0.0.1:8765/drones_bg.html` in your browser. Opening the
HTML file via `file://` also works for casual viewing, but a local HTTP server
avoids any future CORS / fetch edge cases.

## Updating the data

The ГД ГВА JSON schema is mostly stable, but fields like `restriction`,
`reason`, `applicability[]`, and `geometry[].horizontalProjection` (either
`Circle` with center+radius, or `Polygon` with rings of `[lon, lat]`) are what
`regen_geojson.py` actually depends on.

If a future schema change breaks the conversion, edit `regen_geojson.py`:

* `circle_to_polygon()` — controls the vertex count for circle approximation.
* `main()` — the field-lifting step (`lowerLimit`, `upperLimit`, etc.) and
  the `uSpaceClass` filter.

The `drones_bg.html` constants `TODAY` / `TODAY_BG` should be bumped each time
you regenerate, so the "inactive today" filter and legend dates stay accurate.

## Credits

This project stands on the work of several upstream communities:

### Basemap tiles

The map uses three optional basemaps. Each carries its own licence and
attribution (rendered by Leaflet's default attribution control in the
bottom-right of the map):

| Basemap      | Tile URL                                            | Licence / credit                                                |
| ------------ | --------------------------------------------------- | --------------------------------------------------------------- |
| **BGMountains** | `https://bgmtile.kade.si/{z}/{x}/{y}.png` (default) | Tiles © [BGMountains](https://bgmountains.org/), CC-BY-NC-SA 2.5 |
| **OpenTopoMap** | `https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png`   | Map data © OpenTopoMap, CC-BY-SA; tiles via BGMountains, CC-BY-NC-SA 2.5 |
| **OpenStreetMap** | `https://tile.openstreetmap.org/{z}/{x}/{y}.png`   | © OpenStreetMap contributors, ODbL                              |

BGMountains is a community-built map set of the Bulgarian mountains
covering trails, contours, shelters, and peak names. If you find it
useful, please support the project at <https://bgmountains.org/>.

> BGMountains is published under **CC-BY-NC-SA 2.5** — *noncommercial*.
> This codebase is MIT and is itself noncommercial, so the share-alike
> applies on attribution only. If you fork and commercialise the
> product, swap the BGMountains layer out for another basemap.

### Zone data

All zone geometry, restrictions, and messages come from
[caa.bg](https://www.caa.bg/) — Bulgarian Civil Aviation Authority.
The official feed lives under
`/bg/category/633/7062` and is republished periodically as
`bgr_zones_DDMMYYYY.zip`. This project is not affiliated with ГД ГВА.

### Software

The map page renders with [Leaflet](https://leafletjs.com/) (BSD-2)
loaded from `unpkg.com` with an SRI `integrity` hash pinned to the
version in use.

## License

This project is dedicated to the public domain under
[Creative Commons CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).
You can copy, modify, distribute, and use this code and documentation
for any purpose — commercial or non-commercial — without asking
permission.

The CC0 dedication applies **only to the code and docs in this
repository**. Third-party data and assets (ГД ГВА zone data,
BGMountains / OpenTopoMap / OpenStreetMap tiles, Leaflet) remain under
their own upstream licences — see the **Credits** section above.