# Universidad de La Laguna
# Escuela Superior de Ingeniería y Tecnología
# Grado en Ingeniería Informática
# @author Tomás Pino Pérez
# @date 13/9/23
# @brief compila desde src/ a build/obj/ y enlaza en build/bin/
#        genera dependencias automáticas y provee objetivos útiles
# Propósito:
#   - Compilar los .cc de src/ a objetos en build/obj/
#   - Enlazar un binario en build/bin/
#   - Generar dependencias automáticas (.d) para recompilar cuando cambian headers
#   - Proveer objetivos útiles: all (por defecto), run, tar y clean
#
# Uso rápido:
#   make            # compila todo (incremental)
#   make -j4        # compila en paralelo (4 hilos)
#   make run ARGS="arg1 arg2"  # ejecuta el binario con argumentos
#   make tar        # empaqueta usando 00_other_files/fast_tgz.sh (puede fallar si el script no está)
#   make untar ARCHIVE=miarchivo.tgz [DEST=destino]  # descomprime un .tgz en DEST (.) (DEST opcional)
#   make help       # muestra este mensaje de ayuda
#   make clean      # borra build/
#
# Notas:
#   - Mantener include/ en CXXFLAGS con -Iinclude permite usar #include "Foo.h"
#   - DEPFLAGS genera archivos .d; -include $(OBJS:.o=.d) los incorpora a Make
#   - Para forzar una compilación limpia: make clean && make

# Compilador (variable que define el compilador a usar)
CXX := g++

# Opciones de compilación principales
# -std=c++17 : estándar C++
# -g         : símbolos de depuración
# -Wall -Wextra: advertencias
# -Iinclude  : búsqueda de headers en include/
CXXFLAGS := -std=c++17 -g -Wall -Wextra -Iinclude

# Flags para generar dependencias automáticas (.d files)
# -MMD: genera fichero .d con dependencias (excluye dependencias de sistema)
# -MP: añade phony targets para cada dependencia (evita errores si se borran headers)
DEPFLAGS := -MMD -MP

# Directorio base para artefactos (objetos y binario)
BUILD_DIR := build

# Buscar fuentes de forma flexible: primero en src/, luego en directorio actual
SRCS := $(shell find src -name '*.cc' 2>/dev/null || find . -maxdepth 1 -name '*.cc')
OBJS := $(patsubst %.cc,$(BUILD_DIR)/obj/%.o,$(notdir $(SRCS)))

# Ejecutable final (dentro de build/)
TARGET := $(BUILD_DIR)/$(notdir $(CURDIR))

# Objetivo por defecto: compilar y generar el ejecutable
all: $(TARGET)

# Regla patrón: compilar archivos .cc -> build/obj/%.o
# - Busca el archivo fuente en src/ o en directorio actual
# - Crea el directorio si es necesario
# - Compila e invoca DEPFLAGS para generar dependencias .d
$(BUILD_DIR)/obj/%.o: 
	@mkdir -p $(dir $@)
	@if [ -f "src/$*.cc" ]; then \
		echo "# Compiling: src/$*.cc"; \
		$(CXX) $(CXXFLAGS) $(DEPFLAGS) -c -o $@ src/$*.cc; \
	elif [ -f "$*.cc" ]; then \
		echo "# Compiling: $*.cc"; \
		$(CXX) $(CXXFLAGS) $(DEPFLAGS) -c -o $@ $*.cc; \
	else \
		echo "Error: No se encontró $*.cc"; \
		exit 1; \
	fi
	@echo "+ State: $@ created"

# Regla de enlace: cuando todos los .o están listos, enlaza el binario
# - Asegura que el directorio de salida exista
$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	@echo "# Linking: $@"
	$(CXX) $(CXXFLAGS) -o $@ $^

# Ejecutar el binario: use `make run` y opcionalmente `ARGS="a b c" make run`
run: $(TARGET)
	@echo "# Running: $(TARGET) $(ARGS)"
	@if [ -z "$(ARGS)" ]; then ./$(TARGET); else ./$(TARGET) $(ARGS); fi
	@echo "+ State: done"

# Empaquetar el directorio del proyecto usando fast-tgz.sh
# - Usa el script fast-tgz.sh con la opción -a (aplanar)
# - Si el script falla, el objetivo devolverá error
tar:
	@echo "# Compressing with fast-tgz"
	@./../00_other_files/fast-tgz.sh -a -c $(CURDIR) -o $(CURDIR) || { echo "- State: fast-tgz failed"; exit 1; }
	@echo "+ State: done"

# Descomprimir un .tgz (por defecto usa $(notdir $(CURDIR)).tgz)
# Uso: make untar ARCHIVE=miarchivo.tgz DEST=destino
ARCHIVE ?= $(notdir $(CURDIR)).tgz
DEST ?= .

untar:
	@echo "# Extracting: $(ARCHIVE) -> $(DEST)"
	@if [ ! -f "$(ARCHIVE)" ]; then echo "- State: archive '$(ARCHIVE)' not found"; exit 1; fi
	@mkdir -p $(DEST)
	@tar -xzf $(ARCHIVE) -C $(DEST)
	@echo "+ State: done"

# Mensaje de ayuda
help:
	@echo "Makefile usage:"
	@echo "  make           # compila todo (incremental)"
	@echo "  make -j4       # compila en paralelo (4 hilos)"
	@echo "  make run ARGS=\"arg1 arg2\"  # ejecuta el binario con argumentos"
	@echo "  make tar       # empaqueta usando 00_other_files/fast_tgz.sh"
	@echo "  make untar ARCHIVE=miarchivo.tgz [DEST=destino]  # descomprime un .tgz en DEST (.) (DEST opcional)"
	@echo "  make clean     # borra build/"

# Limpiar archivos generados
clean:
	@echo "# Cleaning"
	@rm -rf $(BUILD_DIR)
	@echo "+ State: done"

# Incluir automáticamente los ficheros .d generados por DEPFLAGS
# -include evita error si los .d no existen todavía (primera compilación)
-include $(OBJS:.o=.d)

# Objetivos que no son ficheros
.PHONY: all run tar untar help clean