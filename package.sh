#!/bin/sh
set -e
set -x
_modname=$(sed -n '/^\s*name\s*=/{s/.*"\(.\+\).*"/\1/p;q}' modinfo.lua)
_modversion=$(sed -n '/^\s*version\s*=/{s/.*"\(.\+\).*"/\1/p;q}' modinfo.lua)
_OUT="./out/${_modname// /_}-${_modversion}"
_OUTSTEAM="./out/steam/${_modname// /_}"

rm -fr "${_OUT}" "${_OUTSTEAM}" "${_OUT}.zip"

for f in README.md LICENSE modicon.* modinfo.lua modmain.lua lib/*; do
  install -Dm755 "$f" "${_OUT}/${f}"
done

# the ModUploader REALLY wants the mod to be in this subdirectory
install -dm755 "$(dirname "${_OUTSTEAM}")"
ln -rsf "${_OUT}" "${_OUTSTEAM}"

pushd "${_OUT}"/..
zip -r9 "$(basename "${_OUT}")"{.zip,}
popd
