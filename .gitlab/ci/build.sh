#!/usr/bin/env bash

# SPDX-License-Identifier: AGPL-3.0

#    ----------------------------------------------------------------------
#    Copyright © 2022, 2023, 2024, 2025  Pellegrino Prevete
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


# This script is run within a virtual environment to build
#  pakcage
# $1: platform
# $2: architecture

set \
  -euo \
    pipefail
shopt \
  -s \
    extglob

_gur_mini() {
  local \
    _ns="${1}" \
    _pkg="${2}" \
    _release="${3}" \
    _depends_skip \
    _pacman_opts=() \
    _api \
    _url \
    _msg=() \
    _sig
  _depends_skip="y"
  if (( 3 < "${#}" )); then
    _depends_skip="${4}"
  fi
  _msg=(
    "Downloading '${_pkg}'"
    "binary CI release"
    "from '${_ns}' namespace"
    "Gitlab.com."
  )
  echo \
    "${_msg[*]}"
  _gl_dl_retrieve \
    "https://gitlab.com/api/v4/projects/${_ns}%2F${_pkg}-ur"
  _project_id="$(
    cat \
      "${HOME}/${_ns}%2F${_pkg}-ur" | \
      jq \
        '.id')"
  if [[ "${_project_id}" == "null" ]]; then
    _msg=(
      "The project '${_pkg}-ur' does not exist"
      "in namespace '${_ns}'."
    )
    echo \
      "${_msg[*]}"
    return \
      1
  fi
  _api="https://gitlab.com/api/v4"
  _url="${_api}/projects/${_project_id}/releases"
  _gl_dl_retrieve \
    "${_url}"
  _urls=( $(
    cat \
      "${HOME}/releases" | \
      jq \
        '.[0].assets.links.[]' | \
        jq \
          --raw-output \
          '.direct_asset_url')
  )
  for _url in "${_urls[@]}"; do
    _file="$(
      basename \
        "${_url}")"
    _output_file="$(pwd)/${_file}"
    _gl_dl_retrieve \
      "${_url}"
  done
  for _sig in "${HOME}/"*".pkg.tar.xz.sig"; do
    gpg \
      --verify \
        "${_sig}"
  done
  rm \
    -rf \
    "${HOME}/"*".pkg.tar.xz.sig"
  _pacman_opts+=(
    -U
  )
  if [[ "${_depends_skip}" == "y" ]]; then
    _pacman_opts+=(
      -dd
    )
  fi
  _pacman_opts+=(
    --noconfirm
  )
  pacman \
    "${_pacman_opts[@]}" \
    "${HOME}/"*".pkg.tar.xz"
}

_fur_mini() {
  local \
    _pkg="${1}" \
    _platform="${2}" \
    _clone_opts=() \
    _mktemp_opts=() \
    _orig_pwd \
    _tmp_dir \
    _tmp_dir_base
  _orig_pwd="${PWD}"
  _tmp_dir_base="${_orig_pwd}/tmp"
  _mktemp_opts+=(
    --dry-run
    --directory
    --tmpdir="${_tmp_dir_base}"
  )
  _clone_opts+=(
    --branch="${_pkg}"
    --single-branch
    --depth=1
  )
  _tmp_dir="$(
    mktemp \
      "${_mktemp_opts[@]}")"
  git \
    clone \
      "${_clone_opts[@]}" \
      "https://github.com/themartiancompany/fur" \
      "${_tmp_dir}/fur"
  rm \
    -rf \
    "${_tmp_dir}/fur/${_platform}/"*"/"*".pkg.tar.xz.sig"
  pacman \
    -Udd \
    --noconfirm \
    "${_tmp_dir}/fur/${_platform}/"*"/"*".pkg.tar.xz"
  rm \
    -rf \
    "${_tmp_dir}/fur"
}

_requirements() {
  local \
    _fur_mini_opts=() \
    _fur_opts=() \
    _pkgname \
    _commit \
    _docs_commit \
    _git_http \
    _fur_release_latest \
    _fur_release_public
  _pkgname="${pkg%-ur}"
  _fur_mini_opts+=(
    "${platform}"
  )
  _fur_mini \
    "libcrash-bash" \
    "${_fur_mini_opts[@]}"
  _fur_mini \
    "fur" \
    "${_fur_mini_opts[@]}"
  _fur_release_public="0.0.1.1.1.1.1.1.1.1.1.1.1"
  _fur_opts+=(
    -v
    -p
      "pacman"
  )
  # pacman \
  #   -S \
  #   --noconfirm \
  #   "sudo"
  _gur_mini \
    "${ns}" \
    "reallymakepkg" \
    "1.2.5-1" || \
  fur \
    "${_fur_opts[@]}" \
    "reallymakepkg"
  _fur_release_latest="1.0.0.0.0.0.0.0.0.0.0.0.1.1-2"
  _gur_release_latest="0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.1-1"
  _gur_mini \
    "${ns}" \
    "fur" \
    "${_fur_release_latest}" \
    "n" || \
  true
  recipe-get \
    -v \
    "/home/user/${_pkgname}/PKGBUILD" \
    "_git_http" || \
    true
  _git_http="$(
    recipe-get \
      "/home/user/${_pkgname}/PKGBUILD" \
      "_git_http" || \
      true)"
  # ohoh
  if [[ "${_git_http}" == "gitlab" ]]; then
    _commit="$(
      recipe-get \
        "/home/user/${_pkgname}/PKGBUILD" \
        "_commit")"
    _gl_dl_mini \
      "${ns}" \
      "${_pkgname#lib}" \
      "${_commit}"
    cp \
      "${HOME}/${_pkgname}-${_commit}.tar.gz" \
      "/home/user/${_pkgname}"
  fi
}

_build() {
  local \
    _reallymakepkg_opts=() \
    _makepkg_opts=() \
    _makedepends=() \
    _cmd=() \
    _depend \
    _depend_name \
    _depend_pkgver \
    _depend_target \
    _home \
    _pkgbuild \
    _pkgname \
    _resolve_flag \
    _work_dir
  _home="/home/user"
  _pkgname="${pkg%-ur}"
  _work_dir="${_home}/ramdisk/${_pkgname}-build"
  _pkgbuild="${_home}/${_pkgname}/PKGBUILD"
  mount  |
    grep \
      "${_home}/ramdisk"
  _reallymakepkg_opts+=(
    -v
    -w
      "${_work_dir}"
  )
  _makepkg_opts+=(
    -df
    --nocheck
  )
  for _depend in $(recipe-get \
                     "${_pkgbuild}" \
        "makedepends"); do
    _resolve_flag="false"
    _depend_target="${_depend}"
    if [[ "${_depend}" == *"<"* ]]; then
      _depend_name="${_depend%<*}"
      _depend_pkgver="${_depend#${_depend_name}}"
      _resolve_flag="true"
      _depend_target="${_depend_name}"
    elif [[ "${_depend}" == *"="* ]]; then
      _depend_name="${_depend%=*}"
      _depend_pkgver="${_depend#=${_depend_name}}"
      _resolve_flag="true"
      _depend_target="${_depend_name}"
    fi
    if [[ "${_resolve_flag}" == "true" ]]; then
      _msg=(
        "It is requested version"
        "'${_depend_pkgver}' of"
        "package '${_depend_name}'."
        "Be aware the Fur doesn't"
        "look for provides currently."
      )
      echo \
        "${_msg[*]}"
    fi
    _makedepends+=(
      "${_depend_target}"
    )
  done
  _fur_opts+=(
    -v
    -p
      "pacman"
    -t
      "ci"
  )
  for _depend in "${_makedepends[@]}"; do
    _msg=(
      "Installing makedepend"
      "'${_depend}'"
      "with pacman."
    )
    echo \
      "${_msg[*]}"
    pacman \
      -S \
      --noconfirm \
        "${_depend}" || \
      true
    _msg=(
      "Installing makedepends"
      "'${_depend}' with"
      "fur."
    )
    echo \
      "${_msg[*]}"
    fur \
      "${_fur_opts[@]}" \
      "${_depend}" ||
    true
  done
  _cmd+=(
    "cd"
      "${_home}/${_pkgname}" "&&"
    "reallymakepkg"
      "${_reallymakepkg_opts[@]}"
      "--"
      "${_makepkg_opts[@]}"
  )
  su \
    -c \
    "${_cmd[*]}" - \
    "user" || \
  true
  _something_built="false"
  for _file in "${_home}/${_pkgname}/"*".pkg.tar."*; do
    _something_built="true"
  done
  if [[ "${_something_built}" == "true" ]]; then
    pacman \
      -Udd \
      --noconfirm \
      "${_home}/${_pkgname}/"*".pkg.tar."*
  elif [[ "${_something_built}" == "false" ]]; then
    _msg=(
      "Build failed, printing"
      "work directory content."
    )
    tree \
      -L 5 \
      "${_work_dir}"
    tar \
      cJf \
      "build-directory.tar.xz" \
      "${_work_dir}"
  fi
  for _file \
    in "${_home}/${_pkgname}/"*".pkg.tar."*; do
    mv \
      "${_file}" \
      "dogeos-gnu-$(
        basename \
          "${_file}")"
  done
  for _file \
    in "./"*".pkg.tar."*; do
    gpg \
      --sign \
      --detach-sign \
      "${_file}"
  done
}

_gl_dl_mini() {
  local \
    _ns="${1}" \
    _pkg="${2}" \
    _commit="${3}" \
    _url \
    _http \
    _repo \
    _tarname \
    _msg=()
  _tarname="${_pkg}-${_commit}"
  _http="https://gitlab.com"
  _repo="${_http}/${_ns}/${_pkg}"
  _url="${_repo}/-/archive/${_commit}/${_tarname}.tar.gz"
  _msg=(
    "Downloading '${_tarname}'"
    "source tarball from"
    "'${_ns}' namespace on"
    "Gitlab.com."
  )
  echo \
    "${_msg[*]}"
  _gl_dl_retrieve \
    "${_url}"
}

_gl_dl_retrieve() {
  local \
    _url="${1}" \
    _token_private \
    _token \
    _curl_opts=() \
    _output_file \
    _msg=() \
    _token_missing
  _output_file="${HOME}/$(
    basename \
      "${_url#https://}")"
  _token_private="${HOME}/.config/gitlab.com/default.txt"
  _token_missing="false"
  if [[ ! -e "${_token_private}" ]]; then
    _token_missing="true"
  elif [[ -e "${_token_private}" ]]; then
    if [[ "$(cat "${_token_private}")" == ""  ]]; then
      _token_missing="true"
    fi
  fi
  if [[ "${_token_missing}" == "true" ]]; then
    _msg=(
      "Missing private token at"
      "'${_token_private}'."
    )
    echo \
      "${_msg[*]}"
    _msg=(
      "Set the 'GL_DL_PRIVATE_TOKEN'"
      "variable in your Gitlab.com" \
      "CI namespace or repository configuration."
    )
    echo \
      "${_msg[*]}"
    exit \
      1
  fi
  _token="PRIVATE-TOKEN: $(
    cat \
      "${_token_private}")"
  _curl_opts+=(
    --silent
    -L
    --header
      "${_token}"
    -o 
      "${_output_file}"
  )
  _msg=(
    "Downloading '${_url}'."
  )
  echo \
    "${_msg[*]}"
  curl \
    "${_curl_opts[@]}" \
    "${_url}"
}

_mem_free_get() {
  free | \
    grep \
      "Mem:" | \
    awk \
      '{print $4}'
}

_show_config() {
  _mem_free="$(
    _mem_free_get)"
  echo \
    "Free memory: '${_mem_free}'"
  mount | \
    grep \
      "/home/user/ramdisk"
  inxi \
    -e
  du \
    -hs \
      /usr
}

readonly \
  platform="${1}" \
  arch="${2}" \
  ns="${3}" \
  pkg="${4}" \
  project_id="${5}"
if (( 5 < "${#}" )); then
  commit="${6}"
fi
if (( 6 < "${#}" )); then
  tag="${7}"
fi
if (( 7 < "${#}" )); then
  ci_job_token="${8}"
fi
if (( 8 < "${#}" )); then
  package_registry_url="${9}"
fi

_requirements
_show_config
_build

# vim:set sw=2 sts=-1 et:
