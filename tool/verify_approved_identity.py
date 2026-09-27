"""Guard the shared Partner vector identity requested on 27 September 2026.

The previous raster-logo guard is superseded by the user's request to match
Go Partner. Navigation assertions remain unchanged.
"""
import hashlib
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent.parent
expected = '757414ee449c1bb6f22f6f52637fa07a65ffc8678a9358483638770882fb00d3'
for name in ('assets/svg/go_logo.svg', 'assets/svg/go_logo_light.svg', 'web/favicon.svg'):
    data = (root / name).read_bytes()
    assert hashlib.sha256(data).hexdigest() == expected, f'{name}: shared GO mark changed'
    document = ET.fromstring(data)
    assert document.find('{http://www.w3.org/2000/svg}image') is None, name
    assert len(document) == 4, f'{name}: expected the original Partner GO vector mark'
splash = root / 'assets/brand/partner_splash.webp'
assert hashlib.sha256(splash.read_bytes()).hexdigest() == '63e7342cd147ed212b901095e5273ce7d7fe9ea757e6e977b435422b46f9f366'
home = (root / 'lib/view/layout/home/screen/go_services_home_screen.dart').read_text()
shell = (root / 'lib/view/layout/bottom_navigation/bottom_navigation_bar_screen.dart').read_text()
assert 'GoCustomerHomeView(' in home
assert 'GoServicesHomeScreen(' in shell
print('Shared Partner vector mark, original opening artwork and home route verified.')
