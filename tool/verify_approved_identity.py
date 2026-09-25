"""Fail CI if the approved artwork or actual home entry point regresses."""
import base64
import hashlib
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent.parent
expected = '75b234b7fb16bfd4122682b1c7b9caf5d6d67f9c680cab8e23293198f96c5f16'
for name in ('assets/svg/go_logo.svg', 'assets/svg/go_logo_light.svg', 'web/favicon.svg'):
    document = ET.parse(root / name)
    image = document.find('{http://www.w3.org/2000/svg}image')
    assert image is not None, f'{name}: expected supplied raster artwork, not replacement lettering'
    uri = image.attrib['{http://www.w3.org/1999/xlink}href']
    data = base64.b64decode(''.join(uri.split(',', 1)[1].split()), validate=True)
    assert hashlib.sha256(data).hexdigest() == expected, f'{name}: image checksum mismatch'
    assert data[:4] == b'RIFF' and data[8:12] == b'WEBP', name
home = (root / 'lib/view/layout/home/screen/go_services_home_screen.dart').read_text()
shell = (root / 'lib/view/layout/bottom_navigation/bottom_navigation_bar_screen.dart').read_text()
assert 'GoCustomerHomeView(' in home
assert 'GoServicesHomeScreen(' in shell
print('Approved artwork checksum and active home route verified.')
