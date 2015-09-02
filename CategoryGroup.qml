import QtQuick 2.0

Rectangle {
    width: parent / 3;
    height: 62;
    property alias text: tx.text;

    Text {
        id: tx;
        font.bold: true;
    }
}

