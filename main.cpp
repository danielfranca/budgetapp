#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    //engine.addImportPath("/Users/dfranca/workspace/Qt/qml-material/modules");
    //engine.addImportPath("/Users/dfranca/workspace/Qt/qml-material/modules/Material");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
