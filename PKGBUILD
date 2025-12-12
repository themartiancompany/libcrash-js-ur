# SPDX-License-Identifier: AGPL-3.0

#    ----------------------------------------------------------------------
#    Copyright © 2024, 2025  Pellegrino Prevete
#
#    All rights reserved
#    ----------------------------------------------------------------------
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.


# Maintainers:
#   Truocolo
#     <truocolo@aol.com>
#     <truocolo@0x6E5163fC4BFc1511Dbe06bB605cc14a3e462332b>
#   Pellegrino Prevete (dvorak)
#     <pellegrinoprevete@gmail.com>
#     <dvorak@0x87003Bd6C074C713783df04f36517451fF34CBEf>

_os="$( \
  uname \
    -o)"
_evmfs_available="$( \
  command \
    -v \
    "evmfs" || \
    true)"
if [[ ! -v "_evmfs" ]]; then
  if [[ "${_evmfs_available}" != "" ]]; then
    _evmfs="true"
  elif [[ "${_evmfs_available}" == "" ]]; then
    _evmfs="false"
  fi
fi
_py="python"
_node='nodejs'
if [[ "${_os}" == "Android" ]]; then
  # This will have to be removed when we
  # will have non-termux missing-provides bugged
  # life and dogeos android nodejs and nodejs-lts
  # builds.
  _node_lts="$( \
    pacman \
      -Q \
      "nodejs-lts" | \
      awk \
        '{print $1}' \
      2>/dev/null)"
  if [[ "${_node_lts}" != "" ]]; then
    _node="nodejs-lts"
  fi
fi
if [[ ! -v "_git" ]]; then
  _git="false"
fi
if [[ ! -v "_offline" ]]; then
  _offline="false"
fi
if [[ ! -v "_git_http" ]]; then
  _git_http="gitlab"
fi
if [[ ! -v "_npm" ]]; then
  _npm="true"
fi
if [[ ! -v "_docs" ]]; then
  _docs="true"
fi
_archive_format="tar.gz"
if [[ "${_git_http}" == "github" ]]; then
  _archive_format="zip"
fi
_pkg=crash-js
pkgbase="lib${_pkg}"
pkgname=(
  "${pkgbase}"
)
if [[ "${_docs}" == "true" ]]; then
  pkgname+=(
    "${pkgbase}-docs"
  )
fi
pkgver="0.1.69"
_commit="24e49d2b4ec2ba2ff74bfbaa0a52a005a98d6d47"
pkgrel=3
_pkgdesc=(
  "A collection of Javascript utility functions."
)
pkgdesc="${_pkgdesc[*]}"
arch=(
  'any'
)
_http="https://${_git_http}.com"
_ns="themartiancompany"
url="${_http}/${_ns}/${_pkg}"
license=(
  'AGPL3'
)
depends=(
  "${_node}"
)
if [[ "${_os}" != "GNU/Linux" ]] && \
   [[ "${_os}" == "Android" ]]; then
  depends+=(
  )
fi
_ahsi_optdepends=(
  "ahsi:"
    "Hello World program for a"
    "program writen using both"
    "Crash JavaScript and Crash"
    "Bash."
)
_libcrash_js_docs_optdepends=(
  "${pkgbase}-docs:"
    "Crash JavaScript documentation"
    "and manuals."
)
_libcrash_js_docs_ref_optdepends+=(
 "${_pkg}:"
   "the package this documentation"
   "package pertains to."
)
optdepends=(
  "${_ahsi_optdepends[*]}"
)
if [[ "${_npm}" == "false" ]]; then
  optdepends+=(
    "${_libcrash_js_docs_ref_optdepends[*]}"
  )
fi
if [[ "${_os}" == 'Android' ]]; then
  optdepends+=(
  )
fi
makedepends=(
  'make'
)
if [[ "${_docs}" == "true" ]]; then
  makedepends+=(
    "${_py}-docutils"
  )
fi
if [[ "${_npm}" == "true" ]]; then
  if [[ "${_os}" == "GNU/Linux" ]]; then
    makedepends+=(
      "npm"
    )
  fi
fi
checkdepends=(
  "shellcheck"
)
provides=(
  "${_node}-${_pkg}=${pkgver}"
  "${_pkg}=${pkgver}"
)
_url="${url}"
_tag="${_commit}"
_tag_name="commit"
_tarname="${_pkg}-${_tag}"
_tarfile="${_tarname}.${_archive_format}"
if [[ "${_offline}" == "true" ]]; then
  _url="file://${HOME}/${pkgname}"
fi
_sum="bff6c5712817d399dcd66002e9b1f9eb070ba389a26c5e40f7f13fecebe41221"
_sig_sum="ea083f1151e85ee8ba089a0ab88160b780beb55992540d084e5eadc090195b00"
# Dvorak
_evmfs_ns="0x87003Bd6C074C713783df04f36517451fF34CBEf"
# Truocolo
_evmfs_ns="0x6E5163fC4BFc1511Dbe06bB605cc14a3e462332b"
_evmfs_network="100"
_evmfs_address="0x69470b18f8b8b5f92b48f6199dcb147b4be96571"
_evmfs_dir="evmfs://${_evmfs_network}/${_evmfs_address}/${_evmfs_ns}"
_evmfs_uri="${_evmfs_dir}/${_sum}"
_evmfs_src="${_tarfile}::${_evmfs_uri}"
_sig_uri="${_evmfs_dir}/${_sig_sum}"
_sig_src="${_tarfile}.sig::${_sig_uri}"
if [[ "${_evmfs}" == "true" ]]; then
  makedepends+=(
    "evmfs"
  )
  _src="${_evmfs_src}"
  _sum="${_sum}"
  source+=(
    "${_sig_src}"
  )
  sha256sums+=(
    "${_sig_sum}"
  )
elif [[ "${_git}" == true ]]; then
  makedepends+=(
    "git"
  )
  _src="${_tarname}::git+${_url}#${_tag_name}=${_tag}?signed"
  _sum="SKIP"
elif [[ "${_git}" == false ]]; then
  if [[ "${_tag_name}" == 'pkgver' ]]; then
    if [[ "${_git_http}" == "gitlab" ]]; then
      _uri="${_url}/archive/refs/tags/${_tag}.${_archive_format}"
    fi
  elif [[ "${_tag_name}" == "commit" ]]; then
    if [[ "${_git_http}" == "github" ]]; then
      _uri="${_url}/archive/${_commit}.${_archive_format}"
    elif [[ "${_git_http}" == "gitlab" ]]; then
      _uri="${_url}/-/archive/${_commit}/${_tarname}.${_archive_format}"
    fi
  fi
  _src="${_tarfile}::${_uri}"
fi
source=(
  "${_src}"
)
sha256sums=(
  "${_sum}"
)
validpgpkeys=(
  # Truocolo <truocolo@aol.com>
  '97E989E6CF1D2C7F7A41FF9F95684DBE23D6A3E9'
  'DD6732B02E6C88E9E27E2E0D5FC6652B9D9A6C01'
  # Truocolo <truocolo@0x6E5163fC4BFc1511Dbe06bB605cc14a3e462332b>
  'F690CBC17BD1F53557290AF51FC17D540D0ADEED'
  # Pellegrino Prevete (dvorak) <dvorak@0x87003Bd6C074C713783df04f36517451fF34CBEf>
  '12D8E3D7888F741E89F86EE0FEC8567A644F1D16'
)

check() {
  cd \
    "${_tarname}"
  make \
    -k \
    check
}

build() {
  if [[ "${_npm}" == "true" ]]; then
    cd \
      "${_tarname}"
    make \
      "${_make_opts[@]}" \
      build-npm
  fi
}

package_libcrash-js() {
  local \
    _make_opts=()
  _make_opts=(
    DESTDIR="${pkgdir}"
    PREFIX='/usr'
  )
  cd \
    "${_tarname}"
  if [[ "${_npm}" == "true" ]]; then
   make \
     "${_make_opts[@]}" \
     install-npm
  elif [[ "${_npm}" == "false" ]]; then
    make \
      "${_make_opts[@]}" \
      install-scripts
    install \
      -vDm644 \
      "COPYING" \
      -t \
      "${pkgdir}/usr/share/licenses/${pkgname}/"
  fi
}

package_libcrash-js-docs() {
  local \
    _make_opts=()
  depends=()
  optdepends=(
    "${_libcrash_js_docs_ref_optdepends[*]}"
  )
  _make_opts=(
    DESTDIR="${pkgdir}"
    PREFIX='/usr'
  )
  cd \
    "${_tarname}"
  make \
    "${_make_opts[@]}" \
    install-doc \
    install-man
  install \
    -vDm644 \
    "COPYING" \
    -t \
    "${pkgdir}/usr/share/licenses/${pkgname}/"
}

# vim: ft=sh syn=sh et
