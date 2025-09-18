#!/bin/bash
# Fast Project Setup
# Uso: ./generate_project.sh <nombre_proyecto> [opciones]
# Autor: Tomás Pino Pérez
# Fecha: 18/09/2025
# Versión: 5.0.2
# Repositorio: https://github.com/tomas2p/fast-setup
# Licencia: MIT

VERSION=$(grep -i '^# Versión:' "$0" | head -n1 | awk '{print $3}')
USER_CONFIG_DIR="$HOME/.config/fast-setup"
TEMPLATE_FILE="$USER_CONFIG_DIR/templates.conf"
DEFAULT_TEMPLATE="default-c++"

# -------------------
# Funciones
# -------------------

usage() {
    echo "Uso: $0 <nombre_proyecto> [opciones]"
    echo
    echo "Opciones:"
    echo "  -h, --help               Muestra esta ayuda"
    echo "  -v, --version            Muestra la versión"
    echo "  -l, --list               Lista las plantillas disponibles"
    echo "  -t <plantilla>           Selecciona la plantilla (por defecto: $DEFAULT_TEMPLATE)"
    echo "  --force                  Sobrescribe el directorio si ya existe"
    echo "  -p, --template-path PATH Especifica la ruta al archivo templates.conf"
    exit 0
}

version() {
    echo "Fast Project Setup v$VERSION"
    exit 0
}

list_templates() {
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        echo "No se encontró $TEMPLATE_FILE"
        exit 1
    fi
    echo "Plantillas disponibles:"
    grep '^\[' "$TEMPLATE_FILE" | sed 's/^\[\(.*\)\]$/- \1/'
    exit 0
}

# -------------------
# Parsear argumentos
# -------------------

if [[ $# -lt 1 ]]; then
    usage
fi

PROJECT_NAME=""
TEMPLATE="$DEFAULT_TEMPLATE"
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -v|--version)
            version
            ;;
        -l|--list)
            list_templates
            ;;
        -t)
            shift
            TEMPLATE="$1"
            ;;
        --force)
            FORCE=true
            ;;
        -p|--template-path)
            shift
            TEMPLATE_FILE="$1"
            ;;
        *)
            if [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
            else
                echo "Argumento desconocido: $1"
                usage
            fi
            ;;
    esac
    shift
done

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Debes especificar un nombre de proyecto."
    usage
fi

PROJECT_PATH="$PWD/$PROJECT_NAME"

# -------------------
# Validaciones
# -------------------

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Archivo de plantillas no encontrado: $TEMPLATE_FILE"
    exit 1
fi

# Carpeta de templates relativa al archivo de configuración
TEMPLATE_DIR="$(dirname "$TEMPLATE_FILE")"

# Leer plantilla
STRUCTURE=$(awk -v tpl="$TEMPLATE" '
    /^\[.*\]$/ { section=substr($0,2,length($0)-2) }
    section==tpl && !/^\[/ && NF { print }
' "$TEMPLATE_FILE")

if [[ -z "$STRUCTURE" ]]; then
    echo "La plantilla \"$TEMPLATE\" no existe en $TEMPLATE_FILE"
    exit 1
fi

# Crear proyecto
if [[ -d "$PROJECT_PATH" ]]; then
    if $FORCE; then
        rm -rf "$PROJECT_PATH"
        echo "Directorio existente eliminado (--force)."
    else
        echo "El directorio $PROJECT_PATH ya existe. Usa --force para sobrescribir."
        exit 1
    fi
fi

mkdir -p "$PROJECT_PATH"

# Crear estructura y copiar archivos
while IFS= read -r line; do
    folder=$(echo "$line" | cut -d':' -f1)
    files=$(echo "$line" | cut -s -d':' -f2)

    mkdir -p "$PROJECT_PATH/$folder"

    if [[ -n "$files" ]]; then
        IFS=',' read -ra file_array <<< "$files"
        for f in "${file_array[@]}"; do
            if [[ -f "$TEMPLATE_DIR/$f" ]]; then
                cp "$TEMPLATE_DIR/$f" "$PROJECT_PATH/$folder/$f"
            else
                touch "$PROJECT_PATH/$folder/$f"
            fi
        done
    fi
done <<< "$STRUCTURE"

echo "Proyecto \"$PROJECT_NAME\" creado con la plantilla \"$TEMPLATE\" en $PROJECT_PATH"