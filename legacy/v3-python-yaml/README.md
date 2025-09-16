# Fast-Setup

**Fast-Setup** is a command-line tool designed to streamline project creation by automating directory and file setup based on predefined templates.

1. [About](#about)
   1. [Features](#features)
2. [Usage](#usage)
   1. [Requirements](#requirements)
   2. [Installation](#installation)
   3. [Running the Script](#running-the-script)
   4. [Example](#example)
3. [Templates](#templates)
   1. [Template Folder](#template-folder)
4. [License](#license)

## About

Fast-Setup helps developers save time by creating a standardized project structure with minimal effort. It automatically generates directories and files, and optionally populates them from a `templates` folder if available.

Author: Tomás Pino Pérez
### Features

- Dynamically creates directories and files based on templates or as empty placeholders.
- Supports project-specific customization using a `project_name` placeholder.
- Simple and extendable YAML configuration for defining project structures.
- Automatically copies files and directories from a `templates` folder if they exist.

## Usage
### Requirements

- Python 3.6 or newer
- `PyYAML` library: `pip install PyYAML`

### Installation

Clone the repository:

```bash
git clone https://github.com/Tomas2p/Fast-Setup.git
cd Fast-Setup
```

### Running the Script

To create a new project:
```bash
python fast-setup.py <project_name> [template]
```

Arguments:
- `<project_name>`: The name of your project.
- `[template]`: (Optional) The name of the template to use. Defaults to `default-c++`.

### Example

```bash
python fast-setup.py MyNewProject
```

## Templates

Templates are defined in the `structure.yaml` file and look like this:
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

### Template Folder

Place reusable files in the `templates` directory. Fast-Setup will copy these files to the appropriate locations if they exist. If no template file is found, it creates an empty file.

For example:
- `templates/Makefile` → Copies to the root of the project.
- `templates/docs/README.md` → Copies to docs/README.md.

## License

This project is licensed under the MIT License. See the [LICENSE file](../LICENSE) for details.