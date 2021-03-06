import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:projectbusywork/myColors.dart';
import 'package:projectbusywork/tasks.dart';
import 'package:table_calendar/table_calendar.dart';

class ProgressWidget extends StatefulWidget {
  final Color color;

  @override
  State<StatefulWidget> createState() {
    return ProgressWidgetState();
  }

  ProgressWidget(this.color);
}

class ProgressWidgetState extends State<ProgressWidget> {
  File jsonFile;
  Directory dir;
  String fileName = "tasks.json";
  List<dynamic> fileContent;
  List<Task> allTasks = List<Task>();
  List<charts.Series<Info, String>> seriesData =
      List<charts.Series<Info, String>>();
  List<charts.Series<Info, String>> seriesDataMonthly =
      List<charts.Series<Info, String>>();
  String weekText = "";
  String monthText = "";

  void initState() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      this.setState(
          () => fileContent = json.decode(jsonFile.readAsStringSync()));

      getTasks().then((value) {
        setState(() {
          allTasks.addAll(value);
          print(allTasks);
          seriesData = List<charts.Series<Info, String>>();
          seriesDataMonthly = List<charts.Series<Info, String>>();
          generateData();
          generateDataMonthly();
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'Expected vs. Actual',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Container(height: 20),
              Text(
                'Weekly Report',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                height: 180.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: charts.BarChart(
                  seriesData,
                  animate: true,
                  barGroupingType: charts.BarGroupingType.grouped,
                  behaviors: [
                    new charts.SeriesLegend(
                        entryTextStyle: charts.TextStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Colors.black87),
                    ))
                  ],
                  animationDuration: Duration(seconds: 1),
                ),
              ),
              Container(height: 10),
              Text(weekText),
              Container(height: 20),
              Text(
                'Monthly Report',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                height: 180.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: charts.BarChart(
                  seriesDataMonthly,
                  animate: true,
                  barGroupingType: charts.BarGroupingType.grouped,
                  behaviors: [
                    new charts.SeriesLegend(
                        entryTextStyle: charts.TextStyleSpec(
                      color: charts.ColorUtil.fromDartColor(Colors.black87),
                    ))
                  ],
                  animationDuration: Duration(seconds: 1),
                ),
              ),
              Container(height: 10),
              Text(monthText),
            ],
          ),
        ),
      ),
      backgroundColor: widget.color,
    );
  }

  Future<List<Task>> getTasks() async {
    var addTasks = List<Task>();
    var tasksJson = json.decode(jsonFile.readAsStringSync());
    for (var taskJson in tasksJson) {
      addTasks.add(Task.fromJson(taskJson));
    }
    return addTasks;
  }

  void generateData() {
    int expSunday = 0;
    int actSunday = 0;
    int expMonday = 0;
    int actMonday = 0;
    int expTuesday = 0;
    int actTuesday = 0;
    int expWednesday = 0;
    int actWednesday = 0;
    int expThursday = 0;
    int actThursday = 0;
    int expFriday = 0;
    int actFriday = 0;
    int expSaturday = 0;
    int actSaturday = 0;
    int totalExpMinutes = 0;
    int totalActMinutes = 0;
    for (var task in allTasks) {
      if (task.completed == "true") {
        String checker = task.date;
        List<String> dateSplitter = task.date.split(" ");
        String dateMonth = dateSplitter[0];
        String dateDay =
            dateSplitter[1].substring(0, dateSplitter[1].length - 2);
        String dateYear = dateSplitter[2];
        String realWeekDay = task.weekDay;
        if (weekChecker(task.date)) {
          List<String> hm = task.expected.split(":");
          int hour = int.parse(hm[0]);
          int minute = int.parse(hm[1]);
          int expectedMinutes = minute;
          for (int i = 0; i < hour; i++) expectedMinutes = expectedMinutes + 60;

          List<String> hm2 = task.actualStart.split(":");
          int hour2 = int.parse(hm2[0]);
          int minute2 = int.parse(hm2[1]);
          int actualMinutes = minute2;
          for (int i = 0; i < hour2; i++) actualMinutes = actualMinutes + 60;

          if (realWeekDay == "Sunday") {
            expSunday = expSunday + expectedMinutes;
            actSunday = actSunday + actualMinutes;
          }

          if (realWeekDay == "Monday") {
            expMonday = expMonday + expectedMinutes;
            actMonday = actMonday + actualMinutes;
          }

          if (realWeekDay == "Tuesday") {
            expTuesday = expTuesday + expectedMinutes;
            actTuesday = actTuesday + actualMinutes;
          }

          if (realWeekDay == "Wednesday") {
            expWednesday = expWednesday + expectedMinutes;
            actWednesday = actWednesday + actualMinutes;
          }

          if (realWeekDay == "Thursday") {
            expThursday = expThursday + expectedMinutes;
            actThursday = actThursday + actualMinutes;
          }

          if (realWeekDay == "Friday") {
            expFriday = expFriday + expectedMinutes;
            actFriday = actFriday + actualMinutes;
          }

          if (realWeekDay == "Saturday") {
            expFriday = expSaturday + expectedMinutes;
            actSaturday = actSaturday + actualMinutes;
          }
          totalExpMinutes = totalExpMinutes + expectedMinutes;
          totalActMinutes = totalActMinutes + actualMinutes;
        }
      }
    }
    var expData = [
      new Info(
          "Sun", "expected", expSunday, charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "Mon", "expected", expMonday, charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Tues", "expected", expTuesday,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Wed", "expected", expWednesday,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Thurs", "expected", expThursday,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "Fri", "expected", expFriday, charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Sat", "expected", expSaturday,
          charts.ColorUtil.fromDartColor(lGreen)),
    ];

    var actData = [
      new Info("Sun", "actual", actSunday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Mon", "actual", actMonday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Mon", "actual", actMonday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Tues", "actual", actTuesday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Wed", "actual", actWednesday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Thurs", "actual", actThursday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Fri", "actual", actFriday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Sat", "actual", actSaturday,
          charts.ColorUtil.fromDartColor(Colors.grey)),
    ];

    seriesData.add(
      charts.Series(
        domainFn: (Info info, _) => info.title,
        measureFn: (Info info, _) => info.time,
        colorFn: (Info info, _) => info.color,
        id: "Expected",
        data: expData,
        displayName: "Expected",
      ),
    );

    seriesData.add(
      charts.Series(
        domainFn: (Info info, _) => info.title,
        measureFn: (Info info, _) => info.time,
        colorFn: (Info info, _) => info.color,
        id: "Actual",
        data: actData,
        displayName: "Actual",
      ),
    );

    int minuteChecker = totalExpMinutes - totalActMinutes;

    if (minuteChecker == 0) weekText = "You are exactly on track!";
    if (minuteChecker > 0)
      weekText = "You've spent " +
          minuteChecker.toString() +
          " less minutes than expected this week!";
    if (minuteChecker < 0) {
      minuteChecker = minuteChecker * -1;
      weekText = "You've spent " +
          minuteChecker.toString() +
          " more  minutes than expected this week!";
    }
  }

  void generateDataMonthly() {
    int expJanuary = 0;
    int actJanuary = 0;
    int expFebruary = 0;
    int actFebruary = 0;
    int expMarch = 0;
    int actMarch = 0;
    int expApril = 0;
    int actApril = 0;
    int expMay = 0;
    int actMay = 0;
    int expJune = 0;
    int actJune = 0;
    int expJuly = 0;
    int actJuly = 0;
    int expAugust = 0;
    int actAugust = 0;
    int expSeptember = 0;
    int actSeptember = 0;
    int expOctober = 0;
    int actOctober = 0;
    int expNovember = 0;
    int actNovember = 0;
    int expDecember = 0;
    int actDecember = 0;
    int totalExpMinutes = 0;
    int totalActMinutes = 0;

    for (var task in allTasks) {
      if (task.completed == "true") {
        String checker = task.date;
        List<String> dateSplitter = task.date.split(" ");
        String dateMonth = dateSplitter[0];
        String dateDay =
            dateSplitter[1].substring(0, dateSplitter[1].length - 2);
        String dateYear = dateSplitter[2];
        String realWeekDay = task.weekDay;
        if (dateYear == DateTime.now().year.toString()) {
          List<String> hm = task.expected.split(":");
          int hour = int.parse(hm[0]);
          int minute = int.parse(hm[1]);
          int expectedMinutes = minute;
          for (int i = 0; i < hour; i++) expectedMinutes = expectedMinutes + 60;

          List<String> hm2 = task.actualStart.split(":");
          int hour2 = int.parse(hm2[0]);
          int minute2 = int.parse(hm2[1]);
          int actualMinutes = minute2;
          for (int i = 0; i < hour2; i++) actualMinutes = actualMinutes + 60;

          if (dateMonth == "Jan") {
            expJanuary = expJanuary + expectedMinutes;
            actJanuary = actJanuary + actualMinutes;
          }

          if (dateMonth == "Feb") {
            expFebruary = expFebruary + expectedMinutes;
            actFebruary = actFebruary + actualMinutes;
          }

          if (dateMonth == "Mar") {
            expMarch = expMarch + expectedMinutes;
            actMarch = actMarch + actualMinutes;
          }

          if (dateMonth == "Apr") {
            expApril = expApril + expectedMinutes;
            actApril = actApril + actualMinutes;
          }

          if (dateMonth == "May") {
            expMay = expMay + expectedMinutes;
            actMay = actMay + actualMinutes;
          }

          if (dateMonth == "Jun") {
            expJune = expJune + expectedMinutes;
            actJune = actJune + actualMinutes;
          }

          if (dateMonth == "Jul") {
            expJuly = expJuly + expectedMinutes;
            actJuly = actJuly + actualMinutes;
          }

          if (dateMonth == "Aug") {
            expAugust = expAugust + expectedMinutes;
            actAugust = actAugust + actualMinutes;
          }

          if (dateMonth == "Sep") {
            expSeptember = expSeptember + expectedMinutes;
            actSeptember = actSeptember + actualMinutes;
          }

          if (dateMonth == "Oct") {
            expOctober = expOctober + expectedMinutes;
            actOctober = actOctober + actualMinutes;
          }

          if (dateMonth == "Nov") {
            expNovember = expNovember + expectedMinutes;
            actNovember = actNovember + actualMinutes;
          }

          if (dateMonth == "Dec") {
            expDecember = expDecember + expectedMinutes;
            actDecember = actDecember + actualMinutes;
          }

          if (monthChecker(dateMonth)) {
            totalExpMinutes = totalExpMinutes + expectedMinutes;
            totalActMinutes = totalActMinutes + actualMinutes;
          }
        }
      }
    }
    var expData = [
      new Info("Jan", "expected", expJanuary,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Feb", "expected", expFebruary,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "Mar", "expected", expMarch, charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "Apr", "expected", expApril, charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "May", "expected", expMay, charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "Jun", "expected", expJune, charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "Jul", "expected", expJuly, charts.ColorUtil.fromDartColor(lGreen)),
      new Info(
          "Aug", "expected", expAugust, charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Sep", "expected", expSeptember,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Oct", "expected", expOctober,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Nov", "expected", expNovember,
          charts.ColorUtil.fromDartColor(lGreen)),
      new Info("Dec", "expected", expDecember,
          charts.ColorUtil.fromDartColor(lGreen)),
    ];

    var actData = [
      new Info("Jan", "actual", actJanuary,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Feb", "actual", actFebruary,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Mar", "actual", actMarch,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Apr", "actual", actApril,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info(
          "May", "actual", actMay, charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Jun", "actual", actJune,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Jul", "actual", actJuly,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Aug", "actual", actAugust,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Sep", "actual", actSeptember,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Oct", "actual", actOctober,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Nov", "actual", actNovember,
          charts.ColorUtil.fromDartColor(Colors.grey)),
      new Info("Dec", "actual", actDecember,
          charts.ColorUtil.fromDartColor(Colors.grey)),
    ];

    seriesDataMonthly.add(
      charts.Series(
        domainFn: (Info info, _) => info.title,
        measureFn: (Info info, _) => info.time,
        colorFn: (Info info, _) => info.color,
        id: "Expected",
        data: expData,
        displayName: "Expected",
      ),
    );

    seriesDataMonthly.add(
      charts.Series(
        domainFn: (Info info, _) => info.title,
        measureFn: (Info info, _) => info.time,
        colorFn: (Info info, _) => info.color,
        id: "Actual",
        data: actData,
        displayName: "Actual",
      ),
    );

    int minuteChecker = totalExpMinutes - totalActMinutes;

    if (minuteChecker == 0) monthText = "You are exactly on track!";
    if (minuteChecker > 0)
      monthText = "You've spent " +
          minuteChecker.toString() +
          " less minutes than expected this month!";
    if (minuteChecker < 0) {
      minuteChecker = minuteChecker * -1;
      monthText = "You've spent " +
          minuteChecker.toString() +
          " more minutes than expected this month!";
    }
  }

  bool monthChecker(String dateMonth) {
    int num = 0;
    if (dateMonth == "Jan") num = 1;
    if (dateMonth == "Feb") num = 2;
    if (dateMonth == "Mar") num = 3;
    if (dateMonth == "Apr") num = 4;
    if (dateMonth == "May") num = 5;
    if (dateMonth == "Jun") num = 6;
    if (dateMonth == "Jul") num = 7;
    if (dateMonth == "Aug") num = 8;
    if (dateMonth == "Sep") num = 9;
    if (dateMonth == "Aug") num = 10;
    if (dateMonth == "Nov") num = 11;
    if (dateMonth == "Dec") num = 12;

    if (DateTime.now().month == num) return true;
    return false;
  }

  bool weekChecker(String taskDate) {
    var today = DateTime.now();
    List<String> acceptable = List<String>();
    if (today.weekday == 7) {
      //Sunday
      DateTime day1 = new DateTime(today.year, today.month, today.day);
      String day1Month = monthConvert(day1.month);
      acceptable.add(
          day1Month + " " + day1.day.toString() + ", " + day1.year.toString());
      DateTime day2 = new DateTime(today.year, today.month, today.day + 1);
      String day2Month = monthConvert(day2.month);
      acceptable.add(
          day2Month + " " + day2.day.toString() + ", " + day2.year.toString());
      DateTime day3 = new DateTime(today.year, today.month, today.day + 2);
      String day3Month = monthConvert(day3.month);
      acceptable.add(
          day3Month + " " + day3.day.toString() + ", " + day3.year.toString());
      DateTime day4 = new DateTime(today.year, today.month, today.day + 3);
      String day4Month = monthConvert(day4.month);
      acceptable.add(
          day4Month + " " + day4.day.toString() + ", " + day4.year.toString());
      DateTime day5 = new DateTime(today.year, today.month, today.day + 4);
      String day5Month = monthConvert(day5.month);
      acceptable.add(
          day5Month + " " + day5.day.toString() + ", " + day5.year.toString());
      DateTime day6 = new DateTime(today.year, today.month, today.day + 5);
      String day6Month = monthConvert(day6.month);
      acceptable.add(
          day6Month + " " + day6.day.toString() + ", " + day6.year.toString());
      DateTime day7 = new DateTime(today.year, today.month, today.day + 6);
      String day7Month = monthConvert(day7.month);
      acceptable.add(
          day7Month + " " + day7.day.toString() + ", " + day7.year.toString());
    }

    if (today.weekday == 1) {
      //Monday
      DateTime day1 = new DateTime(today.year, today.month, today.day);
      String day1Month = monthConvert(day1.month);
      acceptable.add(
          day1Month + " " + day1.day.toString() + ", " + day1.year.toString());
      DateTime day2 = new DateTime(today.year, today.month, today.day + 1);
      String day2Month = monthConvert(day2.month);
      acceptable.add(
          day2Month + " " + day2.day.toString() + ", " + day2.year.toString());
      DateTime day3 = new DateTime(today.year, today.month, today.day + 2);
      String day3Month = monthConvert(day3.month);
      acceptable.add(
          day3Month + " " + day3.day.toString() + ", " + day3.year.toString());
      DateTime day4 = new DateTime(today.year, today.month, today.day + 3);
      String day4Month = monthConvert(day4.month);
      acceptable.add(
          day4Month + " " + day4.day.toString() + ", " + day4.year.toString());
      DateTime day5 = new DateTime(today.year, today.month, today.day + 4);
      String day5Month = monthConvert(day5.month);
      acceptable.add(
          day5Month + " " + day5.day.toString() + ", " + day5.year.toString());
      DateTime day6 = new DateTime(today.year, today.month, today.day + 5);
      String day6Month = monthConvert(day6.month);
      acceptable.add(
          day6Month + " " + day6.day.toString() + ", " + day6.year.toString());
      DateTime day7 = new DateTime(today.year, today.month, today.day - 1);
      String day7Month = monthConvert(day7.month);
      acceptable.add(
          day7Month + " " + day7.day.toString() + ", " + day7.year.toString());
    }

    if (today.weekday == 2) {
      //Tuesday
      DateTime day1 = new DateTime(today.year, today.month, today.day);
      String day1Month = monthConvert(day1.month);
      acceptable.add(
          day1Month + " " + day1.day.toString() + ", " + day1.year.toString());
      DateTime day2 = new DateTime(today.year, today.month, today.day + 1);
      String day2Month = monthConvert(day2.month);
      acceptable.add(
          day2Month + " " + day2.day.toString() + ", " + day2.year.toString());
      DateTime day3 = new DateTime(today.year, today.month, today.day + 2);
      String day3Month = monthConvert(day3.month);
      acceptable.add(
          day3Month + " " + day3.day.toString() + ", " + day3.year.toString());
      DateTime day4 = new DateTime(today.year, today.month, today.day + 3);
      String day4Month = monthConvert(day4.month);
      acceptable.add(
          day4Month + " " + day4.day.toString() + ", " + day4.year.toString());
      DateTime day5 = new DateTime(today.year, today.month, today.day + 4);
      String day5Month = monthConvert(day5.month);
      acceptable.add(
          day5Month + " " + day5.day.toString() + ", " + day5.year.toString());
      DateTime day6 = new DateTime(today.year, today.month, today.day - 2);
      String day6Month = monthConvert(day6.month);
      acceptable.add(
          day6Month + " " + day6.day.toString() + ", " + day6.year.toString());
      DateTime day7 = new DateTime(today.year, today.month, today.day - 1);
      String day7Month = monthConvert(day7.month);
      acceptable.add(
          day7Month + " " + day7.day.toString() + ", " + day7.year.toString());
    }

    if (today.weekday == 3) {
      //Wednesday
      DateTime day1 = new DateTime(today.year, today.month, today.day);
      String day1Month = monthConvert(day1.month);
      acceptable.add(
          day1Month + " " + day1.day.toString() + ", " + day1.year.toString());
      DateTime day2 = new DateTime(today.year, today.month, today.day + 1);
      String day2Month = monthConvert(day2.month);
      acceptable.add(
          day2Month + " " + day2.day.toString() + ", " + day2.year.toString());
      DateTime day3 = new DateTime(today.year, today.month, today.day + 2);
      String day3Month = monthConvert(day3.month);
      acceptable.add(
          day3Month + " " + day3.day.toString() + ", " + day3.year.toString());
      DateTime day4 = new DateTime(today.year, today.month, today.day + 3);
      String day4Month = monthConvert(day4.month);
      acceptable.add(
          day4Month + " " + day4.day.toString() + ", " + day4.year.toString());
      DateTime day5 = new DateTime(today.year, today.month, today.day - 3);
      String day5Month = monthConvert(day5.month);
      acceptable.add(
          day5Month + " " + day5.day.toString() + ", " + day5.year.toString());
      DateTime day6 = new DateTime(today.year, today.month, today.day - 2);
      String day6Month = monthConvert(day6.month);
      acceptable.add(
          day6Month + " " + day6.day.toString() + ", " + day6.year.toString());
      DateTime day7 = new DateTime(today.year, today.month, today.day - 1);
      String day7Month = monthConvert(day7.month);
      acceptable.add(
          day7Month + " " + day7.day.toString() + ", " + day7.year.toString());
    }

    if (today.weekday == 4) {
      //Thursday
      DateTime day1 = new DateTime(today.year, today.month, today.day);
      String day1Month = monthConvert(day1.month);
      acceptable.add(
          day1Month + " " + day1.day.toString() + ", " + day1.year.toString());
      DateTime day2 = new DateTime(today.year, today.month, today.day + 1);
      String day2Month = monthConvert(day2.month);
      acceptable.add(
          day2Month + " " + day2.day.toString() + ", " + day2.year.toString());
      DateTime day3 = new DateTime(today.year, today.month, today.day + 2);
      String day3Month = monthConvert(day3.month);
      acceptable.add(
          day3Month + " " + day3.day.toString() + ", " + day3.year.toString());
      DateTime day4 = new DateTime(today.year, today.month, today.day - 4);
      String day4Month = monthConvert(day4.month);
      acceptable.add(
          day4Month + " " + day4.day.toString() + ", " + day4.year.toString());
      DateTime day5 = new DateTime(today.year, today.month, today.day - 3);
      String day5Month = monthConvert(day5.month);
      acceptable.add(
          day5Month + " " + day5.day.toString() + ", " + day5.year.toString());
      DateTime day6 = new DateTime(today.year, today.month, today.day - 2);
      String day6Month = monthConvert(day6.month);
      acceptable.add(
          day6Month + " " + day6.day.toString() + ", " + day6.year.toString());
      DateTime day7 = new DateTime(today.year, today.month, today.day - 1);
      String day7Month = monthConvert(day7.month);
      acceptable.add(
          day7Month + " " + day7.day.toString() + ", " + day7.year.toString());
    }

    if (today.weekday == 5) {
      //Friday
      DateTime day1 = new DateTime(today.year, today.month, today.day);
      String day1Month = monthConvert(day1.month);
      acceptable.add(
          day1Month + " " + day1.day.toString() + ", " + day1.year.toString());
      DateTime day2 = new DateTime(today.year, today.month, today.day + 1);
      String day2Month = monthConvert(day2.month);
      acceptable.add(
          day2Month + " " + day2.day.toString() + ", " + day2.year.toString());
      DateTime day3 = new DateTime(today.year, today.month, today.day - 5);
      String day3Month = monthConvert(day3.month);
      acceptable.add(
          day3Month + " " + day3.day.toString() + ", " + day3.year.toString());
      DateTime day4 = new DateTime(today.year, today.month, today.day - 4);
      String day4Month = monthConvert(day4.month);
      acceptable.add(
          day4Month + " " + day4.day.toString() + ", " + day4.year.toString());
      DateTime day5 = new DateTime(today.year, today.month, today.day - 3);
      String day5Month = monthConvert(day5.month);
      acceptable.add(
          day5Month + " " + day5.day.toString() + ", " + day5.year.toString());
      DateTime day6 = new DateTime(today.year, today.month, today.day - 2);
      String day6Month = monthConvert(day6.month);
      acceptable.add(
          day6Month + " " + day6.day.toString() + ", " + day6.year.toString());
      DateTime day7 = new DateTime(today.year, today.month, today.day - 1);
      String day7Month = monthConvert(day7.month);
      acceptable.add(
          day7Month + " " + day7.day.toString() + ", " + day7.year.toString());
    }

    if (today.weekday == 6) {
      //Saturday
      DateTime day1 = new DateTime(today.year, today.month, today.day);
      String day1Month = monthConvert(day1.month);
      acceptable.add(
          day1Month + " " + day1.day.toString() + ", " + day1.year.toString());
      DateTime day2 = new DateTime(today.year, today.month, today.day - 6);
      String day2Month = monthConvert(day2.month);
      acceptable.add(
          day2Month + " " + day2.day.toString() + ", " + day2.year.toString());
      DateTime day3 = new DateTime(today.year, today.month, today.day - 5);
      String day3Month = monthConvert(day3.month);
      acceptable.add(
          day3Month + " " + day3.day.toString() + ", " + day3.year.toString());
      DateTime day4 = new DateTime(today.year, today.month, today.day - 4);
      String day4Month = monthConvert(day4.month);
      acceptable.add(
          day4Month + " " + day4.day.toString() + ", " + day4.year.toString());
      DateTime day5 = new DateTime(today.year, today.month, today.day - 3);
      String day5Month = monthConvert(day5.month);
      acceptable.add(
          day5Month + " " + day5.day.toString() + ", " + day5.year.toString());
      DateTime day6 = new DateTime(today.year, today.month, today.day - 2);
      String day6Month = monthConvert(day6.month);
      acceptable.add(
          day6Month + " " + day6.day.toString() + ", " + day6.year.toString());
      DateTime day7 = new DateTime(today.year, today.month, today.day - 1);
      String day7Month = monthConvert(day7.month);
      acceptable.add(
          day7Month + " " + day7.day.toString() + ", " + day7.year.toString());
    }

    if (acceptable.contains(taskDate)) return true;
    return false;
  }

  String monthConvert(int month) {
    if (month == 1) return "January";
    if (month == 2) return "February";
    if (month == 3) return "March";
    if (month == 4) return "April";
    if (month == 5) return "May";
    if (month == 6) return "June";
    if (month == 7) return "July";
    if (month == 8) return "August";
    if (month == 9) return "September";
    if (month == 10) return "October";
    if (month == 11) return "November";
    if (month == 12) return "December";
    return null;
  }
}

class Info {
  String title;
  String actual;
  int time;
  charts.Color color;
  Info(this.title, this.actual, this.time, this.color);
}
