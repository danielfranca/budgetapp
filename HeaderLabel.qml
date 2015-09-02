import QtQuick 2.0

Rectangle {
    width: parent.width / 4;
    height: 30;
    property alias text: tx.text;

    Text {
        id: tx;
        font.family: "Helvetica";
        font.pixelSize: 20;

        anchors.verticalCenter: parent.verticalCenter;
    }
}

