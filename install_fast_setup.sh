#!/bin/bash
# Install script para Fast Project Setup v5
# Autor: Tomás Pino Pérez
# Fecha: 18/09/2025
# Licencia: MIT

set -e

# Directorios destino
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/fast-setup"

# Archivos a copiar (ajusta si cambian de ubicación en tu repo)
SCRIPT_SRC="./fast-setup/fast-setup.sh"
TEMPLATE_DIR_SRC="./fast-setup/templates"

# Crear directorios si no existen
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"

# Copiar el script
cp "$SCRIPT_SRC" "$BIN_DIR/fast-setup"
chmod +x "$BIN_DIR/fast-setup"
echo "Script instalado en $BIN_DIR/fast-setup"

# Copiar carpeta de templates
if [[ -d "$TEMPLATE_DIR_SRC" ]]; then
    cp -r "$TEMPLATE_DIR_SRC" "$CONFIG_DIR/templates"
    echo "Carpeta de templates copiada a $CONFIG_DIR/templates/"
fi

# Verificación final
if command -v fast-setup >/dev/null 2>&1; then
    echo "Instalación completada correctamente. Ejecuta 'fast-setup -h' para ver la ayuda."
else
    echo "Advertencia: ~/.local/bin no está en tu PATH. Añádelo para poder ejecutar 'fast-setup' desde cualquier lugar."
fi