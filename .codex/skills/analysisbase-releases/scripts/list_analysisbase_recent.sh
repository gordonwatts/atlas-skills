#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BIN_DIR="${REPO_ROOT}/bin"
CRANE_BIN="${BIN_DIR}/crane"
REGISTRY="gitlab-registry.cern.ch/atlas/athena/analysisbase"

mkdir -p "${BIN_DIR}"

install_crane() {
  local version os arch archive url tmpdir
  version="${CRANE_VERSION:-}"
  if [[ -z "${version}" ]]; then
    version="$(curl -sSL https://api.github.com/repos/google/go-containerregistry/releases/latest \
      | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' \
      | head -n 1)"
  fi
  if [[ -z "${version}" ]]; then
    echo "Failed to determine latest crane release." >&2
    exit 1
  fi

  os="$(uname -s)"
  arch="$(uname -m)"
  case "${os}" in
    Linux) os="Linux" ;;
    Darwin) os="Darwin" ;;
    *) echo "Unsupported OS: ${os}" >&2; exit 1 ;;
  esac
  case "${arch}" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Unsupported architecture: ${arch}" >&2; exit 1 ;;
  esac

  archive="go-containerregistry_${os}_${arch}.tar.gz"
  url="https://github.com/google/go-containerregistry/releases/download/${version}/${archive}"
  tmpdir="$(mktemp -d)"

  curl -sSL -o "${tmpdir}/${archive}" "${url}"
  tar -xzf "${tmpdir}/${archive}" -C "${tmpdir}"

  if [[ ! -f "${tmpdir}/crane" ]]; then
    echo "crane binary not found in archive." >&2
    exit 1
  fi

  mv "${tmpdir}/crane" "${CRANE_BIN}"
  chmod +x "${CRANE_BIN}"
  rm -rf "${tmpdir}"
}

if [[ ! -x "${CRANE_BIN}" ]]; then
  install_crane
fi

"${CRANE_BIN}" ls "${REGISTRY}" \
  | grep -v '^latest$' \
  | sort -V \
  | tail -n 10
