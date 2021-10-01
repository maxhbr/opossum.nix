#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq

set -euo pipefail
set -x

outfile="$(readlink -f data.json)"

json="$(curl https://api.github.com/repos/opossum-tool/OpossumUI/releases |
    jq '.[0] | { tag: .tag_name, url : (.assets[] | select( .name == "OpossumUI-0.1.0.AppImage" ).browser_download_url) }')"
wget -O "$TMPFILE" "$(jq -r .url data.json)"

sha512="$(nix store prefetch-file --json --hash-type sha512 "$(jq -r .url data.json)" | jq -r .hash)"

echo "$json" | jq --arg sha512 "$sha512" '. + {sha512: $sha512}' | tee "$outfile"

git add data.json
git commit -m "update data.json"
