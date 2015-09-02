import QtQuick 2.0

Rectangle {
    width: parent.width / 4;
    height: 40;
    property string group: "";
    property alias text: tx.text;

    TextEdit {
        id: tx;
        x: 5
    }
}

