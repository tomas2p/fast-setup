#!/bin/bash
# Fast Project Setup
# Uso: ./generate_project.sh <nombre_proyecto> [opciones]
# Autor: Tomás Pino Pérez
# Fecha: 18/09/2025
# Versión: 5.0.4
# Repositorio: https://github.com/tomas2p/fast-setup
# Licencia: MIT

VERSION=$(grep -i '^# Versión:' "$0" | head -n1 | awk '{print $3}')
USER_CONFIG_DIR="$HOME/.config/fast-setup"
TEMPLATE_FILE="$USER_CONFIG_DIR/template.conf"
DEFAULT_TEMPLATE="default-c++"
PLACEHOLDER_PATTERN='{{PROJECT}}'
PLACEHOLDER_UPPER='{{PROJECT_UPPER}}'
PLACEHOLDER_LOWER='{{PROJECT_LOWER}}'

# -------------------
# Funciones
# -------------------

usage() {
    echo "Fast Project Setup v$VERSION"
    echo "Uso: $0 <nombre_proyecto> [opciones]"
    echo
    echo "Opciones:"
    echo "  -h, --help               Muestra esta ayuda"
    echo "  -v, --version            Muestra la versión"
    echo "  -l, --list               Lista las plantillas disponibles"
    echo "  -t <plantilla>           Selecciona la plantilla (por defecto: $DEFAULT_TEMPLATE)"
    echo "  --force                  Sobrescribe el directorio si ya existe"
    echo "  --dry-run                Muestra las acciones que se realizarían sin crear ni modificar archivos"
    echo "  --allow-unsafe-name      Permite nombres de proyecto con caracteres no estándar (no recomendado)"
    echo "  -p, --template-path PATH Especifica la ruta al archivo templates.conf"
    echo "  --no-placeholder         Desactiva el placeholder '{{PROJECT}}' en `template.conf` para no ser sustituido automáticamente por el nombre del proyecto"
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
REPLACE_PLACEHOLDERS=true
DRY_RUN=false
ALLOW_UNSAFE_NAME=false

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
        --no-placeholder)
            REPLACE_PLACEHOLDERS=false
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --allow-unsafe-name)
            ALLOW_UNSAFE_NAME=true
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

# Validar nombre del proyecto (por seguridad y compatibilidad con nombres de archivo)
if ! $ALLOW_UNSAFE_NAME; then
    if ! [[ "$PROJECT_NAME" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo "Nombre de proyecto inválido: '$PROJECT_NAME'"
        echo "Usa solo caracteres alfanuméricos, guiones, guiones bajos o puntos, o pasa --allow-unsafe-name para forzar." 
        exit 1
    fi
fi

# Función para escapar texto antes de usar en sed (escapa '/', '&' y '|')
escape_for_sed() {
    # Reemplaza cualquiera de / & | por \& (backslash + matched char)
    printf '%s' "$1" | sed -e 's/[\/&|]/\\\&/g'
}

# Devuelve ruta relativa (reemplaza $PWD/ por ./ para salidas más legibles)
relpath() {
    local p="$1"
    # Si la ruta comienza con $PWD/, reemplazar por ./
    printf '%s' "${p/#$PWD\//./}"
}

# Transformaciones del nombre
PROJECT_NAME_UPPER=$(printf '%s' "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]')
PROJECT_NAME_LOWER=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
PROJECT_NAME_ESCAPED=$(escape_for_sed "$PROJECT_NAME")
PROJECT_NAME_UPPER_ESCAPED=$(escape_for_sed "$PROJECT_NAME_UPPER")
PROJECT_NAME_LOWER_ESCAPED=$(escape_for_sed "$PROJECT_NAME_LOWER")

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
        if $DRY_RUN; then
            echo "[dry-run] REMOVE DIR: $(relpath "$PROJECT_PATH") (would run: rm -rf)"
        else
            rm -rf "$PROJECT_PATH"
            echo "Directorio existente eliminado (--force)."
        fi
    else
        echo "El directorio $PROJECT_PATH ya existe. Usa --force para sobrescribir."
        exit 1
    fi
fi

if $DRY_RUN; then
    echo "[dry-run] MKDIR  $(relpath "$PROJECT_PATH")"
else
    mkdir -p "$PROJECT_PATH"
fi

# Crear estructura y copiar archivos
while IFS= read -r line; do
    folder=$(echo "$line" | cut -d':' -f1)
    files=$(echo "$line" | cut -s -d':' -f2)

    # Reemplazar placeholders en rutas de carpetas
    if $REPLACE_PLACEHOLDERS; then
        folder_eval=$(echo "$folder" | sed "s|$PLACEHOLDER_UPPER|$PROJECT_NAME_UPPER|g; s|$PLACEHOLDER_LOWER|$PROJECT_NAME_LOWER|g; s|$PLACEHOLDER_PATTERN|$PROJECT_NAME|g")
    else
        folder_eval="$folder"
    fi

    if $DRY_RUN; then
        echo "[dry-run] MKDIR  $(relpath "$PROJECT_PATH/$folder_eval")"
    else
        mkdir -p "$PROJECT_PATH/$folder_eval"
    fi

    if [[ -n "$files" ]]; then
        IFS=',' read -ra file_array <<< "$files"
        for f in "${file_array[@]}"; do
            # Reemplazar placeholders en el nombre del archivo
            if $REPLACE_PLACEHOLDERS; then
                f_eval=$(echo "$f" | sed "s|$PLACEHOLDER_UPPER|$PROJECT_NAME_UPPER|g; s|$PLACEHOLDER_LOWER|$PROJECT_NAME_LOWER|g; s|$PLACEHOLDER_PATTERN|$PROJECT_NAME|g")
            else
                f_eval="$f"
            fi

            src_template_path="$TEMPLATE_DIR/$f"
            dest_path="$PROJECT_PATH/$folder_eval/$f_eval"

            if [[ -f "$src_template_path" ]]; then
                # Copiar y reemplazar contenido interno si contiene el placeholder
                if $DRY_RUN; then
                    echo "[dry-run] COPY   $(relpath "$src_template_path") -> $(relpath "$dest_path")"
                    if $REPLACE_PLACEHOLDERS && (grep -q "$PLACEHOLDER_PATTERN" "$src_template_path" 2>/dev/null || grep -q "$PLACEHOLDER_UPPER" "$src_template_path" 2>/dev/null || grep -q "$PLACEHOLDER_LOWER" "$src_template_path" 2>/dev/null); then
                        echo "[dry-run] REPLACE in $(relpath "$dest_path"): {{PROJECT}}->${PROJECT_NAME}, {{PROJECT_UPPER}}->${PROJECT_NAME_UPPER}, {{PROJECT_LOWER}}->${PROJECT_NAME_LOWER}"
                    fi
                else
                    cp "$src_template_path" "$dest_path"
                    if $REPLACE_PLACEHOLDERS && (grep -q "$PLACEHOLDER_PATTERN" "$dest_path" 2>/dev/null || grep -q "$PLACEHOLDER_UPPER" "$dest_path" 2>/dev/null || grep -q "$PLACEHOLDER_LOWER" "$dest_path" 2>/dev/null); then
                        # Usar variables escapadas para sed
                        sed -i "s|$PLACEHOLDER_UPPER|$PROJECT_NAME_UPPER_ESCAPED|g; s|$PLACEHOLDER_LOWER|$PROJECT_NAME_LOWER_ESCAPED|g; s|$PLACEHOLDER_PATTERN|$PROJECT_NAME_ESCAPED|g" "$dest_path"
                    fi
                fi
            else
                # Crear archivo vacío (nombre ya sustituido)
                if $DRY_RUN; then
                    echo "[dry-run] CREATE $(relpath "$dest_path")"
                else
                    touch "$dest_path"
                fi
            fi
        done
    fi
done <<< "$STRUCTURE"

if ! $DRY_RUN; then
    echo "Proyecto \"$PROJECT_NAME\" creado con la plantilla \"$TEMPLATE\" en $PROJECT_PATH"
fi
