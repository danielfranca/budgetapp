import QtQuick 2.0
import QtTest 1.0
import "utils.js" as Utils

TestCase {
    name: "testBudgetFunctions"

    function test_remove_currency() {
        var value = '10';
        compare(Utils.removeCurrencySymbol(value), '10')

        value = '€ 152.00';
        compare(Utils.removeCurrencySymbol(value), '152.00')

        value = '€   152.00';
        compare(Utils.removeCurrencySymbol(value), '152.00')

        value = 'R$ 99,25';
        compare(Utils.removeCurrencySymbol(value), '99,25')

        value = '$ 50.777';
        compare(Utils.removeCurrencySymbol(value), '50.777')

        value = '';
        compare(Utils.removeCurrencySymbol(value), '')
    }

    function test_format_number() {
        var value = '50.288744'
        compare(Utils.formatNumber(value, 'R$', '.'), 'R$ 50.28')

        value = '60,0'
        compare(Utils.formatNumber(value, 'R$', ','), 'R$ 60,00')

        value = '233'
        compare(Utils.formatNumber(value, '$', '.'), '$ 233.00')

        value = '.155578';
        compare(Utils.formatNumber(value, '€', '.'), '€ 0.15')

        value = '152.05fff';
        compare(Utils.formatNumber(value, '€', '.'), '€ 152.05')
    }

    function test_month_title() {
        compare(Utils.createMonthTitle(0, 2016), 'Jan/2016')
        compare(Utils.createMonthTitle(11, 2015), 'Dec/2015')
        compare(Utils.createMonthTitle(2, 1983), 'Mar/1983')
        compare(Utils.createMonthTitle(6, 2010), 'Jul/2010')
        compare(Utils.createMonthTitle(10, 1998), 'Nov/1998')

        compare(Utils.convertTitleToMonthYear('Jan/2016'), [0, 2016])
        compare(Utils.convertTitleToMonthYear('Jun/2010'), [5, 2010])
        compare(Utils.convertTitleToMonthYear('Mar/1995'), [2, 1995])
        compare(Utils.convertTitleToMonthYear('Feb/2020'), [1, 2020])
    }

    function test_find_months() {
        var now = new Date();
        compare(Utils.findMonths(new Date(2015, 11, 01)), ['Nov/2015', 'Dec/2015', 'Jan/2016'])
        compare(Utils.findMonths(new Date(2010, 05, 08)), ['May/2010', 'Jun/2010', 'Jul/2010'])
        compare(Utils.findMonths(new Date(1983, 02, 07)), ['Feb/1983', 'Mar/1983', 'Apr/1983'])
    }

    function test_get_days() {
        var dt1 = new Date(2015, 9, 8)
        var dt2 = new Date(2010, 5, 25)
        var dt3 = new Date(1985, 11, 01)
        var dt4 = new Date(2017, 1, 18)
        var dt5 = new Date(1990, 0, 31)
        var dt6 = new Date(2014, 10, 10)

        var days = Utils.getStartAndEndDate(dt1)
        compare(days[0], '2015-10-01')
        compare(days[1], '2015-10-31')

        days = Utils.getStartAndEndDate(dt2)
        compare(days[0], '2010-06-01')
        compare(days[1], '2010-06-30')

        days = Utils.getStartAndEndDate(dt3)
        compare(days[0], '1985-12-01')
        compare(days[1], '1985-12-31')

        days = Utils.getStartAndEndDate(dt4)
        compare(days[0], '2017-02-01')
        compare(days[1], '2017-02-29')

        days = Utils.getStartAndEndDate(dt5)
        compare(days[0], '1990-01-01')
        compare(days[1], '1990-01-31')

        days = Utils.getStartAndEndDate(dt6)
        compare(days[0], '2014-11-01')
        compare(days[1], '2014-11-30')
    }

    function test_format_date() {
        var dt = new Date(2016, 9, 8)
        compare(Utils.formatDate(dt), '2016-10-07')

        dt = new Date(2016, 1, 29)
        compare(Utils.formatDate(dt), '2016-02-28')

        dt = new Date(1983, 2, 8)
        compare(Utils.formatDate(dt), '1983-03-07')
    }
}

