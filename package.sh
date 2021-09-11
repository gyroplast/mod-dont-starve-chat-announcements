#!/bin/sh
set -e
set -x
_modname=$(sed -n '/^\s*name\s*=/{s/.*"\(.\+\).*"/\1/p;q}' modinfo.lua)
_modversion=$(sed -n '/^\s*version\s*=/{s/.*"\(.\+\).*"/\1/p;q}' modinfo.lua)
_OUT=$(readlink -m -n "./out/${_modname}-${_modversion}")
rm -fr "${_OUT}" "${_OUT}.zip"

for f in README.md LICENSE modicon.* modinfo.lua modmain.lua lib/*; do
  install -Dm755 "$f" "${_OUT}/${f}"
done

pushd "${_OUT}"/..
zip -r9 "${_OUT}.zip" "$(basename "${_OUT}")"
popd
