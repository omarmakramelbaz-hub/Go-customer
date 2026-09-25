"""Make the deployed UI build identifiable without modifying runtime APIs."""
import json
import os
from pathlib import Path

out = Path('build/web')
info = {'commit': os.environ.get('GITHUB_SHA', 'local'), 'identity': 'approved-go-home-v2'}
(out / 'build-info.json').write_text(json.dumps(info, indent=2))
index = out / 'index.html'
html = index.read_text()
html = html.replace('</head>', '<link rel="icon" type="image/svg+xml" href="favicon.svg">\n<meta name="go-identity" content="approved-go-home-v2">\n</head>')
index.write_text(html)
print(json.dumps(info))
