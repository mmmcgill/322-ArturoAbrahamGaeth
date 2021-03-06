import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:projectbusywork/tasks.dart';
import 'package:table_calendar/table_calendar.dart';
import 'DescriptionPage.dart';
import 'myColors.dart';
import 'package:projectbusywork/newactivity_widget.dart';
import 'newactivity_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class OverviewWidget extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();
}

class _OverviewState extends State<OverviewWidget> {
  File jsonFile;
  Directory dir;
  String fileName = "tasks.json";
  bool fileExists = false;
  List<dynamic> fileContent;
  String title = "Upcoming Tasks";
  List<Task> allTasks = List<Task>();
  List<Task> sTasks = List<Task>();
  final TextEditingController eCtrl = new TextEditingController();
  dynamic selectedDate;
  @override
  void initState() {
    super.initState();
    selectedDate = new DateFormat.yMMMd().format(new DateTime.now());
    title = selectedDate.toString();
    _controller = CalendarController();

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (!fileExists) {
        File file = new File(dir.path + "/" + fileName);
        file.createSync();
        fileExists = true;
        file.writeAsStringSync("[]");
      }
      this.setState(
          () => fileContent = json.decode(jsonFile.readAsStringSync()));

      getTasks().then((value) {
        setState(() {
          allTasks.addAll(value);
          sTasks = getTaskByDate(allTasks, sTasks, selectedDate);
        });
      });
    });
  }

  CalendarController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGreen,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                ),
                RawMaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewActivityWidget()),
                    ).then((directory) {
                      this.setState(() => fileContent =
                          json.decode(jsonFile.readAsStringSync()));

                      getTasks().then((value) {
                        setState(() {
                          allTasks = List<Task>();
                          allTasks.addAll(value);
                          sTasks =
                              getTaskByDate(allTasks, sTasks, selectedDate);
                        });
                      });
                    });
                  },
                  child: new Icon(
                    Icons.add,
                    size: 35.0,
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: hGreen,
                ),
              ],
            ),
            Container(
              height: 10,
              //child: Text("OverView",)
            ),
            TableCalendar(
              onDaySelected: _onDaySelected,
              calendarController: _controller,
              initialCalendarFormat: CalendarFormat.week,
              headerVisible: false,
              rowHeight: 70,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              builders: CalendarBuilders(
                selectedDayBuilder: (context, date, events) => Container(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  margin: EdgeInsets.all(3.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hGreen,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                dayBuilder: (context, date, events) => Container(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                        color: lightGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  margin: EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: const EdgeInsets.only(
                    left: 13.0, right: 13.0, top: 5, bottom: 20),
                child: new GroupedListView<dynamic, String>(
                    groupBy: (element) => element.date,
                    elements: sTasks,
                    sort: true,
                    //itemCount: allTasks.length,
                    groupSeparatorBuilder: (dynamic date) => Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                              /*child: Text(
                            date,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: lGreen),
                          )*/
                              ),
                        ),
                    itemBuilder: (c, element) {
                      return Dismissible(
                        key: Key(element.id),

                        onDismissed: (direction) {
                          List<dynamic> jsonFileContent =
                              json.decode(jsonFile.readAsStringSync());
                          for (var i = 0; i < jsonFileContent.length; i++) {
                            if (jsonFileContent[i]["id"] ==
                                element.id.toString()) {
                              jsonFileContent.removeAt(i);
                            }
                          }
                          // var index = jsonFileContent.indexOf(element);
                          // jsonFileContent.removeAt(index);
                          // jsonFileContent.remove(element);
                          jsonFile
                              .writeAsStringSync(json.encode(jsonFileContent));

                          this.setState(() => fileContent =
                              json.decode(jsonFile.readAsStringSync()));

                          setState(() {
                            allTasks.remove(element);
                            sTasks.remove(element);
                          });

                          // Then show a snackbar.
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Container(
                                child: Text(
                                  "${element.title} deleted",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.center,
                                ),
                                // width: 5.0,
                                // color: Colors.red,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.only(bottom: 10.0),
                              ),
                              elevation: 0.0,
                              backgroundColor: Colors.transparent));
                        },
                        // Show a red background as the item is swiped away.
                        background: Container(
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.delete_forever,
                                ))),
                        child: Card(
                          elevation: 2.0,
                          child: ListTile(
                            trailing: IconButton(
                              onPressed: () {
                                if (element.completed == "false") {
                                  element.completed = "true";
                                  writeToFileComp(element.id, "true");
                                  setState(() {
                                    element.completed = "true";
                                  });
                                } else {
                                  element.completed = "false";
                                  writeToFileComp(element.id, "false");
                                  setState(() {
                                    element.completed = "false";
                                  });
                                }
                              },
                              icon: element.completed == "false"
                                  ? Icon(Icons.check_box_outline_blank)
                                  : Icon(Icons.check_box),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DescriptionPage(
                                          desc: element.description,
                                          title: element.title,
                                          location: element.location,
                                          startTime: element.startTime,
                                          date: element.date,
                                          weekDay: element.weekDay,
                                          routine: element.routine,
                                          endTime: element.endTime,
                                          expected: element.expected,
                                          id: element.id,
                                        )),
                              ).then((directory) {
                                this.setState(() => fileContent =
                                    json.decode(jsonFile.readAsStringSync()));

                                getTasks().then((value) {
                                  setState(() {
                                    allTasks = List<Task>();
                                    allTasks.addAll(value);
                                    sTasks = getTaskByDate(
                                        allTasks, sTasks, selectedDate);
                                  });
                                });
                              });
                            },
                            title: element.completed == "false"
                                ? Text(element.title)
                                : Text(element.title,
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    )),
                            subtitle: element.completed == "false"
                                ? Text(
                                    "• Set Time: " +
                                        element.startTime +
                                        " - " +
                                        element.endTime +
                                        (element.actualStart != "00:00"
                                            ? "\n• Time Spent: " +
                                                element.actualStart
                                            : ""),
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    "• Set Time: " +
                                        element.startTime +
                                        " - " +
                                        element.endTime +
                                        (element.actualStart != "00:00"
                                            ? "\n• Time Spent: " +
                                                element.actualStart
                                            : ""),
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    )),
                          ),
                          color:
                              element.completed == "false" ? lGreen : bgGreen,
                          margin: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
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

  void writeToFileComp(dynamic id, dynamic value) {
    List<dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
    for (var i = 0; i < jsonFileContent.length; i++) {
      if (jsonFileContent[i]["id"] == id.toString()) {
        jsonFileContent[i]["completed"] = value;
      }
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      this.setState(
          () => fileContent = json.decode(jsonFile.readAsStringSync()));
    }
  }

  List<Task> getTaskByDate(List<Task> tasks, List<Task> tasks1, dynamic date) {
    tasks1.clear();

    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].date == date &&
          tasks1.firstWhere((itemToCheck) => itemToCheck.id == tasks[i].id,
                  orElse: () => null) ==
              null) {
        tasks1.add(tasks[i]);
      }
      DateFormat fdate = new DateFormat.yMMMd();
      DateTime tdate = fdate.parse(tasks[i].date);
      DateTime sdate = fdate.parse(date.toString());
      Duration difference = sdate.difference(tdate);
      print("sdate$sdate");
      print("date $date");
      print("tdate $tdate");
      print("difference ${difference.inDays}");
      print(tasks[i].routine);

      if (difference.inDays > 0) {
        var uuid = new Uuid();
        if (tasks[i].routine == "Daily") {
          Task t = new Task(
            id: uuid.v5(Uuid.NAMESPACE_OID,
                date.toString() + tasks[i].title + tasks[i].startTime),
            title: tasks[i].title,
            description: tasks[i].description,
            location: tasks[i].location,
            date: date,
            startTime: tasks[i].startTime,
            endTime: tasks[i].endTime,
            routine: tasks[i].routine,
            expected: tasks[i].expected,
            actualEnd: tasks[i].actualEnd,
            actualStart: tasks[i].actualStart,
            completed: "false",
          );

          if (tasks1.firstWhere((itemToCheck) => itemToCheck.id == t.id,
                  orElse: () => null) ==
              null) {
            tasks1.add(t);
            writeToFile(t);
          }
        }
        if (tasks[i].routine == "Weekly" && difference.inDays % 7 == 0 ||
            difference.inDays % 7 == 7) {
          Task t = new Task(
            id: uuid.v5(Uuid.NAMESPACE_OID,
                date.toString() + tasks[i].title + tasks[i].startTime),
            title: tasks[i].title,
            description: tasks[i].description,
            location: tasks[i].location,
            date: date,
            startTime: tasks[i].startTime,
            endTime: tasks[i].endTime,
            routine: tasks[i].routine,
            expected: tasks[i].expected,
            actualEnd: tasks[i].actualEnd,
            actualStart: tasks[i].actualStart,
            completed: "false",
          );
          if (tasks1.firstWhere((itemToCheck) => itemToCheck.id == t.id,
                  orElse: () => null) ==
              null) {
            tasks1.add(t);
            writeToFile(t);
          }
        }
        if (tasks[i].routine == "Monthly" && difference.inDays % 30 == 0 ||
            difference.inDays % 30 == 30) {
          Task t = new Task(
            id: uuid.v5(Uuid.NAMESPACE_OID,
                date.toString() + tasks[i].title + tasks[i].startTime),
            title: tasks[i].title,
            description: tasks[i].description,
            location: tasks[i].location,
            date: date,
            startTime: tasks[i].startTime,
            endTime: tasks[i].endTime,
            routine: tasks[i].routine,
            expected: tasks[i].expected,
            actualEnd: tasks[i].actualEnd,
            actualStart: tasks[i].actualStart,
            completed: "false",
          );
          if (tasks1.firstWhere((itemToCheck) => itemToCheck.id == t.id,
                  orElse: () => null) ==
              null) {
            tasks1.add(t);
            writeToFile(t);
          }
        }
      }
    }
    return tasks1;
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      selectedDate = new DateFormat.yMMMd().format(day);
      sTasks = getTaskByDate(allTasks, sTasks, selectedDate);
      title = selectedDate.toString();
    });
  }

  void writeToFile(dynamic value) {
    if (fileExists) {
      List<dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.add(value);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);
  }
}
