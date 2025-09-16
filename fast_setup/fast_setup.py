import os
import json
import yaml
import shutil
import sys
import importlib.resources
import logging
# Configuración básica de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s: %(message)s'
)

# Carpeta de configuración y plantillas del usuario (minimalista)
USER_CONFIG_DIR = os.path.expanduser("~/.config/fast-setup")

def load_template_file(filename, user_first=True):
    """Carga el contenido de un archivo de plantilla desde usuario o paquete."""
    user_path = os.path.join(USER_CONFIG_DIR, filename)
    if user_first and os.path.exists(user_path):
        with open(user_path, "r") as f:
            if filename.endswith(".yaml") or filename.endswith(".yml"):
                logging.info(f"Cargando plantilla de usuario: {user_path}")
                return yaml.safe_load(f)
            elif filename.endswith(".json"):
                logging.info(f"Cargando plantilla de usuario: {user_path}")
                return json.load(f)
    # Si no existe, buscar en el paquete
    try:
        with importlib.resources.files("fast_setup.templates").joinpath(filename).open("r") as f:
            if filename.endswith(".yaml") or filename.endswith(".yml"):
                logging.info(f"Cargando plantilla interna: {filename}")
                return yaml.safe_load(f)
            elif filename.endswith(".json"):
                logging.info(f"Cargando plantilla interna: {filename}")
                return json.load(f)
    except FileNotFoundError:
        return None

def copy_example_templates():
    """Copia la plantilla de ejemplo a ~/.config/fast-setup/structure.yaml si no existe."""
    fname = "structure.yaml"
    user_path = os.path.join(USER_CONFIG_DIR, fname)
    if not os.path.exists(user_path):
        try:
            with importlib.resources.files("fast_setup.templates").joinpath(fname).open("r") as src, open(user_path, "w") as dst:
                dst.write(src.read())
            logging.info(f"Ejemplo de plantilla copiado a: {user_path}")
        except Exception:
            pass

def load_templates():
    """Carga plantillas desde ~/.config/fast-setup/structure.yaml o structure.json, o del paquete, y valida estructura."""
    os.makedirs(USER_CONFIG_DIR, exist_ok=True)
    copy_example_templates()

    templates = load_template_file("structure.yaml")
    if not templates:
        templates = load_template_file("structure.json")
    if not templates:
        logging.error("No se encontró ninguna plantilla válida.")
        sys.exit(1)

    # Validar que cada plantilla tenga las claves 'directories' y 'files'
    for nombre, estructura in templates.items():
        if not isinstance(estructura, dict) or "directories" not in estructura or "files" not in estructura:
            logging.error(f"La plantilla '{nombre}' no tiene las claves requeridas ('directories', 'files').")
            sys.exit(1)
    return templates



def create_structure(project_name, project_path, structure):
    """Crea los directorios y archivos según la plantilla."""
    # Crear directorios
    for directory in structure.get("directories", []):
        dir_path = os.path.join(
            project_path, directory.replace("project_name", project_name)
        )
        os.makedirs(dir_path, exist_ok=True)
        logging.info(f"Creado directorio: {dir_path}")

    # Crear archivos
    files_dir = os.path.join(USER_CONFIG_DIR, "files")
    for file_path in structure.get("files", []):
        file_path = os.path.join(
            project_path, file_path.replace("project_name", project_name)
        )
        user_source_file = os.path.join(files_dir, os.path.basename(file_path))
        dir_path = os.path.dirname(file_path)
        os.makedirs(dir_path, exist_ok=True)

        if os.path.exists(user_source_file):
            shutil.copy(user_source_file, file_path)
            logging.info(f"Copiado archivo: {file_path} desde ~/.config/fast-setup/files/")
        else:
            open(file_path, "w").close()
            logging.info(f"Creado archivo vacío: {file_path}")



def print_help():
        help_text = """
fast-setup: Generador de estructura de proyectos

Uso:
    python -m fast_setup.fast_setup <nombre_proyecto> [plantilla] [--force]
    python fast_setup/fast_setup.py <nombre_proyecto> [plantilla] [--force]

Opciones:
    -h, --help      Muestra esta ayuda
    --force         Sobrescribe el directorio del proyecto si ya existe

Descripción:
    Crea la estructura de un proyecto usando una plantilla definida en YAML/JSON.
    Puedes personalizar plantillas en ~/.fast-setup/templates/

Ejemplo:
    python -m fast_setup.fast_setup MiProyecto
    python -m fast_setup.fast_setup MiProyecto default-c++ --force
"""
        print(help_text)

def main():
    args = sys.argv[1:]
    if len(args) == 1 and args[0] in ("-h", "--help"):
        print_help()
        sys.exit(0)

    force = False
    # Detectar --force en cualquier posición
    if "--force" in args:
        force = True
        args.remove("--force")

    if len(args) < 1 or len(args) > 2:
        logging.error("Uso: python -m fast_setup.fast_setup <nombre_proyecto> [plantilla] [--force]")
        logging.info("Usa --help para ver la ayuda completa.")
        sys.exit(1)

    project_name = args[0]
    project_path = os.path.join(os.getcwd(), project_name)

    templates = load_templates()

    template = args[1] if len(args) > 1 else "default-c++"
    if template not in templates:
        logging.warning(f"Plantilla '{template}' no encontrada. Usando plantilla por defecto.")
        template = "default-c++"

    structure = templates.get(template)
    if not structure:
        logging.error(f"Plantilla '{template}' no definida.")
        sys.exit(1)

    if os.path.exists(project_path):
        if force:
            shutil.rmtree(project_path)
            logging.warning(f"El directorio '{project_path}' ya existía y fue sobrescrito (--force).")
        else:
            logging.error(f"El directorio '{project_path}' ya existe. Usa --force para sobrescribir.")
            sys.exit(1)

    os.makedirs(project_path)
    logging.info(f"Proyecto '{project_name}' creado.")

    create_structure(project_name, project_path, structure)
    logging.info(f"Proyecto '{project_name}' configurado con la plantilla '{template}'.")


if __name__ == "__main__":
    main()
