# 🛠️ Fast Project Setup

[![Version](https://img.shields.io/badge/version-5.0.4-blue?style=for-the-badge)](https://github.com/tomas2p/fast-setup)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

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
./install.sh
```

Esto hará:

* Copiar `fast-setup.sh` a `~/.local/bin/fast-setup`
* Copiar la carpeta `templates/` que contiene plantillas y `template.conf` a `~/.config/fast-setup/`

> Asegúrate de que `~/.local/bin` esté en tu `$PATH` para ejecutar el comando `fast-setup` desde cualquier lugar.

---

## 🚀 Uso del script

```bash
fast-setup <nombre_proyecto> [opciones]
```

### 🔹 Plantillas

* Las plantillas se definen en un único archivo de configuración:

```bash
~/.config/fast-setup/template.conf
```

* Cada plantilla puede contener **carpetas y archivos**, separados por `:`
* Los archivos existentes en la carpeta `templates/` (junto a `template.conf`) se copian automáticamente al proyecto.
* Si no existen, se crean vacíos.

#### Ejemplo de `template.conf`:

```ini
[default-c++]
src:main_{{PROJECT}}.cc,{{PROJECT}}.h
include:{{PROJECT}}.h
data:input.txt
docs
.:README.md
.:Makefile

[python]
src:main.py
tests:test_main.py
requirements.txt
```

* `.:Makefile` → copia `Makefile` desde `templates/Makefile` a la raíz del proyecto
* `src:main.cpp,project.h` → crea carpeta `src` con los archivos listados

#### Placeholder: `{{PROJECT}}`

El placeholder `{{PROJECT}}` se usa dentro de `template.conf` y en los archivos dentro de la carpeta `templates/` para indicar el nombre del proyecto que suministres al ejecutar el script.

- Sustitución por defecto: cuando ejecutas `fast-setup MiProyecto`, el script reemplaza todas las ocurrencias de `{{PROJECT}}` por `MiProyecto` en:
	- Nombres de carpetas definidos en `template.conf`.
	- Nombres de archivos listados en `template.conf`.
	- Contenido de archivos copiados desde `templates/` si contienen `{{PROJECT}}`.

- Ejemplo de uso:

	`template.conf`:

	```ini
	[default-c++]
	src:main_{{PROJECT}}.cc,{{PROJECT}}.h
	.:README.md
	```

	Al ejecutar `fast-setup MyLib -t default-c++` se generan `src/main_MyLib.cc`, `src/MyLib.h` y `README.md` cuyo contenido tendrá `MyLib` si el `templates/README.md` contenía `{{PROJECT}}`.

- Desactivar sustituciones: si pasas la opción `--no-placeholder` al script, el texto `{{PROJECT}}` no se reemplaza y quedará literalmente en los nombres y contenido (por ejemplo `main_{{PROJECT}}.cc`).

- Casos importantes a tener en cuenta:
	- El reemplazo se realiza con `sed` y no es seguro para binarios; evita usar `{{PROJECT}}` en plantillas binarias.
	- La sustitución es literal y sensible a mayúsculas: `{{project}}` no es lo mismo que `{{PROJECT}}`.
	- Si quieres transformar el nombre (mayúsculas/minúsculas) o usar otras variantes, puedo añadir soporte para `{{PROJECT_UPPER}}`/`{{PROJECT_LOWER}}`.

- Transformaciones disponibles:
	- `{{PROJECT_UPPER}}` → nombre del proyecto en mayúsculas.
	- `{{PROJECT_LOWER}}` → nombre del proyecto en minúsculas.
	Estas variantes funcionan tanto en nombres (carpetas/archivos) como en el contenido de archivos dentro de `templates/`.

- Nombres no seguros y validación:
	- Por defecto el script valida que `PROJECT_NAME` use solo caracteres alfanuméricos, guiones, guiones bajos y puntos (`[A-Za-z0-9._-]`).
	- Si necesitas usar caracteres especiales, pasa la opción `--allow-unsafe-name` (no recomendado; responsabilidad del usuario).

- `--dry-run`:
	- Muestra las acciones que se ejecutarían sin modificar el disco (útil para comprobar la estructura resultante antes de crear archivos).

---

### Ejemplo de `--dry-run`

```bash
# Ver qué crearías sin ejecutar cambios
fast-setup MiProyecto -t default-c++ --dry-run
```

Si quieres que implemente validación del nombre del proyecto o escape seguro para la sustitución en `sed`, dímelo y lo añado.

---

### ▶️ Opciones del script

| Opción                                | Descripción                                                                                                                 |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `-h`, `--help`                        | Muestra la ayuda                                                                                                            |
| `-v`, `--version`                     | Muestra la versión del script                                                                                               |
| `-l`, `--list`                        | Lista las plantillas disponibles                                                                                            |
| `-t <template>`                       | Selecciona la plantilla (por defecto: `default-c++`)                                                                        |
| `--force`                             | Sobrescribe el directorio si ya existe                                                                                      |
| `--dry-run`                           | Muestra las acciones que se realizarían sin crear ni modificar archivos                                                     |
| `--allow-unsafe-name`                 | Permite nombres de proyecto con caracteres no estándar (no recomendado)                                                     |
| `-p <path>`, `--template-path <path>` | Especifica un archivo `template.conf` personalizado                                                                         |
| `--no-placeholder`                    | Desactiva el placeholder '{{PROJECT}}' en `template.conf` para no ser sustituido automáticamente por el nombre del proyecto |

---

### 📌 Ejemplos de uso

```bash
# Crear un proyecto con la plantilla por defecto
fast-setup MiProyecto

# Crear un proyecto usando la plantilla Python
fast-setup MiProyecto -t python

# Sobrescribir un proyecto existente
fast-setup MiProyecto -t default-c++ --force

# Usar un archivo de plantillas personalizado
fast-setup MiProyecto -p ~/mis-plantillas/template.conf -t python

# Listar plantillas disponibles
fast-setup -l
```

---

## 📝 Notas importantes

* Todos los archivos existentes en la carpeta `templates/` relativa al `templates.conf` se copiarán al proyecto automáticamente (ej. `makefile`).
* Archivos que no existan se crean vacíos.
* La opción `--template-path` permite usar diferentes colecciones de plantillas según tu flujo de trabajo.
* Mantener `legacy/` para referencia de versiones anteriores.

### Estructura del Proyecto

```
fast-setup/
├── legacy/
│   ├── v1-bash/README.md
│   ├── v2-python-json/README.md
│   ├── v3-python-yaml/README.md
│   └── v4-python-full/README.md
├── templates/
│   ├── template.conf
│   ├── makefile
│   └── ...
├── fast-setup.sh
├── install.sh
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