#!/usr/bin/env python3
"""Update the pinned Linux AppImage from T3's newest published nightly."""
import argparse
import base64
import json
from pathlib import Path
import re
import urllib.request

RELEASES = 'https://api.github.com/repos/pingdotgg/t3code/releases?per_page=100'
TAG = re.compile(r'^v(\d+\.\d+\.\d+-nightly\.\d{8}\.\d+)$')
DIGEST = re.compile(r'^sha256:([0-9a-f]{64})$')
PACKAGE = Path(__file__).resolve().parents[1] / 'package.nix'


def newest(releases):
    candidates = []
    for release in releases:
        match = TAG.fullmatch(release.get('tag_name', ''))
        if release.get('draft') or match is None:
            continue
        version = match.group(1)
        filename = f'T3-Code-{version}-x86_64.AppImage'
        for asset in release.get('assets', []):
            if asset.get('name') != filename:
                continue
            url = f'https://github.com/pingdotgg/t3code/releases/download/v{version}/{filename}'
            digest = DIGEST.fullmatch(asset.get('digest') or '')
            if asset.get('browser_download_url') != url or digest is None:
                continue
            hash_sri = 'sha256-' + base64.b64encode(bytes.fromhex(digest.group(1))).decode()
            candidates.append((release['published_at'], version, hash_sri))
    if not candidates:
        raise RuntimeError('No published Linux desktop nightly with a SHA-256 digest found')
    return max(candidates, key=lambda value: value[0])


def update(source, version, hash_sri):
    changed, version_count = re.subn(r'version = "[^"]+";', f'version = "{version}";', source, count=1)
    changed, hash_count = re.subn(r'sha256 = "[^"]+";', f'sha256 = "{hash_sri}";', changed, count=1)
    if version_count != 1 or hash_count != 1:
        raise RuntimeError('Unexpected package.nix format')
    return changed


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true', help='Report the latest nightly without changing files')
    args = parser.parse_args()
    request = urllib.request.Request(RELEASES, headers={
        'Accept': 'application/vnd.github+json',
        'User-Agent': 't3-nightly-nix-flake',
    })
    with urllib.request.urlopen(request, timeout=60) as response:
        releases = json.load(response)
    _, version, hash_sri = newest(releases)
    source = PACKAGE.read_text()
    current = re.search(r'version = "([^"]+)";', source).group(1)
    print(f'Pinned: {current}; latest upstream desktop nightly: {version}', flush=True)
    if args.check or current == version:
        return
    PACKAGE.write_text(update(source, version, hash_sri))
    print(f'Updated package.nix to {version}', flush=True)


if __name__ == '__main__':
    main()
