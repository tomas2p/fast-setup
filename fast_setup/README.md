# Fast-Setup

**Fast-Setup** es una herramienta de línea de comandos para automatizar la creación de proyectos mediante plantillas personalizables.

## Índice
1. [Índice](#índice)
2. [Acerca de](#acerca-de)
3. [Instalación](#instalación)
4. [Uso](#uso)
5. [Personalización](#personalización)
6. [Tests](#tests)
7. [Estructura del Proyecto](#estructura-del-proyecto)
8. [Sobre los README](#sobre-los-readme)
9. [Licencia](#licencia)

## Acerca de
Fast-Setup ahorra tiempo generando la estructura de carpetas y archivos de tus proyectos, usando una plantilla YAML centralizada y archivos base opcionales.

Autor: Tomás Pino Pérez

## Instalación

Recomendado: usar entorno virtual.

```sh
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

## Uso

Crea un nuevo proyecto:
```sh
python -m fast_setup.fast_setup MiProyecto
python -m fast_setup.fast_setup MiProyecto default-c++ --force
```

Argumentos:
- `<nombre_proyecto>`: Nombre del proyecto.
- `[plantilla]`: (Opcional) Nombre de la plantilla definida en `structure.yaml`.
- `--force`: Sobrescribe el directorio si ya existe.

Para ver ayuda:
```sh
python -m fast_setup.fast_setup --help
```

## Personalización

- Edita `~/.config/fast-setup/structure.yaml` para definir todas tus plantillas y estructuras.
- Coloca archivos base en `~/.config/fast-setup/files/` para que se copien automáticamente si se solicitan en la plantilla.

Ejemplo de estructura de configuración del usuario:
```
~/.config/fast-setup/
├── structure.yaml
└── files/
    ├── Makefile
    └── README.md
```

Ejemplo de plantilla YAML:
```yaml
default-c++:
  directories:
    - docs
    - src
    - src/project_name
    - data
  files:
    - docs/README.md
    - src/main.cc
    - src/project_name/project_name.cc
    - src/project_name/project_name.h
    - data/input.txt
    - Makefile
```

## Tests

Ejecuta las pruebas unitarias:
```sh
pytest tests/
```

## Estructura del Proyecto

```
fast-setup/
├── fast_setup/
│   ├── fast_setup.py
│   ├── __init__.py
│   ├── templates/
│   │   ├── structure.yaml
│   │   ├── structure.json
│   │   ├── Makefile
│   │   └── ...
│   └── README.md
├── tests/
│   └── test_fast_setup.py
├── legacy/
│   └── ...
├── LICENSE
├── pyproject.toml
└── README.md
```

## Sobre los README

- El README principal (`/README.md`) explica el propósito general y las versiones históricas.
- El README de `fast_setup/` (este archivo) explica el uso moderno, instalación y personalización del script actual.
- Los README en `legacy/` y subversiones documentan los enfoques antiguos (bash, python-json, python-yaml) y sirven como referencia o para comparar tecnologías.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](../LICENSE) para más detalles.