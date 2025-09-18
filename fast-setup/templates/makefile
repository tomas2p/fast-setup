# Universidad de La Laguna
# Escuela Superior de Ingeniería y Tecnología
# Grado en Ingeniería Informática
# @author Tomás Pino Pérez
# @date 13/9/23
# @brief compila desde src/

# Compilador
CXX=g++
# Lista de opciones de compilación
CXXFLAGS=-g -Wall
# Nombre común y ejecutable
TARGET=ejecutable
# Lista de archivos fuente
SRCS=$(shell find src/ -name '*.cc')
# Ruta de achivo compilado
BUILD_DIR=build
# Ruta del directorio
DIR_NAME=$(shell basename $(shell realpath .))

# Definir el objetivo "all" para compilar
# all: build run

# Regla para compilar y luego ejecutar
dev: build run

# Regla para compilar y luego comprimir
release: build tar

# Regla para construir el programa y crear la carpeta de construcción
build: dir program

# Crear la carpeta de construcción si no existe
dir:
	@if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p $(BUILD_DIR); fi

# Regla principal para construir el programa
program: $(SRCS)
	@echo "# Making: $(TARGET)"
	@$(CXX) $(CXXFLAGS) -o $(BUILD_DIR)/$(TARGET) $^
	@echo "+ State: ready"

# Regla que compila y ejecuta con ARGS="param1 param2"
run: program
	@if [ -z "$(ARGS)" ]; then ./$(BUILD_DIR)/$(TARGET); else ./$(BUILD_DIR)/$(TARGET) $(ARGS); fi

# Regla que comprime el directorio en tar.gz
tar: 
	cd ..; tar -czvf ./tpp-$(DIR_NAME).tar.gz $(DIR_NAME)

# Limpieza de archivos generados
clean:
	@echo "# Deleting: $(TARGET)"
	@rm -r $(BUILD_DIR)
	@echo "+ State: ready"

# Indica que all y clean no corresponde a archivos
.PHONY: clean all