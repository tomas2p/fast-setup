# 🛠️ Fast Project Setup

[![Version](https://img.shields.io/badge/version-5.0-blue)](https://github.com/tomas2p/fast-setup)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Script ligero para crear estructuras de proyectos a partir de plantillas predefinidas.

Ideal para proyectos en **C++**, **Python** o cualquier otro lenguaje donde quieras empezar rápido sin repetir siempre lo mismo.

---

## 📥 Instalación

1. Clonar el repositorio:

```bash
git clone https://github.com/tomas2p/fast-setup.git
cd fast-setup
````

2. Ejecutar el script de instalación:

```bash
./install_fast-setup.sh
```

Esto hará:

* Copiar `fast-setup.sh` a `~/.local/bin/fast-setup`
* Copiar `templates.conf` y la carpeta `templates/` a `~/.config/fast-setup/`

> Asegúrate de que `~/.local/bin` esté en tu `$PATH` para ejecutar el comando `fast-setup` desde cualquier lugar.

---

## 🚀 Uso del script

```bash
fast-setup <nombre_proyecto> [opciones]
```

### 🔹 Plantillas

* Las plantillas se definen en un único archivo:

```bash
~/.config/fast-setup/templates.conf
```

* Cada plantilla puede contener **carpetas y archivos**, separados por `:`
* Los archivos existentes en la carpeta `templates/` (junto a `templates.conf`) se copian automáticamente al proyecto.
* Si no existen, se crean vacíos.

#### Ejemplo de `templates.conf`:

```ini
[default]
docs
src:main.cpp,project.h
data:input.txt
.:Makefile

[python]
src:main.py
tests:test_main.py
requirements.txt
```

* `.:Makefile` → copia `Makefile` desde `templates/Makefile` a la raíz del proyecto
* `src:main.cpp,project.h` → crea carpeta `src` con los archivos listados

---

### ▶️ Opciones del script

| Opción                                | Descripción                                          |
| ------------------------------------- | ---------------------------------------------------- |
| `-h`, `--help`                        | Muestra la ayuda                                     |
| `-v`, `--version`                     | Muestra la versión del script                        |
| `-l`, `--list`                        | Lista las plantillas disponibles                     |
| `-t <template>`                       | Selecciona la plantilla (por defecto: `default`)     |
| `--force`                             | Sobrescribe el directorio si ya existe               |
| `-p <path>`, `--template-path <path>` | Especifica un archivo `templates.conf` personalizado |

---

### 📌 Ejemplos de uso

```bash
# Crear un proyecto con la plantilla por defecto
fast-setup MiProyecto

# Crear un proyecto usando la plantilla Python
fast-setup MiProyecto -t python

# Sobrescribir un proyecto existente
fast-setup MiProyecto -t default --force

# Usar un archivo de plantillas personalizado
fast-setup MiProyecto -p ~/mis-plantillas/templates.conf -t python

# Listar plantillas disponibles
fast-setup -l
```

---

## 📝 Notas importantes

* Todos los archivos existentes en la carpeta `templates/` relativa al `templates.conf` se copiarán al proyecto automáticamente (ej. `Makefile`).
* Archivos que no existan se crean vacíos.
* La opción `--template-path` permite usar diferentes colecciones de plantillas según tu flujo de trabajo.
* Mantener `legacy/` para referencia de versiones anteriores.

### Estructura del Proyecto

```
fast-setup/
├── fast-setup/
│   ├── fast-setup.sh
│   └── templates/
│       ├── template.conf
│       ├── makefile
│       └── ...
├── legacy/
│   ├── v1-bash/README.md
│   ├── v2-python-json/README.md
│   ├── v3-python-yaml/README.md
│   └── v4-python-full/README.md
├── install_fast_setup.sh
├── LICENSE
└── README.md
```

### Versiones Legacy

El proyecto incluye versiones anteriores para referencia y comparación:
- [Bash](legacy/v1-bash/README.md)
- [Python con JSON](legacy/v2-python-json/README.md)
- [Python con YAML](legacy/v3-python-yaml/README.md)
- [Python FULL (YAML/JSON)](legacy/v4-python-full/README.md)

Consulta los README en cada subcarpeta para detalles y ejemplos históricos.

---

### ⚖️ Licencia

MIT License – ver archivo [LICENSE](LICENSE)