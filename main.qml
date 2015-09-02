import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Extras 1.4
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
//import Material.Action 0.1
import Material 0.1 as Material
import Material.ListItems 0.1 as ListItem
//import "/Users/dfranca/workspace/Qt/qml-material/modules/Material/" as Material

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

    function isNewCategoryGroup(index) {
        console.log("Index: " + index);
        var currentItem = budgetList.model.get(index);
        console.log(JSON.stringify(currentItem));
        var newOne = true;

        if (index > 0) {
            var oldItem = budgetList.model.get(index-1);
            console.log(JSON.stringify(oldItem));
            newOne = (oldItem.group !== currentItem.group);
        }

        console.log("Is new category group? " + newOne);

        return newOne;
    }

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

    Material.AwesomeIcon {}

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

    Rectangle {
        id: formNewCategory
        width: parent.width * 0.8
        height: parent.height * 0.5
        color: "white";
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0
        z: 100



        Text {
            id: name
            text: qsTr("text")
        }

    }

    ListView {
        id: budgetList
        model: ListModel {
            ListElement {
                group: "Tiberinho & Pablo"
                category: "Daycare/Hotel"
                budgeted: 50
                outflow: 0
            }
            ListElement {
                group: "Tibérinho & Pablo"
                category: "Wash"
                budgeted: 0
                outflow: 0
            }
            ListElement {
                group: "Monthly Bills"
                category: "Mortgage"
                budgeted: 930
                outflow: 930
            }
            ListElement {
                group: "Monthly Bills"
                category: "Ziggo"
                budgeted: 56
                outflow: 56
            }
            ListElement {
                group: "Monthly Bills"
                category: "Eletricity/Gas"
                budgeted: 130
                outflow: 124
            }
            ListElement {
                group: "Monthly Bills"
                category: "T-Mobile"
                budgeted: 130
                outflow: 65
            }
            ListElement {
                group: "Everyday Expenses"
                category: "Groceries"
                budgeted: 200
                outflow: 153.75
            }
        }

        clip: true
        width: parent.width
        height: parent.height - 70
        anchors.top: topBar.bottom

        header: Row {
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: 5

            HeaderLabel {
                id: categoriesLabel
                text: qsTr("Categories");
            }

            HeaderLabel {
                id: budgetLabel
                text: qsTr("Budgeted");
            }

            HeaderLabel {
                text: qsTr("Outflows");
            }
            HeaderLabel {
                text: qsTr("Balance");
            }
        }

        delegate: Rectangle {

                width: parent.width
                height: 30
                property bool newCategoryGroup: isNewCategoryGroup(index);

                Rectangle {
                    color: "royalblue"
                    id: groupName
                    anchors.top: parent.top

                    Component.onCompleted: {
                        parent.height = (newCategoryGroup)?parent.height * 2: parent.height;
                    }

                    width: (newCategoryGroup)?parent.width: 0;
                    height: (newCategoryGroup)?30: 0;

                    Text {
                         text: (newCategoryGroup)?" (-) " + group: "";
                         color: "white";
                         anchors.verticalCenter: parent.verticalCenter
                         x: 3
                         font.bold: true
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 30
                    anchors.bottom: parent.bottom
                    Row {
                        height: parent.height
                        width: parent.width
                        CategoryField {
                            text: " (-) " + category;
                            color: "lightcyan";
                        }
                        NumberField {
                            text: budgeted;
                            color: "lightblue";
                        }
                        NumberField {
                            text: outflow;
                            color: "lightcyan";
                        }
                        NumberField {
                            text: budgeted - outflow;
                            color: "lightblue";
                        }
                    }
                }
        }

        footer: Component {
            Text {
                text: "Add Category..."
                width: parent.width
                height: 100
                font.family: "Helvetica"
                z: 1000

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (formNewCategory.opacity == 0) {
                            formNewCategory.opacity = 0.9;
                        }
                        else {
                            formNewCategory.opacity = 0;
                        }
                    }
                }
            }
        }

    }

}
