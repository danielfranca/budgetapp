#include <QApplication>
#include <QQmlApplicationEngine>

#include <QtQuickTest/quicktest.h>
//QUICK_TEST_MAIN(budgetApp)

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/modules/");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
