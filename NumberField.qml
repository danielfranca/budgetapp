import QtQuick 2.0

Rectangle {
    width: parent.width / 4;
    height: 30;
    property alias text: tx.text;

    TextEdit {
        id: tx;
        x: 5
        font.italic: true;
        inputMethodHints: Qt.ImhFormattedNumbersOnly;
    }
}

