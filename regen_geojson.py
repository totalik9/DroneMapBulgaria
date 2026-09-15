"""Convert the official ГД ГВА drone zones JSON into a GeoJSON FeatureCollection
ready for Leaflet.

Usage:
    python regen_geojson.py <input.json> [output.json]

- Input: bgr_zones_DDMMYYYY.json from caa.bg (flat schema, NOT GeoJSON)
- Output: FeatureCollection where each feature is a single L.polygon-compatible
  geometry (Circles approximated as 64-vertex polygons in lon/lat -> lat/lon).
- uSpaceClass is dropped (always NO/No/no = not-applicable; zero informational value).
"""
import json, math, os, sys


def circle_to_polygon(center, radius, segments=64):
    """Approximate a Circle (center [lon,lat], radius meters) as a polygon."""
    lon, lat = center
    # 1 deg lat ~ 111320 m; 1 deg lon ~ 111320 * cos(lat) m
    lat_cos = math.cos(math.radians(lat))
    coords = []
    for i in range(segments):
        a = 2 * math.pi * i / segments
        dx = radius * math.cos(a)
        dy = radius * math.sin(a)
        plat = lat + dy / 111320
        plon = lon + dx / (111320 * (lat_cos or 1e-9))
        coords.append([plon, plat])
    coords.append(coords[0])  # close ring
    return [coords]  # GeoJSON Polygon = [ring]


def main(in_path, out_path=None):
    if out_path is None:
        out_path = os.path.join(os.path.dirname(in_path), 'zones_geo.json')

    with open(in_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    out_features = []
    for z in data['features']:
        props = {k: v for k, v in z.items() if k != 'geometry' and k != 'type'}
        props.pop('uSpaceClass', None)  # always NO; drop noise

        # Original schema: lowerLimit/upperLimit/lowerRef/upperRef live inside
        # each geometry[]. Lift the first ones up to top-level props (popup reads
        # p.lowerLimit / p.upperLimit). When the same feature has multiple
        # geometry entries (rare), we still use the first one's verticals as
        # the "primary" — popup only shows one height band.
        geoms = z.get('geometry', [])
        if geoms:
            g0 = geoms[0]
            props.setdefault('lowerLimit', g0.get('lowerLimit'))
            props.setdefault('upperLimit', g0.get('upperLimit'))
            props.setdefault('lowerRef', g0.get('lowerVerticalReference'))
            props.setdefault('upperRef', g0.get('upperVerticalReference'))

        for geom in geoms:
            hp = geom['horizontalProjection']
            if hp['type'] == 'Circle':
                coords = circle_to_polygon(hp['center'], hp['radius'])
            else:
                coords = hp['coordinates']  # already rings of [lon,lat]
            out_features.append({
                'type': 'Feature',
                'properties': dict(props),  # shallow copy per feature
                'geometry': {'type': 'Polygon', 'coordinates': coords},
            })

    out = {'type': 'FeatureCollection', 'features': out_features}
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, separators=(',', ':'))

    print(f'Wrote {len(out_features)} features to {out_path}')
    print(f'Size: {os.path.getsize(out_path):,} bytes')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
