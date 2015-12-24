#include <QApplication>
#include <QQmlApplicationEngine>

#include <QtQuickTest/quicktest.h>
//#define __TEST__

#ifdef __TEST__
QUICK_TEST_MAIN(budgetApp)
#else
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/modules/");
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
#endif
