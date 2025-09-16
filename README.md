# Fast-Setup

**Fast-Setup** es una herramienta para automatizar la creación de proyectos mediante plantillas YAML/JSON personalizables.

## Índice
1. [Índice](#índice)
2. [Acerca de](#acerca-de)
3. [Instalación](#instalación)
4. [Uso](#uso)
5. [Personalización](#personalización)
6. [Tests](#tests)
7. [Estructura del Proyecto](#estructura-del-proyecto)
8. [Versiones Legacy](#versiones-legacy)
9. [Licencia](#licencia)

## Acerca de
Fast-Setup ahorra tiempo generando la estructura de carpetas y archivos de tus proyectos, usando una plantilla YAML/JSON centralizada y archivos base opcionales.

Autor: Tomás Pino Pérez

## Instalación

**Para usuarios:**
- Instala el paquete desde PyPI (próximamente) o descarga el release y ejecútalo directamente.
- Al instalar, solo necesitas el script y la plantilla de usuario en `~/.config/fast-setup/`.

**Para desarrolladores:**
- Clona el repositorio para modificar, probar o contribuir.
- Instala las dependencias desde `requirements.txt` y ejecuta los tests.

```sh
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Uso

Crea un nuevo proyecto:
```sh
python -m fast_setup.fast_setup MiProyecto
python -m fast_setup.fast_setup MiProyecto default-c++ --force
```

Argumentos:
- `<nombre_proyecto>`: Nombre del proyecto.
- `[plantilla]`: (Opcional) Nombre de la plantilla definida en `structure.yaml` o `structure.json`.
- `--force`: Sobrescribe el directorio si ya existe.

Para ver ayuda:
```sh
python -m fast_setup.fast_setup --help
```

## Personalización

- Edita `~/.config/fast-setup/structure.yaml` o `structure.json` para definir todas tus plantillas y estructuras.
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
pytest --cov=fast_setup --cov-report=term-missing tests/
```
O instala las dependencias primero si es la primera vez:
```sh
pip install -r requirements.txt
pytest --cov=fast_setup --cov-report=term-missing tests/
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
│   ├── v1-bash/README.md
│   ├── v2-python-json/README.md
│   ├── v3-python-yaml/README.md
│   └── v4-python-full/README.md
├── LICENSE
├── pyproject.toml
└── README.md
```

## Versiones Legacy

El proyecto incluye versiones anteriores para referencia y comparación:
- [Bash](legacy/v1-bash/README.md)
- [Python con JSON](legacy/v2-python-json/README.md)
- [Python con YAML](legacy/v3-python-yaml/README.md)
- [Python FULL (YAML/JSON)](legacy/v4-python-full/README.md)

Consulta los README en cada subcarpeta para detalles y ejemplos históricos.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.