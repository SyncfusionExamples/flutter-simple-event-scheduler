import 'dart:async';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'appointment_editor.dart';
import 'calendar_data.dart';

void main() {
  runApp(MyApp());
}

CalendarData calendarData;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Customized Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

int firstDayOfWeek = 7;
int eventDuration = 60;
double startHour = 0.0;
double endHour = 24.0;
bool showArrows = false;

class _MyHomePageState extends State<MyHomePage> {
  GoogleDataSource _dataSource;
  CalendarController _controller;
  bool _isDBLoaded = false;

  @override
  void initState() {
    _dataSource = GoogleDataSource();
    calendarData = CalendarData(_dataSource, updateUI);
    _isDBLoaded = false;
    calendarData.updateSettingFromDB(updateUI)
      ..then((value) {
        _isDBLoaded = true;
        updateUI();
      });
    calendarData.currentUser.addListener(() {
      updateUI();
    });
    _controller = CalendarController()
      ..displayDate = DateTime.now()
      ..view = CalendarView.month;
    super.initState();
  }

  void onCalendarTapped(CalendarTapDetails calendarTapDetails) async {
    if (calendarTapDetails.targetElement == CalendarElement.header) {
      setState(() {
        /// Update the draw content when calendar view changed.
        _controller.view = CalendarView.month;
      });
      return;
    } else if (calendarTapDetails.targetElement == CalendarElement.viewHeader) {
      if (_controller.view == CalendarView.day) {
        _controller.displayDate = calendarTapDetails.date;
        setState(() {
          /// Update the draw content when calendar view changed.
          _controller.view = CalendarView.schedule;
        });
      } else if (_controller.view == CalendarView.schedule) {
        _controller.displayDate = calendarTapDetails.date;
        setState(() {
          /// Update the draw content when calendar view changed.
          _controller.view = CalendarView.day;
        });
      }

      return;
    }

    googleAPI.Event event;
    final bool _isAllDay =
        calendarTapDetails.targetElement == CalendarElement.allDayPanel;
    DateTime _selectedDate;

    if (_controller.view == CalendarView.month && calendarTapDetails.targetElement != CalendarElement.appointment) {
      setState(() {
        /// Update the draw content when calendar view changed.
        _controller.view = CalendarView.day;
      });
    } else {
      final bool _connectionStatus = await calendarData.getConnectionStatus();
      if (!_connectionStatus) {
        return;
      }

      if (calendarData.currentUser == null ||
          calendarData.currentUser.value == null) {
        return;
      }

      if (calendarTapDetails.appointments != null &&
          calendarTapDetails.targetElement == CalendarElement.appointment) {
        event = calendarTapDetails.appointments[0];
      } else {
        _selectedDate = calendarTapDetails.date;
      }

      Navigator.push(
        context,
        _createRoute(
            AppointmentEditor(event, _dataSource, _selectedDate, _isAllDay)),
      );
    }
  }

  void onCalendarViewChange(String value) {
    if (value == 'Day') {
      _controller.view = CalendarView.day;
    } else if (value == 'Week') {
      _controller.view = CalendarView.week;
    } else if (value == 'Work week') {
      _controller.view = CalendarView.workWeek;
    } else if (value == 'Month') {
      _controller.view = CalendarView.month;
    } else if (value == 'Timeline day') {
      _controller.view = CalendarView.timelineDay;
    } else if (value == 'Timeline week') {
      _controller.view = CalendarView.timelineWeek;
    } else if (value == 'Timeline work week') {
      _controller.view = CalendarView.timelineWorkWeek;
    } else if (value == 'Timeline month') {
      _controller.view = CalendarView.timelineMonth;
    } else if (value == 'Schedule') {
      _controller.view = CalendarView.schedule;
    }
  }

  bool _isSelectedView(String value) {
    if (value == 'Day' && _controller.view == CalendarView.day) {
      return true;
    } else if (value == 'Week' && _controller.view == CalendarView.week) {
      return true;
    } else if (value == 'Work week' &&
        _controller.view == CalendarView.workWeek) {
      return true;
    } else if (value == 'Month' && _controller.view == CalendarView.month) {
      return true;
    } else if (value == 'Timeline day' &&
        _controller.view == CalendarView.timelineDay) {
      return true;
    } else if (value == 'Timeline week' &&
        _controller.view == CalendarView.timelineWeek) {
      return true;
    } else if (value == 'Timeline work week' &&
        _controller.view == CalendarView.timelineWorkWeek) {
      return true;
    } else if (value == 'Timeline month' &&
        _controller.view == CalendarView.timelineMonth) {
      return true;
    } else if (value == 'Schedule' &&
        _controller.view == CalendarView.schedule) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    super.dispose();
    calendarData.closeStream();
  }

  void updateUI() {
    setState(() {
      /// Update the calendar UI.
    });
  }

  Widget _createHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      padding: const EdgeInsetsDirectional.only(top: 16.0),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Stack(children: <Widget>[
                Container(
                  padding: const EdgeInsetsDirectional.only(end: 16.0),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 72.0,
                    height: 72.0,
                    child: CircleAvatar(
                      backgroundImage: calendarData.currentUser != null &&
                              calendarData.currentUser.value != null
                          ? NetworkImage(
                              calendarData.currentUser.value.photoUrl)
                          : null,
                      backgroundColor: calendarData.currentUser != null &&
                              calendarData.currentUser.value != null
                          ? null
                          : Colors.white,
                      child: calendarData.currentUser != null &&
                              calendarData.currentUser.value != null &&
                              calendarData.currentUser.value?.displayName[0] !=
                                  null
                          ? null
                          : Icon(Icons.account_circle,
                              size: 72, color: Theme.of(context).primaryColor),
                    ),
                  ),
                )
              ]),
            ),
            if (calendarData.currentUser == null ||
                calendarData.currentUser.value == null)
              ListTile(
                  hoverColor: Colors.grey,
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 25,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10.0),
                        alignment: Alignment.centerLeft,
                        child: Text('Add Account',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                  onTap: (() async {
                    showDialog(
                        context: context,barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    await calendarData.handleSignIn(
                        _dataSource, context, updateUI);

                    /// Update settings value to calendar.
                    updateUI();

                    /// Close the progress indicator dialog.
                    Navigator.pop(context);

                    /// Close the drawer.
                    Navigator.pop(context);
                  })),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (calendarData.currentUser != null &&
                    calendarData.currentUser.value != null &&
                    calendarData.currentUser.value.displayName[0] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(calendarData.currentUser.value.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                        )),
                  ),
                if (calendarData.currentUser != null &&
                    calendarData.currentUser.value != null &&
                    calendarData.currentUser.value?.email != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 2),
                    child: Text(calendarData.currentUser.value.email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                        )),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Returns the month name based on the month value passed from date.
  String _getMonthDate(int month) {
    if (month == 01) {
      return 'January';
    } else if (month == 02) {
      return 'February';
    } else if (month == 03) {
      return 'March';
    } else if (month == 04) {
      return 'April';
    } else if (month == 05) {
      return 'May';
    } else if (month == 06) {
      return 'June';
    } else if (month == 07) {
      return 'July';
    } else if (month == 08) {
      return 'August';
    } else if (month == 09) {
      return 'September';
    } else if (month == 10) {
      return 'October';
    } else if (month == 11) {
      return 'November';
    } else {
      return 'December';
    }
  }

  /// Returns the builder for schedule view.
  Widget scheduleViewBuilder(
      BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
    final String monthName = _getMonthDate(details.date.month);
    return Stack(
      children: [
        Image.asset('assets/images/' + monthName + '.png',
            fit: BoxFit.cover,
            width: details.bounds.width,
            height: details.bounds.height),
        Positioned(
          left: 55,
          right: 0,
          top: 20,
          bottom: 0,
          child: Text(
            monthName + ' ' + details.date.year.toString(),
            style: TextStyle(fontSize: 18),
          ),
        )
      ],
    );
  }

  Widget _createDrawerItem(
      {IconData icon,
      String text,
      GestureTapCallback onTap,
      bool isSelected = false}) {
    return Container(
        height: 50,
        child: ListTile(
          tileColor: isSelected ? Colors.grey.withOpacity(0.3) : null,
          title: Row(
            children: <Widget>[
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.black54,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  text,
                  style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                ),
              )
            ],
          ),
          onTap: onTap,
        ));
  }

  void onTap(String view) {
    onCalendarViewChange(view);
    Navigator.pop(context);
    setState(() {
      /// Update the draw content when calendar view changed.
    });
  }

  Route _createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.7;
    return !_isDBLoaded
        ? Scaffold(
            body: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.widgets,
                      color: Colors.black54,
                    ),
                    Text(
                      ' Syncfusion Calendar',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                )),
          )
        : Scaffold(
            drawer: Container(
                width: width > 300 ? 300 : width,
                child: Drawer(
                    child: ListView(
                  padding: EdgeInsets.all(0),
                  children: <Widget>[
                    _createHeader(),
                    if (calendarData.currentUser != null &&
                        calendarData.currentUser.value != null)
                      _createDrawerItem(
                          icon: Icons.logout,
                          text: 'Sign out',
                          onTap: (() async {
                            showDialog(
                                context: context,barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                });
                            await calendarData.signOut(_dataSource, updateUI);

                            /// Update settings value to calendar.
                            updateUI();

                            /// Close the progress indicator dialog.
                            Navigator.pop(context);

                            /// Close the drawer.
                            Navigator.pop(context);
                          })),
                    _createDrawerItem(
                        icon: Icons.view_agenda_outlined,
                        text: 'Schedule',
                        isSelected: _isSelectedView('Schedule'),
                        onTap: () {
                          onTap('Schedule');
                        }),
                    _createDrawerItem(
                        icon: Icons.view_module_outlined,
                        text: 'Month',
                        isSelected: _isSelectedView('Month'),
                        onTap: () {
                          onTap('Month');
                        }),
                    _createDrawerItem(
                        icon: Icons.view_day_outlined,
                        text: 'Day',
                        isSelected: _isSelectedView('Day'),
                        onTap: () {
                          onTap('Day');
                        }),
                    _createDrawerItem(
                        icon: Icons.view_week_outlined,
                        text: 'Week',
                        isSelected: _isSelectedView('Week'),
                        onTap: () {
                          onTap('Week');
                        }),
                    _createDrawerItem(
                        icon: Icons.view_week_outlined,
                        text: 'Work Week',
                        isSelected: _isSelectedView('Work week'),
                        onTap: () {
                          onTap('Work week');
                        }),
                    Divider(
                      thickness: 1,
                    ),
                    _createDrawerItem(
                        icon: Icons.view_array_outlined,
                        text: 'Timeline Day',
                        isSelected: _isSelectedView('Timeline day'),
                        onTap: () {
                          onTap('Timeline day');
                        }),
                    _createDrawerItem(
                        icon: Icons.table_chart_outlined,
                        text: 'Timeline Week',
                        isSelected: _isSelectedView('Timeline week'),
                        onTap: () {
                          onTap('Timeline week');
                        }),
                    _createDrawerItem(
                        icon: Icons.table_chart_outlined,
                        text: 'Timeline Work Week',
                        isSelected: _isSelectedView('Timeline work week'),
                        onTap: () {
                          onTap('Timeline work week');
                        }),
                    _createDrawerItem(
                        icon: Icons.view_module_outlined,
                        text: 'Timeline Month',
                        isSelected: _isSelectedView('Timeline month'),
                        onTap: () {
                          onTap('Timeline month');
                        }),
                    Divider(
                      thickness: 1,
                    ),
                    _createDrawerItem(
                        icon: Icons.settings_outlined,
                        text: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, _createRoute(SettingsPanel()))
                            ..whenComplete(() => {
                                  setState(() {
                                    /// Update settings changes to calendar
                                  })
                                });
                        }),
                    ListTile(
                      title: Text('Version 1.0.0'),
                    ),
                  ],
                ))),
            appBar: AppBar(
              bottom: PreferredSize(
                  preferredSize: Size(double.infinity, 3.0),
                  child: SizedBox(
                      height: 3.0,
                      child: StreamBuilder(
                          stream: calendarData.loadingStream.isLoading,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data) {
                              return LinearProgressIndicator();
                            } else {
                              return Container();
                            }
                          }))),
              actions: <Widget>[
                if (calendarData.currentUser != null &&
                    calendarData.currentUser.value != null)
                  IconButton(
                      icon: Icon(Icons.autorenew),
                      onPressed: () async {
                        calendarData.refresh(_dataSource, updateUI);
                      }),
                IconButton(
                  icon: Icon(Icons.today),
                  onPressed: () {
                    _controller.displayDate = DateTime.now();
                  },
                )
              ],
            ),
            body: Center(
              child: SfCalendar(
                controller: _controller,
                dataSource: _dataSource,
                onTap: onCalendarTapped,
                showNavigationArrow: showArrows,
                firstDayOfWeek: firstDayOfWeek,
                scheduleViewMonthHeaderBuilder: scheduleViewBuilder,
                timeSlotViewSettings: TimeSlotViewSettings(
                  minimumAppointmentDuration: Duration(minutes: eventDuration),
                  startHour: startHour,
                  endHour: endHour,
                ),
                monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment),
              ),
            ),
            floatingActionButton: calendarData.currentUser != null &&
                    calendarData.currentUser.value != null
                ? FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () {
                      if (calendarData.currentUser == null ||
                          calendarData.currentUser.value == null) {
                        return;
                      }

                      final DateTime date = DateTime.now();
                      Navigator.push(
                          context,
                          _createRoute(AppointmentEditor(
                              null, _dataSource, date, false)));
                    },
                  )
                : null, // This trailing comma makes auto-formatting nicer for build methods.
          );
  }
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({List<googleAPI.Event> events}) {
    this.appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final googleAPI.Event event = appointments[index];
    return event.start.date ?? event.start.dateTime.toLocal();
  }

  @override
  Color getColor(int index) {
    final googleAPI.Event event = appointments[index];
    return event.colorId != null
        ? calendarData.fromHex(
            (calendarData.colors[event.colorId] as googleAPI.ColorDefinition)
                .background)
        : Colors.blue;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final googleAPI.Event event = appointments[index];
    return event.endTimeUnspecified != null && event.endTimeUnspecified
        ? (event.start.date ?? event.start.dateTime.toLocal())
        : (event.start.date != null
            ? event.end.date.add(Duration(days: -1))
            : event.end.dateTime.toLocal());
  }

  @override
  String getEndTimeZone(int index) {
    final googleAPI.Event event = appointments[index];
    return calendarData.getTimeZone(event.end.timeZone);
  }

  @override
  String getLocation(int index) {
    return appointments[index].location;
  }

  @override
  String getNotes(int index) {
    return appointments[index].description;
  }

  @override
  String getRecurrenceRule(int index) {
    final googleAPI.Event event = appointments[index];
    final DateTime _startDate =
        (event.start.date ?? event.start.dateTime.toLocal());
    final List<String> recurrence = event.recurrence;
    if (recurrence != null) {
      for (int i = 0; i < recurrence.length; i++) {
        String text = recurrence[i];
        if (text.contains('RRULE:')) {
          text = text.substring(6);
          if (text.contains('WEEKLY') && !text.contains('BYDAY')) {
            text += ';BYDAY=' + calendarData.getWeekDayString(_startDate);
          } else if (text.contains('MONTHLY') &&
              !text.contains('BYDAY') &&
              !text.contains('BYMONTHDAY')) {
            text += ';BYMONTHDAY=' + _startDate.day.toString();
          } else if (text.contains('YEARLY') && !text.contains('BYMONTH')) {
            text += ';BYMONTH=' +
                _startDate.month.toString() +
                ';BYMONTHDAY=' +
                _startDate.day.toString();
          }
          return text;
        }
      }
    }

    return '';
  }

  @override
  String getStartTimeZone(int index) {
    final googleAPI.Event event = appointments[index];
    return calendarData.getTimeZone(event.start.timeZone);
  }

  @override
  String getSubject(int index) {
    final googleAPI.Event event = appointments[index];
    return event.summary == null || event.summary.isEmpty
        ? 'No Title'
        : event.summary;
  }
}

class SettingsPanel extends StatefulWidget {
  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final Map<int, String> weekDays = <int, String>{
    6: 'Saturday',
    7: 'Sunday',
    1: 'Monday'
  };
  final Map<int, String> eventDurations = <int, String>{
    15: '15 minutes',
    30: '30 minutes',
    60: '60 minutes',
    90: '90 minutes',
    120: '120 minutes'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Settings'),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Container(
          child: ListView(
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Start of the week'),
                subtitle: Text(weekDays[firstDayOfWeek]),
                onTap: () async {
                  final List<int> keys = weekDays.keys.toList();
                  final int selectedIndex = await _simpleDialog(
                      context, weekDays.values.toList(), 'Start of the week');
                  if (selectedIndex == null) {
                    return;
                  }

                  final int selectedValue = keys[selectedIndex];
                  if (firstDayOfWeek == selectedValue) {
                    return;
                  }

                  setState(() {
                    firstDayOfWeek = selectedValue;
                    calendarData.updateFirebaseData();
                  });
                },
              ),
              Divider(
                thickness: 1,
                height: 1,
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Default event duration'),
                subtitle: Text(eventDuration.toString() + ' minutes'),
                onTap: () async {
                  final List<int> keys = eventDurations.keys.toList();
                  final int selectedIndex = await _simpleDialog(context,
                      eventDurations.values.toList(), 'Start of the week');
                  if (selectedIndex == null) {
                    return;
                  }

                  final int selectedValue = keys[selectedIndex];
                  if (eventDuration == selectedValue) {
                    return;
                  }

                  setState(() {
                    eventDuration = selectedValue;
                    calendarData.updateFirebaseData();
                  });
                },
              ),
              Divider(
                thickness: 1,
                height: 1,
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 16),
                title: Text('Start time'),
                trailing: NumericUpDown(
                  minValue: 0.0,
                  maxValue: endHour,
                  value: startHour,
                  onChanged: (value) {
                    setState(() {
                      startHour = value;
                      calendarData.updateFirebaseData();
                    });
                  },
                ),
              ),
              Divider(
                thickness: 1,
                height: 1,
              ),
              ListTile(
                contentPadding: EdgeInsets.only(left: 16),
                title: Text('End time'),
                trailing: NumericUpDown(
                  minValue: startHour,
                  maxValue: 24.0,
                  value: endHour,
                  onChanged: (value) {
                    setState(() {
                      endHour = value;
                      calendarData.updateFirebaseData();
                    });
                  },
                ),
              ),
              Divider(
                thickness: 1,
                height: 1,
              ),
              SwitchListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Text('Show navigation arrow'),
                value: showArrows,
                onChanged: (bool value) {
                  setState(() {
                    showArrows = value;
                    calendarData.updateFirebaseData();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _simpleDialog(
      BuildContext context, List<String> options, String headerText) async {
    return await showDialog<int>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(headerText),
            children: _getListChildren(options),
          );
        });
  }

  List<Widget> _getListChildren(List<String> options) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < options.length; i++) {
      children.add(
        SimpleDialogOption(
          child: Text(options[i]),
          onPressed: () {
            Navigator.pop(context, i);
          },
        ),
      );
    }

    return children;
  }
}

class NumericUpDown extends StatefulWidget {
  NumericUpDown(
      {this.minValue = 0.0, this.maxValue = 24.0, this.onChanged, this.value});

  final double minValue;
  final double maxValue;
  final double value;

  final ValueChanged<double> onChanged;

  @override
  State<NumericUpDown> createState() {
    return _NumericUpDownState();
  }
}

class _NumericUpDownState extends State<NumericUpDown> {
  double value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).accentColor;
    return Container(
      width: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
              color: value > widget.minValue
                  ? iconColor
                  : iconColor.withOpacity(0.3),
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            iconSize: 18.0,
            hoverColor: value > widget.minValue ? null : Colors.transparent,
            splashColor: value > widget.minValue ? null : Colors.transparent,
            highlightColor: value > widget.minValue ? null : Colors.transparent,
            splashRadius: 18,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                if (value > widget.minValue) {
                  value--;
                }
                widget.onChanged(value);
              });
            },
          ),
          Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: value < widget.maxValue
                  ? iconColor
                  : iconColor.withOpacity(0.3),
            ),
            splashRadius: 18,
            hoverColor: value < widget.maxValue ? null : Colors.transparent,
            splashColor: value < widget.maxValue ? null : Colors.transparent,
            highlightColor: value < widget.maxValue ? null : Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            iconSize: 18.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                if (value < widget.maxValue) {
                  value++;
                }
                widget.onChanged(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
