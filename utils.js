var definedMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
var definedMonthDays = {"Jan": 31, "Feb": 29, "Mar": 31, "Apr": 30, "May": 31, "Jun": 30, "Jul": 31, "Aug": 31, "Sep": 30, "Oct": 31, "Nov": 30, "Dec": 31};

//Database: ~/Library/Application Support/BudgetApp/QML/OfflineStorage/Databases

function convertTitleToMonthYear(title) {
    var splittedDate = title.split('/');
    var monthName = splittedDate[0];
    var month = definedMonths.indexOf(monthName) + 1;
    var year = parseInt(splittedDate[1]);

    return [month-1, year];
}

function getStartAndEndDate(date) {

    var month = date.getMonth()+1;
    var year = date.getFullYear();

    var monthName = definedMonths[month-1];
    var endDay = definedMonthDays[monthName];

    if (month < 10) {
        month = '0' + month;
    }
    if (endDay < 10) {
        endDay = '0' + endDay;
    }

    var startDate = year + '-' + month + '-01';
    var endDate = year + '-' + month + '-' + endDay;

    return [startDate, endDate];
}

function retrieveTransactions(date, category) {
    var limitDates = getStartAndEndDate(date);
    var startDate = limitDates[0];
    var endDate = limitDates[1];
    return Models.MoneyTransaction.filter({category: category, date__ge: startDate, date__le: endDate}).all();
}

function sumTransactions(transactions) {
    var sum = 0;
    for (var x=0; x<transactions.length; x++) {
        sum += convertToNumber(transactions[x].value);
    }
    return sum;
}

function calculateBudgetBalance(budgetItem, title) {

    //TODO: Change it to a SUM aggregation function call
    var dates = convertTitleToMonthYear(title)
    var date = new Date(dates[1], dates[0], 1)
    var transactions = retrieveTransactions(date, budgetItem.category)
    var totalSpent = sumTransactions(transactions);
    console.log("TOTAL SPENT: " + totalSpent)

    var balance = budgetItem.budget - totalSpent;

    console.log("BALANCE: " + balance)

    return balance;
}

function convertToNumber(value) {
    if (typeof value === "number") return value;

    return parseInt(removeCurrencySymbol(value.replace(',','.')));
}

function createMonthTitle(monthIndex, currentYear) {
    return definedMonths[monthIndex] + '/' + currentYear;
}

function findMonths(date, indexes) {
    var months = [];

    if (!date) {
        date = new Date();
    }

    if (typeof indexes === 'undefined') {
        indexes = [-1, 0, 1];
    }

    var monthIndex = date.getMonth();
    var currentYear = date.getFullYear();

    for (var x=0; x<indexes.length; x++) {
        var idxMonth = monthIndex + indexes[x];
        var titleYear = currentYear;

        if (idxMonth > 11) {
            while (idxMonth > 0) {
                idxMonth -= 12;
                titleYear++;
            }
        } else if (idxMonth < 0) {
            while (idxMonth < 11) {
                idxMonth += 12
                titleYear--;
            }
        }

        months.push(createMonthTitle(idxMonth, titleYear));
    }

    return months;//.reverse();
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
        //Is minus
        else if (value[x] === '-') {
            finalValue += '-'
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

