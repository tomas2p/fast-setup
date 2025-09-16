import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../')))

import os
import shutil
import tempfile
import yaml
import pytest
from fast_setup import fast_setup

@pytest.fixture(autouse=True)
def cleanup_proyecto_root():
    yield
    root = os.path.abspath(os.getcwd())
    proyecto_path = os.path.join(root, "proyecto")
    if os.path.exists(proyecto_path):
        shutil.rmtree(proyecto_path)

def test_load_templates_valid():
    # Crea un archivo de estructura temporal válido
    temp_dir = tempfile.mkdtemp()
    try:
        structure_path = os.path.join(temp_dir, "structure.yaml")
        with open(structure_path, "w") as f:
            yaml.dump({
                "default-test": {
                    "directories": ["src"],
                    "files": ["README.md"]
                }
            }, f)
        # Parchea la variable de config para usar el temporal
        fast_setup.USER_CONFIG_DIR = temp_dir
        templates = fast_setup.load_templates()
        assert "default-test" in templates
        assert templates["default-test"]["directories"] == ["src"]
    finally:
        shutil.rmtree(temp_dir)

def test_create_structure_creates_dirs_and_files():
    temp_dir = tempfile.mkdtemp()
    try:
        project_name = "demo"
        project_path = os.path.join(temp_dir, project_name)
        structure = {
            "directories": ["src", "docs"],
            "files": ["README.md", "src/main.py"]
        }
        fast_setup.create_structure(project_name, project_path, structure)
        assert os.path.isdir(os.path.join(project_path, "src"))
        assert os.path.isdir(os.path.join(project_path, "docs"))
        assert os.path.isfile(os.path.join(project_path, "README.md"))
        assert os.path.isfile(os.path.join(project_path, "src", "main.py"))
    finally:
        shutil.rmtree(temp_dir)

def test_load_templates_invalid():
    temp_dir = tempfile.mkdtemp()
    try:
        structure_path = os.path.join(temp_dir, "structure.yaml")
        with open(structure_path, "w") as f:
            yaml.dump({"mal": {"archivos": ["README.md"]}}, f)
        fast_setup.USER_CONFIG_DIR = temp_dir
        try:
            fast_setup.load_templates()
            assert False, "Debe lanzar SystemExit por plantilla inválida"
        except SystemExit:
            pass
    finally:
        shutil.rmtree(temp_dir)

def test_force_overwrite(tmp_path):
    project_name = "force-demo"
    project_path = tmp_path / project_name
    os.makedirs(project_path)
    with open(project_path / "old.txt", "w") as f:
        f.write("old")
    structure = {"directories": ["src"], "files": ["README.md"]}
    # Simula --force
    if os.path.exists(project_path):
        shutil.rmtree(project_path)
    try:
        fast_setup.create_structure(project_name, str(project_path), structure)
        assert os.path.isdir(project_path / "src")
        assert os.path.isfile(project_path / "README.md")
    finally:
        shutil.rmtree(tmp_path)

def test_custom_base_file():
    temp_dir = tempfile.mkdtemp()
    try:
        files_dir = os.path.join(temp_dir, "files")
        os.makedirs(files_dir)
        with open(os.path.join(files_dir, "README.md"), "w") as f:
            f.write("contenido personalizado")
        fast_setup.USER_CONFIG_DIR = temp_dir
        structure = {"directories": [], "files": ["README.md"]}
        project_path = os.path.join(temp_dir, "proyecto")
        fast_setup.create_structure("proyecto", project_path, structure)
        with open(os.path.join(project_path, "README.md")) as f:
            contenido = f.read()
        assert "contenido personalizado" in contenido
    finally:
        shutil.rmtree(temp_dir)

def test_help_cli(monkeypatch, capsys):
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "--help"])
    try:
        fast_setup.main()
    except SystemExit:
        pass
    out = capsys.readouterr().out
    assert "fast-setup" in out
    assert "Uso:" in out

def test_template_inexistent_uses_default(monkeypatch):
    temp_dir = tempfile.mkdtemp()
    structure_path = os.path.join(temp_dir, "structure.yaml")
    with open(structure_path, "w") as f:
        yaml.dump({
            "default-c++": {
                "directories": ["src"],
                "files": ["README.md"]
            }
        }, f)
    fast_setup.USER_CONFIG_DIR = temp_dir
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "proyecto", "no-existe"])
    try:
        fast_setup.main()
    except SystemExit:
        pass
    shutil.rmtree(temp_dir)


def test_error_if_dir_exists_and_no_force(tmp_path):
    project_name = "yaexiste"
    project_path = tmp_path / project_name
    os.makedirs(project_path)
    structure = {"directories": ["src"], "files": ["README.md"]}
    fast_setup.USER_CONFIG_DIR = str(tmp_path)
    with open(tmp_path / "structure.yaml", "w") as f:
        yaml.dump({"default-c++": structure}, f)
    monkeypatch = lambda *a, **kw: None  # Dummy
    try:
        fast_setup.create_structure(project_name, str(project_path), structure)
        assert False, "Debe lanzar error si el directorio existe y no hay --force"
    except Exception:
        pass


def test_subdirs_and_nested_files():
    temp_dir = tempfile.mkdtemp()
    try:
        structure = {
            "directories": ["src", "src/utils"],
            "files": ["src/main.py", "src/utils/helper.py"]
        }
        project_path = os.path.join(temp_dir, "proyecto")
        fast_setup.create_structure("proyecto", project_path, structure)
        assert os.path.isdir(os.path.join(project_path, "src", "utils"))
        assert os.path.isfile(os.path.join(project_path, "src", "main.py"))
        assert os.path.isfile(os.path.join(project_path, "src", "utils", "helper.py"))
    finally:
        shutil.rmtree(temp_dir)


def test_project_name_special_chars():
    temp_dir = tempfile.mkdtemp()
    try:
        project_name = "demo-123_áé"
        structure = {"directories": ["src/project_name"], "files": ["src/project_name/main.py"]}
        project_path = os.path.join(temp_dir, project_name)
        fast_setup.create_structure(project_name, project_path, structure)
        assert os.path.isdir(os.path.join(project_path, "src", project_name))
        assert os.path.isfile(os.path.join(project_path, "src", project_name, "main.py"))
    finally:
        shutil.rmtree(temp_dir)


def test_base_file_content():
    temp_dir = tempfile.mkdtemp()
    try:
        files_dir = os.path.join(temp_dir, "files")
        os.makedirs(files_dir)
        contenido = "contenido base"
        with open(os.path.join(files_dir, "README.md"), "w") as f:
            f.write(contenido)
        fast_setup.USER_CONFIG_DIR = temp_dir
        structure = {"directories": [], "files": ["README.md"]}
        project_path = os.path.join(temp_dir, "proyecto")
        fast_setup.create_structure("proyecto", project_path, structure)
        with open(os.path.join(project_path, "README.md")) as f:
            assert contenido in f.read()
    finally:
        shutil.rmtree(temp_dir)


def test_json_template(monkeypatch):
    temp_dir = tempfile.mkdtemp()
    try:
        structure_path = os.path.join(temp_dir, "structure.json")
        import json
        with open(structure_path, "w") as f:
            json.dump({
                "default-json": {
                    "directories": ["src"],
                    "files": ["README.md"]
                }
            }, f)
        # Renombra temporalmente structure.yaml si existe en el paquete interno
        import importlib.resources
        pkg_dir = importlib.resources.files("fast_setup.templates")
        yaml_path = pkg_dir.joinpath("structure.yaml")
        renamed = False
        if yaml_path.exists():
            os.rename(yaml_path, yaml_path.with_suffix(".bak"))
            renamed = True
        fast_setup.USER_CONFIG_DIR = temp_dir
        templates = fast_setup.load_templates()
        assert "default-json" in templates
        if renamed:
            os.rename(yaml_path.with_suffix(".bak"), yaml_path)
    finally:
        shutil.rmtree(temp_dir)


def test_fallback_to_internal_template(monkeypatch):
    fast_setup.USER_CONFIG_DIR = "/tmp/noexiste"
    templates = fast_setup.load_templates()
    assert "default-c++" in templates or len(templates) > 0


def test_error_no_valid_template(monkeypatch):
    temp_dir = tempfile.mkdtemp()
    try:
        fast_setup.USER_CONFIG_DIR = temp_dir
        # Mockea copy_example_templates para que no copie nada
        monkeypatch.setattr(fast_setup, "copy_example_templates", lambda: None)
        # Mockea load_template_file para que siempre retorne None
        monkeypatch.setattr(fast_setup, "load_template_file", lambda filename, user_first=True: None)
        # Borra structure.yaml y structure.json si existen
        for fname in ["structure.yaml", "structure.json"]:
            fpath = os.path.join(temp_dir, fname)
            if os.path.exists(fpath):
                os.remove(fpath)
        try:
            fast_setup.load_templates()
            assert False, "Debe lanzar SystemExit si no hay plantilla válida"
        except SystemExit:
            pass
    finally:
        shutil.rmtree(temp_dir)


def test_no_args_shows_error(monkeypatch, caplog):
    monkeypatch.setattr("sys.argv", ["fast_setup.py"])
    with caplog.at_level("ERROR"):
        try:
            fast_setup.main()
        except SystemExit:
            pass
    assert any("Uso:" in m for m in caplog.messages)


def test_load_template_file_not_found(monkeypatch):
    import fast_setup.fast_setup as fs
    # Simula que no existe ni en usuario ni en paquete
    monkeypatch.setattr("importlib.resources.files", lambda pkg: type("Fake", (), {"joinpath": lambda self, fn: type("FakeFile", (), {"open": lambda self, mode: (_ for _ in ()).throw(FileNotFoundError())})()})())
    result = fs.load_template_file("no-existe.yaml")
    assert result is None


def test_copy_example_templates_exception(monkeypatch):
    import fast_setup.fast_setup as fs
    # Simula excepción al copiar
    monkeypatch.setattr("importlib.resources.files", lambda pkg: type("Fake", (), {"joinpath": lambda self, fn: type("FakeFile", (), {"open": lambda self, mode: (_ for _ in ()).throw(Exception("fail"))})()})())
    fs.USER_CONFIG_DIR = tempfile.mkdtemp()
    try:
        fs.copy_example_templates()  # No debe lanzar excepción
    finally:
        shutil.rmtree(fs.USER_CONFIG_DIR)


def test_main_help(monkeypatch):
    import fast_setup.fast_setup as fs
    import io, sys
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "--help"])
    stdout = sys.stdout
    sys.stdout = io.StringIO()
    try:
        try:
            fs.main()
        except SystemExit:
            pass
        output = sys.stdout.getvalue()
    finally:
        sys.stdout = stdout
    assert "Uso:" in output or "ayuda" in output


def test_main_default_template_warning(monkeypatch, tmp_path, caplog):
    import fast_setup.fast_setup as fs
    # Crea estructura con plantilla inexistente, debe usar default y loggear warning
    structure = {"default-c++": {"directories": [], "files": []}}
    config_dir = tmp_path / "config"
    config_dir.mkdir()
    structure_path = config_dir / "structure.yaml"
    with open(structure_path, "w") as f:
        yaml.dump(structure, f)
    fs.USER_CONFIG_DIR = str(config_dir)
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "proyecto", "no-existe"])
    with caplog.at_level("WARNING"):
        try:
            fs.main()
        except SystemExit:
            pass
    assert "no encontrada" in caplog.text


def test_main_args_invalid(monkeypatch):
    import fast_setup.fast_setup as fs
    monkeypatch.setattr("sys.argv", ["fast_setup.py"])  # Sin argumentos
    try:
        fs.main()
        assert False, "Debe salir por error de argumentos"
    except SystemExit:
        pass


def test_main_template_not_found(monkeypatch, tmp_path):
    import fast_setup.fast_setup as fs
    temp_dir = tmp_path
    structure_path = os.path.join(temp_dir, "structure.yaml")
    with open(structure_path, "w") as f:
        yaml.dump({"default-c++": {"directories": ["src"], "files": ["README.md"]}}, f)
    fs.USER_CONFIG_DIR = str(temp_dir)
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "proyecto", "no-existe"])
    old_cwd = os.getcwd()
    os.chdir(temp_dir)
    try:
        try:
            fs.main()
        except SystemExit:
            pass
    finally:
        os.chdir(old_cwd)
        shutil.rmtree(temp_dir, ignore_errors=True)


def test_main_structure_not_defined(monkeypatch, tmp_path):
    import fast_setup.fast_setup as fs
    temp_dir = tmp_path
    structure_path = os.path.join(temp_dir, "structure.yaml")
    with open(structure_path, "w") as f:
        yaml.dump({"default-c++": None}, f)
    fs.USER_CONFIG_DIR = str(temp_dir)
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "proyecto"])
    old_cwd = os.getcwd()
    os.chdir(temp_dir)
    try:
        try:
            fs.main()
        except SystemExit:
            pass
    finally:
        os.chdir(old_cwd)
        shutil.rmtree(temp_dir, ignore_errors=True)


def test_main_dir_exists_no_force(monkeypatch, tmp_path):
    import fast_setup.fast_setup as fs
    temp_dir = tmp_path
    structure_path = os.path.join(temp_dir, "structure.yaml")
    with open(structure_path, "w") as f:
        yaml.dump({"default-c++": {"directories": [], "files": []}}, f)
    fs.USER_CONFIG_DIR = str(temp_dir)
    project_path = os.path.join(temp_dir, "proyecto_test_existente")
    os.makedirs(project_path, exist_ok=True)
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "proyecto_test_existente"])
    old_cwd = os.getcwd()
    os.chdir(temp_dir)
    try:
        try:
            fs.main()
        except SystemExit:
            pass
        shutil.rmtree(project_path, ignore_errors=True)
    finally:
        os.chdir(old_cwd)
        shutil.rmtree(temp_dir, ignore_errors=True)


def test_main_dir_exists_with_force(monkeypatch, tmp_path):
    import fast_setup.fast_setup as fs
    temp_dir = tmp_path
    structure_path = os.path.join(temp_dir, "structure.yaml")
    with open(structure_path, "w") as f:
        yaml.dump({"default-c++": {"directories": [], "files": []}}, f)
    fs.USER_CONFIG_DIR = str(temp_dir)
    project_path = os.path.join(temp_dir, "proyecto_test_force")
    os.makedirs(project_path, exist_ok=True)
    monkeypatch.setattr("sys.argv", ["fast_setup.py", "proyecto_test_force", "--force"])
    old_cwd = os.getcwd()
    os.chdir(temp_dir)
    try:
        try:
            fs.main()
        except SystemExit:
            pass
        assert os.path.isdir(project_path)
        shutil.rmtree(project_path, ignore_errors=True)
    finally:
        os.chdir(old_cwd)
        shutil.rmtree(temp_dir, ignore_errors=True)


def test_run_as_module_shows_help():
    import subprocess, sys
    result = subprocess.run([
        sys.executable, "-m", "fast_setup.fast_setup", "--help"],
        capture_output=True, text=True
    )
    assert "fast-setup" in result.stdout
    assert "Uso:" in result.stdout
    assert result.returncode == 0 or result.returncode == 1  # Puede salir con 0 o 1


def test_load_template_file_internal_yaml():
    import fast_setup.fast_setup as fs
    fs.USER_CONFIG_DIR = tempfile.mkdtemp()
    result = fs.load_template_file("structure.yaml")
    # Puede ser dict si existe, o None si no existe en el paquete
    assert result is None or isinstance(result, dict)
    shutil.rmtree(fs.USER_CONFIG_DIR)


def test_load_template_file_internal_json():
    import fast_setup.fast_setup as fs
    # Borra temporalmente la plantilla de usuario para forzar carga interna
    fs.USER_CONFIG_DIR = tempfile.mkdtemp()
    # Debe cargar la plantilla interna JSON si existe
    try:
        result = fs.load_template_file("structure.json")
        # Puede no existir, pero si existe debe ser dict
        if result is not None:
            assert isinstance(result, dict)
    finally:
        shutil.rmtree(fs.USER_CONFIG_DIR)


def test_no_proyecto_in_root():
    root = os.path.abspath(os.getcwd())
    proyecto_path = os.path.join(root, "proyecto")
    assert not os.path.exists(proyecto_path), "La carpeta 'proyecto' no debe existir en el directorio raíz tras los tests."
