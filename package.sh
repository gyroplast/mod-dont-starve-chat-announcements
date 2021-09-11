#!/bin/sh
set -e
set -x
_modname=$(sed -n '/^\s*name\s*=/{s/.*"\(.\+\).*"/\1/p;q}' modinfo.lua)
_modversion=$(sed -n '/^\s*version\s*=/{s/.*"\(.\+\).*"/\1/p;q}' modinfo.lua)
_OUT=$(readlink -m -n "./out/${_modname// /_}-${_modversion}")
_OUTSTEAM=$(readlink -m -n "./out/steam/${_modname// /_}")
rm -fr "${_OUT}" "${_OUT}.zip"

for f in README.md LICENSE modicon.* modinfo.lua modmain.lua lib/*; do
  install -Dm755 "$f" "${_OUT}/${f}"
done

# the ModUploader REALLY wants the mod to be in this subdirectory
install -dm755 "$(dirname "${_OUTSTEAM}")"
ln -sf "${_OUT}" "${_OUTSTEAM}"

pushd "${_OUT}"/..
zip -r9 "${_OUT}.zip" "$(basename "${_OUT}")"
popd
