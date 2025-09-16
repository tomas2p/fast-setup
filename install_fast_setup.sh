#!/usr/bin/env bash

# Detecta si se está ejecutando en fish o bash
SHELL_TYPE=$(ps -p $$ -o comm=)

# Función para activar el entorno virtual
activate_venv() {
  if [[ "$SHELL_TYPE" == "fish" ]]; then
    source "$1/bin/activate.fish"
  else
    source "$1/bin/activate"
  fi
}

# Pregunta al usuario si desea usar pipx
read -p "¿Deseas usar pipx para instalar el paquete? (s/n): " USE_PIPX
if [[ "$USE_PIPX" == "s" || "$USE_PIPX" == "S" ]]; then
  if ! command -v pipx &> /dev/null; then
    echo "pipx no está instalado. Instalándolo..."
    if command -v pacman &> /dev/null; then
      sudo pacman -S python-pipx
    elif command -v apt &> /dev/null; then
      sudo apt install pipx
    elif command -v brew &> /dev/null; then
      brew install pipx
    else
      echo "Error: No se pudo determinar el gestor de paquetes para instalar pipx."
      exit 1
    fi
  fi
  echo "Instalando el paquete con pipx..."
  pipx install .
  if [[ $? -ne 0 ]]; then
    echo "Error: No se pudo instalar el paquete con pipx."
    exit 1
  fi
  echo "El paquete se ha instalado correctamente con pipx."
  exit 0
fi

# Verifica si se está ejecutando en un entorno virtual
if [[ -z "$VIRTUAL_ENV" ]]; then
  echo "No estás en un entorno virtual. Creando uno..."
  read -p "Especifica el directorio para el entorno virtual (por defecto: $HOME/fast_setup_venv): " VENV_DIR
  VENV_DIR=${VENV_DIR:-$HOME/fast_setup_venv}
  python -m venv "$VENV_DIR"
  if [[ $? -ne 0 ]]; then
    echo "Error: No se pudo crear el entorno virtual. Verifica los permisos o la configuración de Python."
    exit 1
  fi
  activate_venv "$VENV_DIR"
else
  echo "Ya estás en un entorno virtual."
fi

# Instala el paquete en modo editable
echo "Instalando el paquete en modo editable..."
python -m pip install --upgrade pip setuptools
if [[ $? -ne 0 ]]; then
  echo "Error: No se pudo actualizar pip o setuptools."
  exit 1
fi
python -m pip install -e .
if [[ $? -ne 0 ]]; then
  echo "Error: No se pudo instalar el paquete."
  exit 1
fi

# Verifica si el comando está disponible
if command -v fast-setup &> /dev/null; then
  echo "El comando 'fast-setup' se ha instalado correctamente."
else
  echo "Hubo un problema al instalar el comando 'fast-setup'."
  exit 1
fi