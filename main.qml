import QtQuick 2.4
import QtQuick.Layouts 1.1
import Material.ListItems 0.1 as ListItem
import Material 0.1;
import Material.Extras 0.1;
import "models.js" as Models
import "utils.js" as Utils

ApplicationWindow {
    title: qsTr("Budget")

    width: 640
    height: 1136
    visible: true
    color: "lightcyan"
    property var definedMonthDays: {"Jan": 31, "Feb": 29, "Mar": 31, "Apr": 30, "May": 31, "Jun": 30, "Jul": 31, "Aug": 31, "Sep": 30, "Oct": 31, "Nov": 30, "Dec": 31};
    property var currencySymbols: ["€", "$", "R$"];
    property string currencySymbol: ""
    property var decimalSeparators: [".", ","];
    property string decimalSeparator: ""
    property int selectedGroupId: -1

    theme {
        primaryColor: Palette.colors["blue"]["500"]
        primaryDarkColor: Palette.colors["blue"]["700"]
        accentColor: Palette.colors["teal"]["500"]
        tabHighlightColor: "white"
    }

    ListModel {
        id: modelBudgetItems

        Component.onCompleted: {
            //Load from the database
            Models.init();
            //TOOD: Needs to filter by month/year
            var items = Models.BudgetItem.all();
            if (items.length === 0) {
                var categories = Models.Category.all()
                var date = new Date()
                for (var x = 0; x < categories.length; x++) {
                    Models.BudgetItem.create({budget:0, category: categories[x].id, month: date.getMonth()+1, year: date.getFullYear()})
                }
                items = Models.BudgetItem.all();
            }

            for (var y=0; y < items.length; y++) {
                var category = Models.Category.filter({id: items[y].category}).get()
                var group = Models.Group.filter({id: category.categoryGroup}).get();
                var budget = items[y].budget;
                if (!budget) {
                    budget = 0;
                }

                modelBudgetItems.append({id: items[y].id, budget: budget, category: category.name, group: group.name});
            }
        }
    }

    initialPage: TabbedPage {
        id: page
        title: "Budget App"
        tabs: Utils.findMonths()

        actions: [
            Action {
                iconName: "action/settings"
                name: "Settings"
                onTriggered: {
                    settings.show();
                }
            }
        ]

        Repeater {
            property var months: page.tabs
            model: page.tabs

            delegate: Tab {
                title: months[index]
                property string selectedComponent: modelData[2]

                ListView {
                    id: listViewBudgetItems
                    anchors.fill: parent
                    model: modelBudgetItems

                    headerPositioning: ListView.OverlayHeader
                    header: Component {
                        View {
                            id: viewCategory
                            backgroundColor: theme.tabHighlightColor;
                            elevation: 0
                            width: parent.width
                            height: 50

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
                                        checkinAccount.text = Utils.removeCurrencySymbol(checkinAccount.text);
                                    } else {
                                        checkinAccount.text = Utils.formatNumber(checkinAccount.text, currencySymbol, decimalSeparator);
                                    }
                                }
                            }

                            Label {
                                id: totalBalance
                                text: Utils.formatNumber("105.10", currencySymbol, decimalSeparator)
                                font.pixelSize: Units.dp(25)
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                            }
                        }
                    }

                    delegate: Component {
                        View {
                            id: viewCategory
                            width: listViewBudgetItems.width
                            height: 50

                            ListItem.Subtitled {
                                id: itemCategory
                                height: parent.height
                                width: parent.width / 2
                                text: category
                                valueText: Utils.formatNumber(Utils.calculateBudgetBalance(Models.BudgetItem.filter({id: id}).get(), page.tabs[page.selectedTab]), currencySymbol, decimalSeparator)
                                secondaryItem: TextField {
                                    id: budgetedField
                                    placeholderText: "Budgeted"
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: Utils.formatNumber(''+budget, currencySymbol, decimalSeparator)
                                    font.pixelSize: Units.dp(12)
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    horizontalAlignment: TextInput.AlignRight

                                    onActiveFocusChanged: {
                                        if (activeFocus) {
                                            budgetedField.text = Utils.removeCurrencySymbol(budgetedField.text);
                                        } else {
                                            var budgetItem = Models.BudgetItem.filter({id: id}).update({budget: Utils.removeCurrencySymbol(budgetedField.text)}).get();
                                            itemCategory.valueText = Utils.formatNumber(Utils.calculateBudgetBalance(budgetItem, page.tabs[page.selectedTab]), currencySymbol, decimalSeparator)
                                            budgetedField.text = Utils.formatNumber(budgetedField.text, currencySymbol, decimalSeparator);
                                        }
                                    }
                                }
                                subText: group

                                backgroundColor: theme.primaryColor;
                                tintColor: theme.tabHighlightColor

                                action: Icon {
                                    anchors.centerIn: parent
                                    name: "content/remove_circle"
                                    visible: true
                                    size: Units.dp(32)

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            Models.BudgetItem.filter({id: id}).remove();
                                            modelBudgetItems.remove(index)
                                        }
                                    }
                                }
                            }
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

            onClicked: addTransactionDialog.show()
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
                        transactionValue.text = Utils.formatNumber(transactionValue.text, currencySymbol, decimalSeparator);
                    }
                }


            }

            MenuField {
                id: menuAddTransaction
                textRole: "name"

                model: ListModel {
                    id: modelCategories

                    Component.onCompleted: {
                        var groups = Models.Group.all();
                        console.log("GROUPS: " + groups.length);
                        for (var x=0; x < groups.length; x++) {
                            var categories = Models.Category.filter({categoryGroup: groups[x].id}).all();
                            console.log("CATEGORIES: " + categories.length);
                            for (var y=0; y < categories.length; y++) {
                                var name = groups[x].name + '/' + categories[y].name;
                                console.log("name: " + name);
                                modelCategories.append({id: categories[y].id, name: name});
                            }
                        }
                    }
                }
            }

            onAccepted: {
                var d = new Date();
                Models.MoneyTransaction.create({value: transactionValue.text, category: menuAddTransaction.selectedItem.category, date: d.toISOString()});
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
                id: groupSelector
                textRole: "name"
                model: ListModel {
                    id: modelGroups

                    Component.onCompleted: {
                        var groups = Models.Group.all();
                        for (var x=0; x < groups.length; x++) {
                            modelGroups.append({name:groups[x].name, id: groups[x].id});
                        }
                    }
                }

            }

            onAccepted: {
                var category = Models.Category.create({name: categoryValue.text, categoryGroup: groupSelector.selectedItem.id});
                if (category) {
                    //Create new budget for that
                    var d = new Date();
                    var b = Models.BudgetItem.create({month: d.getMonth()+1, year: d.getFullYear(), category: category.id, budget: 0});
                    var cat = Models.Category.filter({id: b.category}).get();
                    var grp = Models.Group.filter({id: category.categoryGroup}).get();

                    modelBudgetItems.append({id: b.id, budget: b.budget, category: cat.name, group: grp.name});
                }
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

            onAccepted: {
                var group = Models.Group.create({name: groupValue.text});
                if (group) {
                    modelGroups.append(group);
                }
            }
        }

        Dialog {
            id: settings
            title: "Settings"
            height: parent.height / 3

            RowLayout {
                width: parent.width

                Label {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 0.4 * parent.width
                    text: "Currency"
                }

                MenuField {
                    id: selectedCurrency
                    model: currencySymbols
                    maxVisibleItems: 3
                    width: 0.3 * parent.width
                    Component.onCompleted: { currencySymbol = currencySymbols[0]; }

                    onSelectedIndexChanged: {
                        currencySymbol = currencySymbols[selectedIndex];
                    }
                }
            }

            RowLayout {
                width: parent.width

                Label {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 0.4 * parent.width
                    text: "Decimal Separator"
                }

                MenuField {
                    id: decimalSeparatorChoice
                    model: decimalSeparators
                    maxVisibleItems: 2
                    width: 0.3 * parent.width

                    Component.onCompleted: { decimalSeparator = decimalSeparators[0]; }

                    onSelectedIndexChanged: {
                        decimalSeparator = decimalSeparators[selectedIndex];
                    }

                }
            }

        }
    }
}
