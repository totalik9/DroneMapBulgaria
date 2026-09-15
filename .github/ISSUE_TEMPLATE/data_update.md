---
name: Data update / schema change
about: Track ГД ГВА feed changes or refresh zone data
title: "[data] "
labels: ["data"]
assignees: []
---

### CAA source snapshot

- URL:
- Published date:
- Zip filename:

### Schema / content change

<!-- What differs from the previous snapshot? New fields, renamed
     restrictions, new reason categories, polygon-vs-circle shifts. -->

### Code change needed

<!-- Tick whichever apply. -->

- [ ] `regen_geojson.py`
- [ ] `drones_bg.html` (constants / filters / colour map)
- [ ] `update_zones.bat`
- [ ] `README.md` ("Updating the data" section)
- [ ] `CHANGELOG.md`

### Verification

- [ ] `python regen_geojson.py <new.json> /tmp/zones_geo.json` succeeds
- [ ] Map loads at `http://127.0.0.1:8765/drones_bg.html`
- [ ] Each restriction class shows expected colour
- [ ] Popups escape HTML correctly for at least one zone with Cyrillic
      text containing `<` / `>` / `&`