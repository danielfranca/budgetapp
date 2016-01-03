import QtQuick 2.0
import Material 0.1;
import Material.ListItems 0.1 as ListItem

Component {

    Dialog {
        id: diag

        property alias model: myListView.model
        width: parent.width * 0.8
        height: parent.height * 0.9

        ListView {
            id: myListView
            anchors.fill: parent
            model: 10

            delegate: Component {
                View {
                    width: parent.width
                    height: 30
                    ListItem.Subtitled {
                        text: "Subtitled list item"
                        valueText: "2h ago"
                    }
                    Component.onCompleted: {
                        console.log("LOADED ELEMENT")
                    }
                }
            }
        }
    }
}

