TEMPLATE = app

QT += qml quick widgets sql

SOURCES += main.cpp

RESOURCES += qml.qrc

CONFIG += qml_debug

QTPLUGIN += qsvg

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = /Users/dfranca/workspace/Qt/qml-material/modules

# Default rules for deployment.
include(deployment.pri)
