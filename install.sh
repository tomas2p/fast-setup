#!/usr/bin/env bash
# Simplified installer for fast-setup (optimized)
set -euo pipefail

usage() {
  cat <<EOF
Uso: $(basename "$0") [opciones]

Opciones:
  -p, --prefix DIR      Directorio prefijo de instalación (por defecto: \$HOME/.local)
  -u, --uninstall       Desinstalar los archivos instalados
  -h, --help            Mostrar esta ayuda
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${HOME}/.local"
MODE="install"

# Parse args robustly (checks missing argument for --prefix)
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prefix)
      if [[ -z "${2:-}" || "${2:0:1}" == "-" ]]; then
        printf "Error: falta argumento para %s\n" "$1" >&2
        usage
        exit 2
      fi
      PREFIX="$2"
      shift
      ;;
    -u|--uninstall)
      MODE="uninstall"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf "Opción desconocida: %s\n" "$1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

BIN_DIR="$PREFIX/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fast-setup"

install_main() {
  local src="$SCRIPT_DIR/fast-setup.sh"
  if [[ ! -f "$src" ]]; then
    printf "Error: no se encontró %s\n" "$src" >&2
    return 2
  fi
  mkdir -p "$BIN_DIR"
  # Use install to set permissions atomically
  install -m 755 "$src" "$BIN_DIR/fast-setup"
  printf "Instalado: %s/fast-setup\n" "$BIN_DIR"

  # Copiar templates al directorio de configuración si existen en el repo
  local templates_src="$SCRIPT_DIR/templates"
  if [[ -d "$templates_src" ]]; then
    mkdir -p "$CONFIG_DIR"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --delete "$templates_src"/ "$CONFIG_DIR"/
    else
      cp -a "$templates_src"/. "$CONFIG_DIR"/
    fi
    printf "Templates copiados a %s\n" "$CONFIG_DIR"
  fi
}
uninstall() {
  rm -f "$BIN_DIR/fast-setup"
  rm -rf "$CONFIG_DIR"
  printf "Desinstalado: fast-setup y configuración en %s\n" "$CONFIG_DIR"
}

if [[ "$MODE" == "install" ]]; then
  install_main

  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    printf "\nAdvertencia: %s no está en tu PATH. Añade lo siguiente a tu shell profile:\n" "$BIN_DIR"
    printf "  export PATH=\"%s:\$PATH\"\n" "$BIN_DIR"
  fi

  printf "Instalación finalizada. Ejecuta 'fast-setup -h' para ver la ayuda.\n"
  exit 0
fi

if [[ "$MODE" == "uninstall" ]]; then
  uninstall
  exit 0
fi

# Fallback (shouldn't happen)
usage
exit 1