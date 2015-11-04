.import "quickmodel.js" as QuickModel

var qmdb;
var Group;
var Category;
var BudgetItem;
var Transaction;

function init() {
    qmdb = new QuickModel.QMDatabase("BudgetApp", "1.0");

    Group = qmdb.define("Group", {
                name: qmdb.String("Group Name", {accept_null: false})
    });

    Category = qmdb.define("Group", {
                        group: qmdb.FK("Group", {references: 'Group'}),
                        name: qmdb.String("Category Name", {accept_null: false})
    });

    BudgetItem = qmdb.define("BudgetItem", {
                        month: qmdb.Integer("Month", {accept_null: false}),
                        year: qmdb.Integer("Year", {accept_null: false}),
                        category: qmdb.FK("Category", {references: 'Category'}),
                        budget: qmdb.Float("Budget", {default: 0})
    });

    Transaction = qmdb.define("Transaction", {
                           date: qmdb.Date("Date", {accept_null: false}),
                           category: qmdb.FK("Category", {references: 'Category'}),
                           value: qmdb.Float("Budget", {default: 0})
    });
}

