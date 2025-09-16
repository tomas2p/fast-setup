#!/bin/bash
# Fast project setup script with multiple templates
# Usage: ./fast_setup.sh <nombre_proyecto> <template>
# Author: Tomás Pino Pérez (alu0101474311)

# Extraer el nombre del proyecto y la plantilla
dir_full="$1"
template="$2"
dir_short=$(echo "$dir_full" | sed 's/^.*-//; s/.*/\L&/')

# Definición de plantillas disponibles con carpetas y archivos
declare -A templates=(
    ["ssi"]="docs src:main.cc,${dir_short}.h data:input.txt"
    ["ia"]="docs src:main.cc,${dir_short}.h data:input.txt"
)

# Función para mostrar el uso correcto del script
usage() {
    echo "Uso: $0 <nombre_proyecto> <template>"
    echo "Plantillas disponibles: ${!templates[@]}"
    exit 1
}

# Función para crear directorios y archivos y manejar errores
create_structure() {
    local base_dir="$1"
    local -n structure="$2"

    mkdir -p "$base_dir" || { echo "Error al crear el directorio \"$base_dir\"."; exit 1; }
    IFS=' ' # Cambiar el delimitador interno de la cadena a espacio
    for item in ${structure}; do
        # Separar el nombre del directorio y los archivos
        IFS=':' read -r folder files <<< "$item"
        mkdir -p "$base_dir/$folder" || { echo "Error al crear el directorio \"$base_dir/$folder\"."; exit 1; }
        
        # Crear archivos si están especificados
        if [[ -n "$files" ]]; then
            IFS=',' # Cambiar el delimitador a coma para los archivos
            for file in $files; do
                touch "$base_dir/$folder/$file" || { echo "Error al crear el archivo \"$base_dir/$folder/$file\"."; exit 1; }
            done
        fi
    done
}

# Función para copiar y modificar el Makefile
setup_makefile() {
    local makefile_source="$1"
    local makefile_dest="$2"

    if [[ -f "$makefile_source" ]]; then
        cp "$makefile_source" "$makefile_dest" || { echo "Error al copiar el makefile."; exit 1; }
        sed -i "s/TARGET=.*/TARGET=${dir_short}/" "$makefile_dest" || { echo "Error al modificar el makefile."; exit 1; }
    else
        echo "El archivo Makefile no se encuentra en la ruta especificada: $makefile_source"
        exit 1
    fi
}

# Función para modificar el archivo de workspace (opcional)
modify_workspace() {
    local workspace_file="$1"
    local project_path="$2"

    if [[ -f "$workspace_file" ]]; then
        sed -i "s|\"path\": \"\.\.\/SSI\/P[0-9]\{2\}-[^\"]*\"|\"path\": \"..\/SSI\/$project_path\"|" "$workspace_file" || { echo "Error al modificar el archivo de workspace."; exit 1; }
    else
        echo "El archivo de workspace no se encuentra en la ruta especificada: $workspace_file"
        exit 1
    fi
}

# Verificamos que se proporcionen al menos dos argumentos
if [ $# -ne 2 ]; then
    usage
fi

# Verificar si la plantilla existe
if [[ -z "${templates[$template]}" ]]; then
    echo "La plantilla \"$template\" no existe."
    usage
fi

# Verificar que el directorio no exista
if [ -d "$dir_full" ]; then
    echo "El directorio \"$dir_full\" ya existe. Elige otro nombre."
    exit 1
fi

# Crear la estructura (directorios y archivos) según la plantilla seleccionada
create_structure "$dir_full" "templates[$template]"

# Copiar y modificar el makefile
makefile_source="./makefile"  # Reemplaza esto con la ruta correcta del makefile
makefile_dest="$dir_full/makefile"
setup_makefile "$makefile_source" "$makefile_dest"

# Modificar el archivo de workspace si es necesario (ejemplo para SSI)
if [[ "$template" == "ssi" ]]; then
    workspace_file="/home/tomas2p/Documents/vscode_workspaces/SSI.code-workspace"
    # modify_workspace "$workspace_file" "$dir_full"
fi

echo "Proyecto \"$dir_short\" creado exitosamente con la plantilla \"$template\"."
