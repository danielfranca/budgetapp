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
            Models.init();
        }
    }

    Component {
        id: delegatedBudgetItem

        View {
            id: viewCategory
            width: parent.width
            height: 50
            property alias budgetValue: itemCategory.valueText

            ListItem.Subtitled {
                id: itemCategory
                height: parent.height
                width: parent.width / 2
                text: category
                valueText: Utils.formatNumber(balance, currencySymbol, decimalSeparator)
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
                            Models.BudgetItem.filter({id: id}).update({budget: Utils.removeCurrencySymbol(budgetedField.text)});
                            var budgetItem = Models.BudgetItem.filter({id: id}).get()
                            itemCategory.valueText = Utils.formatNumber(balance, currencySymbol, decimalSeparator)
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

    initialPage: TabbedPage {
        id: page
        title: "Budget App"
        tabs: Utils.findMonths()
        selectedTab: 1

        function loadModelBudgetItems(month, year, modelBudgetItems) {
            modelBudgetItems.clear()

            //Load from the database
            //TOOD: Needs to filter by month/year
            var items = Models.BudgetItem.filter({month: month, year: year}).all();
            if (items.length === 0) {
                var categories = Models.Category.all()
                for (var x = 0; x < categories.length; x++) {
                    Models.BudgetItem.create({budget:0, category: categories[x].id, month: month, year: year})
                }
                items = Models.BudgetItem.filter({month: month, year: year}).all();
            }

            for (var y=0; y < items.length; y++) {
                var category = Models.Category.filter({id: items[y].category}).get()
                var group = Models.Group.filter({id: category.categoryGroup}).get();
                var budget = items[y].budget;
                if (!budget) {
                    budget = 0;
                }

                var baseDate = new Date(year, month, 1);
                var transactions = Utils.retrieveTransactions(baseDate, category.id)
                console.log("*** NUMBER OF TRANSACTIONS: " + transactions.length)
                var sum = Utils.sumTransactions(transactions)
                modelBudgetItems.append({id: items[y].id, budget: budget, category: category.name, group: group.name, transactions: transactions, balance: sum-budget});
            }
        }

        Component.onCompleted: {
            var arr = Utils.convertTitleToMonthYear(page.tabs[page.selectedTab])
            var month = arr[0]
            var year = arr[1]

            loadModelBudgetItems(month, year, modelBudgetItems)

        }

        onSelectedTabChanged: {
            console.log("Tab changed: currentMonth: " + page.cur)

            var arr = Utils.convertTitleToMonthYear(page.tabs[page.selectedTab])
            var month = arr[0]
            var year = arr[1]

            loadModelBudgetItems(month, year, modelBudgetItems)
        }

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
                property string selectedComponent: modelData[1]

                ListView {
                    id: listViewBudgetItems
                    anchors.fill: parent
                    model: modelBudgetItems

                    headerPositioning: ListView.OverlayHeader
                    header: Component {
                        View {
                            id: headerCategory
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
                    delegate: delegatedBudgetItem
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
                if (!menuAddTransaction.selectedComponent)
                    return;
                var categoryId = menuAddTransaction.selectedComponent.id;
                var transaction = Models.MoneyTransaction.create({value: Utils.removeCurrencySymbol(transactionValue.text), category: categoryId, date: d.toISOString()});
                for (var x=0; x < modelBudgetItems.count; x++) {
                    var item = modelBudgetItems.get(x)
                    var bItem = Models.BudgetItem.filter({id: item.id}).get()
                    if (bItem.category === categoryId) {
                        item.budget = Utils.calculateBudgetBalance(bItem, page.tabs[page.selectedTab])
                        var dtArr = Utils.convertTitleToMonthYear(page.tabs[page.selectedTab])
                        //var d = new Date(dtArr[1], dtArr[0], 1)
                        var transactions = Utils.retrieveTransactions(d, categoryId)
                        var sum = Utils.sumTransactions(transactions)
                        item.balance = item.budget - sum
                        break;
                    }
                }
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
                var category = Models.Category.create({name: categoryValue.text, categoryGroup: groupSelector.selectedComponent.id});
                if (category) {
                    //Create new budget for that
                    var d = new Date();
                    var b = Models.BudgetItem.create({month: d.getMonth()+1, year: d.getFullYear(), category: category.id, budget: 0});
                    var cat = Models.Category.filter({id: b.category}).get();
                    var grp = Models.Group.filter({id: category.categoryGroup}).get();

                    var transactions = Utils.retrieveTransactions(d, category.id)
                    var sum = Utils.sumTransactions(transactions)
                    modelBudgetItems.append({id: b.id, budget: b.budget, category: cat.name, group: grp.name, transactions: transactions, balance: b.budget-sum});
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
