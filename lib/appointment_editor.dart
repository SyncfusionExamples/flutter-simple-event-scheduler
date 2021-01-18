import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'main.dart';

class AppointmentEditor extends StatefulWidget {
  AppointmentEditor(
      this.event, this.dataSource, this._selectedDate, this.isAllDay);

  final googleAPI.Event event;
  final GoogleDataSource dataSource;
  final DateTime _selectedDate;
  final bool isAllDay;

  @override
  AppointmentEditorState createState() => AppointmentEditorState();
}

class AppointmentEditorState extends State<AppointmentEditor> {
  List<String> _timeZoneCollection = <String>[];
  int _selectedTimeZoneIndex;
  int _selectedColorIndex;
  List<String> _colorCollection = <String>[];
  List<String> _colorNames = <String>[];
  final Color defaultColor = Colors.grey;
  DateTime _startDate;
  DateTime _endDate;
  bool _isAllDay;
  String _subject;
  String _notes;
  TimeOfDay _startTime;
  TimeOfDay _endTime;

  @override
  void initState() {
    _colorCollection = <String>[];
    _colorNames = <String>[
      'Lavendar',
      'Light green',
      'Violet',
      'Light Red',
      'Yellow',
      'Orange',
      'Sky blue',
      'Grey',
      'Dark blue',
      ' Green',
      'Red',
      'Default color'
    ];
    if (calendarData.colors.keys != null) {
      _colorCollection = calendarData.colors.keys.toList();
    }

    _timeZoneCollection = <String>[];
    _timeZoneCollection.add('Australia/Darwin');
    _timeZoneCollection.add('Australia/Sydney');
    _timeZoneCollection.add('Asia/Kabul');
    _timeZoneCollection.add('America/Anchorage');
    _timeZoneCollection.add('Asia/Riyadh');
    _timeZoneCollection.add('Indian/Reunion');
    _timeZoneCollection.add('Asia/Baghdad');
    _timeZoneCollection.add('America/Argentina/Buenos_Aires');
    _timeZoneCollection.add('America/Halifax');
    _timeZoneCollection.add('Asia/Baku');
    _timeZoneCollection.add('Atlantic/Azores');
    _timeZoneCollection.add('America/Bahia');
    _timeZoneCollection.add('Asia/Dhaka');
    _timeZoneCollection.add('Europe/Minsk');
    _timeZoneCollection.add('America/Regina');
    _timeZoneCollection.add('Atlantic/Cape_Verde');
    _timeZoneCollection.add('Asia/Yerevan');
    _timeZoneCollection.add('Australia/Adelaide');
    _timeZoneCollection.add('America/Guatemala');
    _timeZoneCollection.add('Asia/Almaty');
    _timeZoneCollection.add('America/Cuiaba');
    _timeZoneCollection.add('Europe/Budapest');
    _timeZoneCollection.add('Europe/Warsaw');
    _timeZoneCollection.add('Pacific/Guadalcanal');
    _timeZoneCollection.add('America/Chicago');
    _timeZoneCollection.add('Asia/Shanghai');
    _timeZoneCollection.add('Etc/GMT+12');
    _timeZoneCollection.add('Africa/Nairobi');
    _timeZoneCollection.add('Australia/Brisbane');
    _timeZoneCollection.add('America/Sao_Paulo');
    _timeZoneCollection.add('America/New_York');
    _timeZoneCollection.add('Africa/Cairo');
    _timeZoneCollection.add('Asia/Yekaterinburg');
    _timeZoneCollection.add('Europe/Kiev');
    _timeZoneCollection.add('Pacific/Fiji');
    _timeZoneCollection.add('Europe/London');
    _timeZoneCollection.add('Europe/Bucharest');
    _timeZoneCollection.add('Asia/Tbilisi');
    _timeZoneCollection.add('America/Godthab');
    _timeZoneCollection.add('Atlantic/Reykjavik');
    _timeZoneCollection.add('Pacific/Honolulu');
    _timeZoneCollection.add('Asia/Kolkata');
    _timeZoneCollection.add('Asia/Tehran');
    _timeZoneCollection.add('Asia/Jerusalem');
    _timeZoneCollection.add('Asia/Amman');
    _timeZoneCollection.add('Europe/Kaliningrad');
    _timeZoneCollection.add('Asia/Seoul');
    _timeZoneCollection.add('Africa/Tripoli');
    _timeZoneCollection.add('Pacific/Kiritimati');
    _timeZoneCollection.add('Asia/Magadan');
    _timeZoneCollection.add('Indian/Mauritius');
    _timeZoneCollection.add('Asia/Beirut');
    _timeZoneCollection.add('America/Montevideo');
    _timeZoneCollection.add('Africa/Casablanca');
    _timeZoneCollection.add('America/Denver');
    _timeZoneCollection.add('America/Chihuahua');
    _timeZoneCollection.add('Asia/Rangoon');
    _timeZoneCollection.add('Asia/Novosibirsk');
    _timeZoneCollection.add('Africa/Windhoek');
    _timeZoneCollection.add('Asia/Kathmandu');
    _timeZoneCollection.add('Pacific/Auckland');
    _timeZoneCollection.add('America/St_Johns');
    _timeZoneCollection.add('Asia/Irkutsk');
    _timeZoneCollection.add('Asia/Krasnoyarsk');
    _timeZoneCollection.add('America/Santiago');
    _timeZoneCollection.add('America/Los_Angeles');
    _timeZoneCollection.add('America/Santa_Isabel');
    _timeZoneCollection.add('Asia/Karachi');
    _timeZoneCollection.add('America/Asuncion');
    _timeZoneCollection.add('Europe/Paris');
    _timeZoneCollection.add('Asia/Srednekolymsk');
    _timeZoneCollection.add('Asia/Kamchatka');
    _timeZoneCollection.add('Europe/Samara');
    _timeZoneCollection.add('Europe/Moscow');
    _timeZoneCollection.add('America/Cayenne');
    _timeZoneCollection.add('America/Bogota');
    _timeZoneCollection.add('America/La_Paz');
    _timeZoneCollection.add('Asia/Bangkok');
    _timeZoneCollection.add('Pacific/Apia');
    _timeZoneCollection.add('Asia/Singapore');
    _timeZoneCollection.add('Africa/Johannesburg');
    _timeZoneCollection.add('Asia/Colombo');
    _timeZoneCollection.add('Asia/Damascus');
    _timeZoneCollection.add('Asia/Taipei');
    _timeZoneCollection.add('Australia/Hobart');
    _timeZoneCollection.add('Asia/Tokyo');
    _timeZoneCollection.add('Pacific/Tongatapu');
    _timeZoneCollection.add('Europe/Istanbul');
    _timeZoneCollection.add('America/Indiana/Indianapolis');
    _timeZoneCollection.add('America/Phoenix');
    _timeZoneCollection.add('America/Danmarkshavn');
    _timeZoneCollection.add('Pacific/Tarawa');
    _timeZoneCollection.add('America/Noronha');
    _timeZoneCollection.add('Pacific/Midway');
    _timeZoneCollection.add('Asia/Ulaanbaatar');
    _timeZoneCollection.add('America/Caracas');
    _timeZoneCollection.add('Asia/Vladivostok');
    _timeZoneCollection.add('Australia/Perth');
    _timeZoneCollection.add('Africa/Lagos');
    _timeZoneCollection.add('Europe/Berlin');
    _timeZoneCollection.add('Asia/Tashkent');
    _timeZoneCollection.add('Pacific/Port_Moresby');
    _timeZoneCollection.add('Asia/Yakutsk');

    if (widget.event != null) {
      final Duration _offset = DateTime.now().timeZoneOffset;
      _startDate =
          widget.event.start.date ?? widget.event.start.dateTime.add(_offset);
      _endDate = widget.event.endTimeUnspecified != null &&
              widget.event.endTimeUnspecified
          ? _startDate
          : widget.event.end.date != null
              ? DateTime(widget.event.end.date.year,
                  widget.event.end.date.month, widget.event.end.date.day - 1)
              : widget.event.end.dateTime.add(_offset);
      _startTime = widget.event.start.dateTime != null
          ? TimeOfDay(hour: _startDate.hour, minute: _startDate.minute)
          : TimeOfDay(minute: 0, hour: 0);
      _endTime = widget.event.end.dateTime != null ||
              (widget.event.endTimeUnspecified != null &&
                  widget.event.endTimeUnspecified)
          ? TimeOfDay(hour: _endDate.hour, minute: _endDate.minute)
          : TimeOfDay(minute: 0, hour: 0);
      _isAllDay = widget.event.start.date != null;
      _subject = widget.event.summary;
      _notes = widget.event.description;
      _selectedColorIndex = widget.event.colorId == null
          ? -1
          : _colorCollection.indexOf(widget.event.colorId);
      _selectedTimeZoneIndex = widget.event.start.timeZone == null
          ? -1
          : _timeZoneCollection.indexOf(widget.event.start.timeZone);
    } else {
      _startDate = widget._selectedDate;
      _endDate = widget._selectedDate.add(Duration(hours: 1));
      _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
      _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
      _isAllDay = widget.isAllDay;
      _subject = '';
      _notes = '';
      _selectedColorIndex = -1;
      _selectedTimeZoneIndex = -1;
    }

    super.initState();
  }

  @override
  Widget build([BuildContext context]) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: _selectedColorIndex == -1
              ? Colors.blue
              : calendarData.fromHex(
                  (calendarData.colors[_colorCollection[_selectedColorIndex]]
                          as googleAPI.ColorDefinition)
                      .background),
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                icon: const Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                onPressed: () {
                  googleAPI.Event event = widget.event ?? googleAPI.Event();
                  final DateTime _eventStartTime = DateTime(
                      _startDate.year,
                      _startDate.month,
                      _startDate.day,
                      _startTime.hour,
                      _startTime.minute);
                  final DateTime _eventEndTime = DateTime(
                      _endDate.year,
                      _endDate.month,
                      _endDate.day,
                      _endTime.hour,
                      _endTime.minute);
                  event.summary = _subject;
                  event.start = googleAPI.EventDateTime()
                    ..date = _isAllDay
                        ? DateTime(
                            _startDate.year, _startDate.month, _startDate.day)
                        : null
                    ..dateTime = _isAllDay ? null : _eventStartTime.toUtc()
                    ..timeZone = _isAllDay
                        ? null
                        : _selectedTimeZoneIndex != -1
                            ? _timeZoneCollection[_selectedTimeZoneIndex]
                            : null;
                  event.end = googleAPI.EventDateTime()
                    ..date = _isAllDay
                        ? DateTime(
                            _endDate.year, _endDate.month, _endDate.day + 1)
                        : null
                    ..dateTime = _isAllDay ? null : _eventEndTime.toUtc()
                    ..timeZone = _isAllDay
                        ? null
                        : _selectedTimeZoneIndex != -1
                            ? _timeZoneCollection[_selectedTimeZoneIndex]
                            : null;
                  event.description = _notes;
                  event.colorId = _selectedColorIndex == -1
                      ? null
                      : _colorCollection[_selectedColorIndex];
                  if (widget.event == null) {
                    calendarData.addAppointment(widget.dataSource, event);
                  } else {
                    calendarData.updateAppointment(widget.dataSource, event);
                  }

                  Navigator.pop(context);
                })
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Stack(
            children: <Widget>[_getAppointmentEditor(context)],
          ),
        ),
        floatingActionButton: widget.event == null
            ? const Text('')
            : FloatingActionButton(
                onPressed: () {
                  if (widget.event != null) {
                    calendarData.deleteAppointment(
                        widget.dataSource, widget.event);
                    Navigator.pop(context);
                  }
                },
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ));
  }

  Widget _getAppointmentEditor(BuildContext context) {
    return Container(
        child: ListView(
      padding: const EdgeInsets.all(0),
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
          leading: const Text(''),
          title: TextField(
            controller: TextEditingController(text: _subject),
            onChanged: (String value) {
              _subject = value;
            },
            keyboardType: TextInputType.multiline,
            maxLines: null,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Add title',
            ),
          ),
        ),
        const Divider(
          height: 1.0,
          thickness: 1,
        ),
        ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: Icon(
              Icons.access_time,
            ),
            title: Row(children: <Widget>[
              const Expanded(
                child: Text('All-day'),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: _isAllDay,
                        onChanged: (bool value) {
                          setState(() {
                            _isAllDay = value;
                          });
                        },
                      ))),
            ])),
        ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: const Text(''),
            title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                        child: Text(
                            DateFormat('EEE, MMM dd yyyy').format(_startDate),
                            textAlign: TextAlign.left),
                        onTap: () async {
                          final DateTime date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );

                          if (date != null && date != _startDate) {
                            setState(() {
                              final Duration difference =
                                  _endDate.difference(_startDate);
                              _startDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  _startTime.hour,
                                  _startTime.minute,
                                  0);
                              _endDate = _startDate.add(difference);
                              _endTime = TimeOfDay(
                                  hour: _endDate.hour, minute: _endDate.minute);
                            });
                          }
                        }),
                  ),
                  Expanded(
                      flex: 3,
                      child: _isAllDay
                          ? const Text('')
                          : GestureDetector(
                              child: Text(
                                DateFormat('hh:mm a').format(_startDate),
                                textAlign: TextAlign.right,
                              ),
                              onTap: () async {
                                final TimeOfDay time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: _startTime.hour,
                                      minute: _startTime.minute),
                                );

                                if (time != null && time != _startTime) {
                                  setState(() {
                                    _startTime = time;
                                    final Duration difference =
                                        _endDate.difference(_startDate);
                                    _startDate = DateTime(
                                        _startDate.year,
                                        _startDate.month,
                                        _startDate.day,
                                        _startTime.hour,
                                        _startTime.minute,
                                        0);
                                    _endDate = _startDate.add(difference);
                                    _endTime = TimeOfDay(
                                        hour: _endDate.hour,
                                        minute: _endDate.minute);
                                  });
                                }
                              })),
                ])),
        ListTile(
            contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            leading: const Text(''),
            title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                        child: Text(
                          DateFormat('EEE, MMM dd yyyy').format(_endDate),
                          textAlign: TextAlign.left,
                        ),
                        onTap: () async {
                          final DateTime date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );

                          if (date != null && date != _endDate) {
                            setState(() {
                              final Duration difference =
                                  _endDate.difference(_startDate);
                              _endDate = DateTime(date.year, date.month,
                                  date.day, _endTime.hour, _endTime.minute, 0);
                              if (_endDate.isBefore(_startDate)) {
                                _startDate = _endDate.subtract(difference);
                                _startTime = TimeOfDay(
                                    hour: _startDate.hour,
                                    minute: _startDate.minute);
                              }
                            });
                          }
                        }),
                  ),
                  Expanded(
                      flex: 3,
                      child: _isAllDay
                          ? const Text('')
                          : GestureDetector(
                              child: Text(
                                DateFormat('hh:mm a').format(_endDate),
                                textAlign: TextAlign.right,
                              ),
                              onTap: () async {
                                final TimeOfDay time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                        hour: _endTime.hour,
                                        minute: _endTime.minute));

                                if (time != null && time != _endTime) {
                                  setState(() {
                                    _endTime = time;
                                    final Duration difference =
                                        _endDate.difference(_startDate);
                                    _endDate = DateTime(
                                        _endDate.year,
                                        _endDate.month,
                                        _endDate.day,
                                        _endTime.hour,
                                        _endTime.minute,
                                        0);
                                    if (_endDate.isBefore(_startDate)) {
                                      _startDate =
                                          _endDate.subtract(difference);
                                      _startTime = TimeOfDay(
                                          hour: _startDate.hour,
                                          minute: _startDate.minute);
                                    }
                                  });
                                }
                              })),
                ])),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
          enabled: !_isAllDay,
          leading: Icon(
            Icons.public,
            color: defaultColor,
          ),
          title: Text(_selectedTimeZoneIndex == -1
              ? 'Default Time'
              : _timeZoneCollection[_selectedTimeZoneIndex]),
          onTap: () async {
            final int _selectedIndex = await showDialog<dynamic>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return _CalendarTimeZonePicker(
                  selectedTimeZoneIndex: _selectedTimeZoneIndex,
                  timeZoneCollection: _timeZoneCollection,
                );
              },
            );

            if (_selectedIndex != null) {
              setState(() {
                _selectedTimeZoneIndex = _selectedIndex;
              });
            }
          },
        ),
        const Divider(
          height: 1.0,
          thickness: 1,
        ),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
          leading: Icon(Icons.lens,
              color: _selectedColorIndex == -1
                  ? Colors.blue
                  : calendarData.fromHex((calendarData
                              .colors[_colorCollection[_selectedColorIndex]]
                          as googleAPI.ColorDefinition)
                      .background)),
          title: Text(_selectedColorIndex == -1
              ? _colorNames[_colorNames.length - 1]
              : _colorNames[_selectedColorIndex]),
          onTap: () async {
            final int _selectedIndex = await showDialog<dynamic>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return _CalendarColorPicker(
                  colorCollection: _colorCollection,
                  colorNames: _colorNames,
                  selectedColorIndex: _selectedColorIndex,
                );
              },
            );

            if (_selectedIndex != null) {
              setState(() {
                _selectedColorIndex = _selectedIndex;
              });
            }
          },
        ),
        const Divider(
          height: 1.0,
          thickness: 1,
        ),
        kIsWeb
            ? const Divider(
                height: 1.0,
                thickness: 1,
              )
            : Container(),
        ListTile(
          contentPadding: const EdgeInsets.all(5),
          leading: Icon(
            Icons.subject,
            color: defaultColor,
          ),
          title: TextField(
            controller: TextEditingController(text: _notes),
            onChanged: (String value) {
              _notes = value;
            },
            keyboardType: TextInputType.multiline,
            maxLines: kIsWeb ? 1 : null,
            style: TextStyle(
                fontSize: 18, color: defaultColor, fontWeight: FontWeight.w400),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Add description',
            ),
          ),
        ),
      ],
    ));
  }
}

class _CalendarColorPicker extends StatefulWidget {
  _CalendarColorPicker(
      {this.selectedColorIndex, this.colorCollection, this.colorNames});

  final int selectedColorIndex;
  final List<String> colorNames;
  final List<String> colorCollection;

  @override
  State<StatefulWidget> createState() {
    return _CalendarColorPickerState();
  }
}

class _CalendarColorPickerState extends State<_CalendarColorPicker> {
  int _selectedColorIndex;

  @override
  void initState() {
    _selectedColorIndex = widget.selectedColorIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          width: kIsWeb ? 500 : double.maxFinite,
          height: (calendarData.colors.length * 50).toDouble(),
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: calendarData.colors.length + 1,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Icon(
                    index == _selectedColorIndex ||
                            (index == calendarData.colors.length &&
                                _selectedColorIndex == -1)
                        ? Icons.lens
                        : Icons.trip_origin,
                    color: index >= calendarData.colors.length
                        ? Colors.blue
                        : calendarData.fromHex(
                            (calendarData.colors[widget.colorCollection[index]]
                                    as googleAPI.ColorDefinition)
                                .background)),
                title: Text(widget.colorNames[index]),
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                    if (index == calendarData.colors.length) {
                      _selectedColorIndex = -1;
                    }
                  });

                  Future.delayed(const Duration(milliseconds: 200), () {
                    // When task is over, close the dialog
                    Navigator.pop(context, _selectedColorIndex);
                  });
                },
              );
            },
          )),
    );
  }
}

class _CalendarTimeZonePicker extends StatefulWidget {
  const _CalendarTimeZonePicker(
      {this.timeZoneCollection, this.selectedTimeZoneIndex});

  final List<String> timeZoneCollection;
  final int selectedTimeZoneIndex;

  @override
  State<StatefulWidget> createState() {
    return _CalendarTimeZonePickerState();
  }
}

class _CalendarTimeZonePickerState extends State<_CalendarTimeZonePicker> {
  int _selectedTimeZoneIndex;

  @override
  void initState() {
    _selectedTimeZoneIndex = widget.selectedTimeZoneIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          width: kIsWeb ? 500 : double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: widget.timeZoneCollection.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Icon(
                  index == _selectedTimeZoneIndex
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                title: Text(widget.timeZoneCollection[index]),
                onTap: () {
                  setState(() {
                    _selectedTimeZoneIndex = index;
                  });

                  // ignore: always_specify_types
                  Future.delayed(const Duration(milliseconds: 200), () {
                    // When task is over, close the dialog
                    Navigator.pop(context, _selectedTimeZoneIndex);
                  });
                },
              );
            },
          )),
    );
  }
}
