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
    property var definedMonths: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    property var currencySymbols: ["€", "$", "R$"];
    property string currencySymbol: ""

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

    function findMonths() {
        var months = [];
        var d = new Date();
        var monthIndex = d.getMonth();
        var currentYear = d.getFullYear();

        months.push(currentYear + ' ' + definedMonths[monthIndex]);

        monthIndex--;

        if (monthIndex < 0) {
            monthIndex = 12 + monthIndex;
            currentYear--;
        }

        months.push(currentYear + ' ' + definedMonths[monthIndex]);

        monthIndex--;

        if (monthIndex < 0) {
            monthIndex = 12 + monthIndex;
            currentYear--;
        }

        months.push(currentYear + ' ' + definedMonths[monthIndex]);

        return months.reverse();
    }

    function removeCurrencySymbol(value) {
        return value.split(' ')[1];
    }

    function formatNumber(value) {
        var decimalSeparator = '.';
        var allowedAfterSeparator = 2;
        var afterSeparator = -1;
        var finalValue = '';
        var begin = true;

        value += ''; //Convert number to string

        for (var x=0; x < value.length; x++) {
            //End
            if (afterSeparator >= allowedAfterSeparator) {
                break;
            }
            //IsNumber
            else if (!isNaN(value[x])) {
                if (!begin || value[x] !== '0') {
                    finalValue += value[x];
                    begin = false;
                }
                if (afterSeparator >= 0) {
                    afterSeparator += 1;
                }
            }
            //IsSeparator
            else if (value[x] === decimalSeparator) {
                finalValue += decimalSeparator;
                afterSeparator += 1;
            }
        }

        if (finalValue.length === 0) {
            finalValue = '0';
        }

        if (afterSeparator >= -1) {
            finalValue += (decimalSeparator + '00').substring(afterSeparator + 1);
        }

        return currencySymbol + ' ' + finalValue;
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
        tabs: findMonths()

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
            model: findMonths()

            delegate: Item {
                width: monthsView.width
                height: monthsView.height
                clip: true

                property string selectedComponent: modelData[2]

                ListView {
                    id: listViewCategories
                    anchors.fill: parent
                    model: modelCategories

                    headerPositioning: ListView.OverlayHeader
                    header: Component {
                        View {
                            id: viewCategory
                            backgroundColor: theme.tabHighlightColor;
                            elevation: 0
                            width: parent.width
                            height: 50

                            MenuField {
                                id: selectedCurrency
                                model: ["Euro (€)", "US Dollar ($)", "Brazilian Real (R$)"];
                                maxVisibleItems: 3
                                width: 0.3 * parent.width

                                Component.onCompleted: { currencySymbol = currencySymbols[0]; }

                                onSelectedIndexChanged: {
                                    currencySymbol = currencySymbols[selectedIndex];
                                }
                            }

                            Button {
                                text: "New Category"
                                backgroundColor: theme.primaryDarkColor
                                onClicked: categoryDialog.show()
                                anchors.right: parent.right
                            }
                        }
                    }

                    footer: Component {
                        View {
                            id: viewFooter
                            backgroundColor: theme.tabHighlightColor;
                            elevation: 0
                            width: parent.width
                            height: 50

                            TextField {
                                id: checkinAccount
                                placeholderText: "Checkin Account"
                                font.pixelSize: Units.dp(18)
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                horizontalAlignment: TextInput.AlignRight

                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        checkinAccount.text = removeCurrencySymbol(checkinAccount.text);
                                    } else {
                                        checkinAccount.text = formatNumber(checkinAccount.text);
                                    }
                                }
                            }

                            Label {
                                id: totalBalance
                                text: formatNumber("105.10")
                                font.pixelSize: Units.dp(25)
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                            }
                        }
                    }

                    delegate: Component {
                        View {
                            id: viewCategory
                            //backgroundColor: theme.tabHighlightColor;
                            //elevation: 1
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
                                valueText: formatNumber(10-7.3)
                                secondaryItem: TextField {
                                    id: budgetedField
                                    //floatingLabel: true
                                    placeholderText: "Budgeted"
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: formatNumber(''+budgeted)
                                    font.pixelSize: Units.dp(12)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    horizontalAlignment: TextInput.AlignRight

                                    onActiveFocusChanged: {
                                        if (activeFocus) {
                                            budgetedField.text = removeCurrencySymbol(budgetedField.text);
                                        } else {
                                            budgetedField.text = formatNumber(budgetedField.text);
                                        }
                                    }
                                }
                                subText: group

                                backgroundColor: theme.primaryColor;
                                tintColor: theme.tabHighlightColor
                                //valueText: "Budgeted"
                            }
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

        Button {
            id: btAddTransaction
            text: qsTr("New Transaction")
            elevation: 1
            activeFocusOnPress: true
            backgroundColor: theme.primaryDarkColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            //onClicked: addTransactionDialog.show()
            onClicked: categoryDialog.show()
        }

        Dialog {
            id: addTransactionDialog
            title: "New Transaction"

            TextField {
                id: transactionValue
                placeholderText: "Value"
                text: '0.00'
                font.pixelSize: Units.dp(30)
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                horizontalAlignment: TextInput.AlignRight

                onActiveFocusChanged: {
                    if (!activeFocus) {
                        transactionValue.text = formatNumber(transactionValue.text);
                    }
                }


            }

            MenuField {
                model: ["Tiberio & Pablo", "Clothing", "Groceries"]
            }
        }

        Dialog {
            id: categoryDialog
            title: "New/Edit Category"

            TextField {
                id: categoryValue
                placeholderText: "Category"
                font.pixelSize: Units.dp(30)
            }
            MenuField {
                model: ["Tiberio & Pablo", "Clothing", "Groceries"]
            }

            Row {
                width: parent.width
                spacing: Units.dp(20)
                Button {
                    text: qsTr("New Group")
                    backgroundColor: theme.primaryDarkColor

                    onClicked: groupDialog.show()
                }

                ActionButton {
                    text: "Remove"
                    backgroundColor: Palette.colors["red"]["700"]
                    iconName: "content/remove_circle"
                }
            }
        }

        Dialog {
            id: groupDialog
            title: "New Group"

            TextField {
                id: groupValue
                placeholderText: "Group"
                font.pixelSize: Units.dp(30)
            }
        }
    }
}
