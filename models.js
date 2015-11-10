.import "quickmodel.js" as QuickModel

var qmdb;
var Group;
var Category;
var BudgetItem;
var MoneyTransaction;

function init() {
    qmdb = new QuickModel.QMDatabase("BudgetApp3", "1.0");

    console.log("Models::init");

    Group = qmdb.define("CategoryGroup", {
                name: qmdb.String("Group Name", {accept_null: false})
    });

    Category = qmdb.define("Category", {
                        categoryGroup: qmdb.FK("Group", {references: 'CategoryGroup'}),
                        name: qmdb.String("Category Name", {accept_null: false})
    });

    BudgetItem = qmdb.define("BudgetItem", {
                        month: qmdb.Integer("Month", {accept_null: false}),
                        year: qmdb.Integer("Year", {accept_null: false}),
                        category: qmdb.FK("Category", {references: 'Category'}),
                        budget: qmdb.Float("Budget", {default: 0})
    });

    MoneyTransaction = qmdb.define("MoneyTransaction", {
                           date: qmdb.Date("Date", {accept_null: false}),
                           category: qmdb.FK("Category", {references: 'Category'}),
                           value: qmdb.Float("Budget", {default: 0})
    });
}

