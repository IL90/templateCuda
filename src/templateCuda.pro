
TARGET = out
QT -= gui core

CONFIG += release console
CONFIG -= app_bundle
TEMPLATE = app
#PROJECT_DIR = $$system(pwd)
DESTDIR = ../bin
OBJECTS_DIR = ../obj/

INCLUDEPATH += .
DEPENDPATH += .

# Input
HEADERS += \
Opener.h

SOURCES += \
main.cpp

###CUDA###
CUDA_DIR = /usr/local/cuda
INCLUDEPATH += $$CUDA_DIR/include

QMAKE_LIBDIR += $$CUDA_DIR/lib64
CUDA_ARCH = sm_20
CUDA_SOURCES += \
functions.cu \
func.cu

LIBS += -lcudart -lcuda

cuda.commands = nvcc -c -Xcompiler $$join(QMAKE_CXXFLAGS,",") $$join(INCLUDEPATH,'" -I "','-I "','"') ${QMAKE_FILE_NAME} -o ${QMAKE_FILE_OUT}

cuda.dependcy_type = TYPE_C
cuda.depend_command = nvcc -M -Xcompiler $$join(QMAKE_CXXFLAGS,",") $$join(INCLUDEPATH,'" -I "','-I "','"') ${QMAKE_FILE_NAME} | sed "s,^.*: ,," | sed "s,^ *,," | tr -d '\\\n'

cuda.input = CUDA_SOURCES
cuda.output = ${OBJECTS_DIR}cu/${QMAKE_FILE_BASE}_cuda.o

QMAKE_EXTRA_UNIX_COMPILERS += cuda
#QMAKE_EXTRA_COMPILERS += cuda
########################################################################