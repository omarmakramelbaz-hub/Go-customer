"""Configure the public browser key without copying server credentials."""
import html
import os
import re
from pathlib import Path
from urllib.parse import urlencode

root = Path(__file__).resolve().parents[1]
# Retain the existing Maps client integration. Override for a restricted web key.
places = (root / 'lib/view/layout/map/utils/google_maps_place_service.dart').read_text()
existing_key = re.search(r"apiKey = '([^']+)'", places).group(1)
key = os.environ.get('MAPS_WEB_API_KEY') or existing_key
query = urlencode({'key': key, 'libraries': 'places', 'language': 'ar', 'region': 'EG'})
script = f'<script src="https://maps.googleapis.com/maps/api/js?{html.escape(query, quote=True)}"></script>'
index = root / 'web/index.html'
source = index.read_text()
if '<!-- MAPS_SCRIPT -->' not in source:
    raise SystemExit('Configure from a clean web/index.html containing MAPS_SCRIPT.')
index.write_text(source.replace('<!-- MAPS_SCRIPT -->', script))
