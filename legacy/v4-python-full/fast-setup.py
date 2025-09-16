import os
import json
import yaml
import shutil
import sys

# Archivos de plantillas
YAML_FILE = "./templates/structure.yaml"
JSON_FILE = "./templates/structure.json"


def load_templates():
    """Carga las plantillas desde structure.yaml o structure.json."""
    if os.path.exists(YAML_FILE):
        with open(YAML_FILE, "r") as file:
            return yaml.safe_load(file)
    elif os.path.exists(JSON_FILE):
        with open(JSON_FILE, "r") as file:
            return json.load(file)
    else:
        print("Error: No se encontró un archivo de plantilla válido.")
        sys.exit(1)


def create_structure(project_name, project_path, structure):
    """Crea los directorios y archivos según la plantilla."""
    # Crear directorios
    for directory in structure.get("directories", []):
        dir_path = os.path.join(
            project_path, directory.replace("project_name", project_name)
        )
        source_dir = os.path.join(
            "templates", directory.replace("project_name", project_name)
        )

        if os.path.exists(source_dir):  # Si hay un directorio plantilla, copiarlo
            shutil.copytree(source_dir, dir_path, dirs_exist_ok=True)
            print(f"Copiado directorio: {dir_path} desde plantilla.")
        else:  # Si no, crearlo vacío
            os.makedirs(dir_path, exist_ok=True)
            print(f"Creado directorio: {dir_path}")

    # Crear archivos
    for file_path in structure.get("files", []):
        file_path = os.path.join(
            project_path, file_path.replace("project_name", project_name)
        )
        source_file = os.path.join("templates", os.path.basename(file_path))
        dir_path = os.path.dirname(file_path)
        os.makedirs(dir_path, exist_ok=True)  # Asegurarse de que el directorio exista

        if os.path.exists(source_file):  # Si hay un archivo plantilla, copiarlo
            shutil.copy(source_file, file_path)
            print(f"Copiado archivo: {file_path} desde plantilla.")
        else:  # Si no, crearlo vacío
            open(file_path, "w").close()
            print(f"Creado archivo vacío: {file_path}")


def main():
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Uso: python fast-setup.py <nombre_proyecto> [plantilla]")
        sys.exit(1)

    project_name = sys.argv[1]
    project_path = os.path.join(os.getcwd(), project_name)

    templates = load_templates()

    template = (
        sys.argv[2] if len(sys.argv) > 2 else "default-c++"
    )  # Usar plantilla por defecto
    if template not in templates:
        print(
            f"Advertencia: Plantilla '{template}' no encontrada. Usando plantilla por defecto."
        )
        template = "default-c++"

    structure = templates.get(template)
    if not structure:
        print(f"Plantilla '{template}' no definida.")
        sys.exit(1)

    if os.path.exists(project_path):
        print(f"El directorio '{project_path}' ya existe.")
        sys.exit(1)

    os.makedirs(project_path)
    print(f"Proyecto '{project_name}' creado.")

    create_structure(project_name, project_path, structure)
    print(f"Proyecto '{project_name}' configurado con la plantilla '{template}'.")


if __name__ == "__main__":
    main()