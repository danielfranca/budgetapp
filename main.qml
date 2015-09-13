import QtQuick 2.4
import Material.ListItems 0.1 as ListItem
import Material 0.1;
import Material.Extras 0.1;

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

    theme {
        primaryColor: Palette.colors["blue"]["500"]
        primaryDarkColor: Palette.colors["blue"]["700"]
        accentColor: Palette.colors["teal"]["500"]
        tabHighlightColor: "white"
    }

    initialPage: Page {
        id: page
        title: "Budget App"
        tabs: months

        actions: [
            Action {
                iconName: "action/search"
                name: "Search"
                enabled: false
            },
            Action {
                iconName: "action/settings"
                name: "Settings"
                //hoverAnimation: true
            }
        ]

        TabView {
            id: monthsView
            anchors.fill: parent
            currentIndex: 0
            model: months

            delegate: Item {
                width: monthsView.width
                height: monthsView.height
                clip: true

                property string selectedComponent: modelData[0]

                ListView {
                    id: listViewCategories
                    anchors.fill: parent
                    model: modelCategories

                    delegate: Component {
                        View {
                            id: viewCategory
                            backgroundColor: theme.tabHighlightColor;
                            elevation: 1
                            width: listViewCategories.width
                            height: 50

                            ListItem.Subheader {
                                text: group
                                height: parent.height / 2
                                width: parent.width
                            }

                            ListItem.Subtitled {
                                id: itemCategory
                                height: parent.height
                                width: parent.width / 2
                                text: category
                                secondaryItem: TextField {
                                    //floatingLabel: true
                                    placeholderText: "Budgeted"
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: budgeted
                                    font.pixelSize: Units.dp(12)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                }
                                subText: group

                                backgroundColor: theme.primaryColor;
                                tintColor: theme.tabHighlightColor
                                //valueText: "Budgeted"
                            }

                            /*TextEdit {
                                anchors.top: itemCategory.bottom

                                id: editBudgeted

                                text: budgeted
                                width: parent.width/2
                                height: parent.height
                            }

                            TextEdit {
                                anchors.top: itemCategory.bottom
                                anchors.left: editBudgeted.right

                                id: editOutflow

                                text: outflow
                                width: parent.width/2
                                height: parent.height
                            }*/

                        }
                    }

                    ListModel {
                        id: modelCategories
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
                }
            }
        }
    }
}
