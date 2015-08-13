import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

ApplicationWindow {
    title: qsTr("Budget")
    width: 640
    height: 1136
    visible: true
    color: "lightcyan"
    property var months: ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    property var monthNames: {
        "JAN": "January",
        "FEB": "February",
        "MAR": "March",
        "APR": "April",
        "MAY": "May",
        "JUN": "June",
        "JUL": "July",
        "AUG": "August",
        "SEP": "September",
        "OCT": "October",
        "NOV": "November",
        "DEC": "December"
    };

    function findMonth(currentTitle, next) {

        var splitted = currentTitle.split(" ");
        var month = splitted[0].toUpperCase().slice(0, 3);
        var year = parseInt(splitted[1]);
        var monthFound;

        var idx = months.indexOf(month);
        if (next) {
            if (idx >= 0 && idx < 11) {
                monthFound = months[idx + 1];
            }
            else if (idx === 11) {
                monthFound = months[0];
                year++;
            }
        }
        else {
            if (idx > 0 && idx <= 11) {
                monthFound = months[idx - 1];
            }
            else if (idx === 0) {
                monthFound = months[11];
                year--;
            }
        }

        return monthNames[monthFound] + " " + year;
    }

    Rectangle {
        id: topBar
        color: "lightblue";
        height: 70
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        SwipeArea {
            anchors.fill: parent
            onSwipe: {
                switch (direction) {
                case "left":
                    monthTitle.text = findMonth(monthTitle.text, true);
                    break
                case "right":
                    monthTitle.text = findMonth(monthTitle.text);
                    break
                }
            }
        }

        Text {
            text: "<";
            font.pointSize: 48;
            font.family: "Segoe UI";
            color: "white"; //"lightslategray";
            anchors.verticalCenter: parent.verticalCenter;
            anchors.left: parent.left;

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    monthTitle.text = findMonth(monthTitle.text);
                }
            }
        }

        Text {
            text: ">";
            font.pointSize: 48;
            font.family: "Segoe UI";
            color: "white"; //"lightslategray";
            anchors.verticalCenter: parent.verticalCenter;
            anchors.right: parent.right;

            MouseArea {
                anchors.fill: parent;

                onClicked: {
                    monthTitle.text = findMonth(monthTitle.text, true);
                }
            }
        }

        Text {
            id: monthTitle

            text: qsTr("November 2015");
            font.family: "Segoe UI";
            font.pointSize: 30;
            color: "lightslategray";
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.verticalCenter: parent.verticalCenter;

        }
    }

    ListView {
        model: 10
        clip: true
        width: parent.width
        height: parent.height - 70
        anchors.top: topBar.bottom

        Row {
            Text {
                text: qsTr("Category");
            }
            TextField {
            }
        }
    }
}
