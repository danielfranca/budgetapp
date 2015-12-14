var definedMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function calculateBudgetBalance(budgetItem, date) {

    var splittedDate = date.split('/');
    var monthName = splittedDate[0];
    var month = definedMonths.indexOf(monthName) + 1;
    var year = splittedDate[1];

    console.log("MONTH: " + month);
    console.log("YEAR: " + year);

    var endDay = definedMonthDays[monthName];
    var startDate = '01/' + month + '/' + year;
    var endDate = endDay + '/' + month + '/' + year;

    //TODO: Change it to a SUM aggregation function call
    var transactions = Models.MoneyTransaction.filter({category: budgetItem.category, date__ge: startDate, date__le: endDate}).all();
    var totalSpent = 0;
    for (var x=0; x<transactions.length; x++) {
        totalSpent += transactions[x].value;
    }
    var balance = budgetItem.budget - totalSpent;

    console.log("BALANCE: " + balance)

    return balance;
}

function createMonthTitle(monthIndex, currentYear) {
    return definedMonths[monthIndex] + '/' + currentYear;
}

function findMonths(date) {
    var months = [];

    if (!date) {
        date = new Date();
    }

    var monthIndex = date.getMonth();
    var currentYear = date.getFullYear();

    months.push(createMonthTitle(monthIndex, currentYear));

    monthIndex--;

    if (monthIndex < 0) {
        monthIndex = 12 + monthIndex;
        currentYear--;
    }

    months.push(createMonthTitle(monthIndex, currentYear));

    monthIndex--;

    if (monthIndex < 0) {
        monthIndex = 12 + monthIndex;
        currentYear--;
    }

    months.push(createMonthTitle(monthIndex, currentYear));

    return months.reverse();
}

function removeCurrencySymbol(value) {
    if (value.indexOf(' ') === -1) {
        return value;
    }
    var sp = value.split(' ');
    return sp[sp.length-1].trim();
}

function formatNumber(value, currencySymbol, decimalSeparator) {
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
            if (finalValue.length === 0) {
                finalValue = '0';
            }

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

