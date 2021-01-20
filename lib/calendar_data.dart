import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import './client/google_browser_client.dart'
    if (dart.library.io) './client/google_io_client.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'database_helper.dart';
import 'main.dart';

class _LoadingStream {
  StreamController _indication = StreamController<bool>();

  StreamSink<bool> get send => _indication.sink;

  Stream<bool> get isLoading => _indication.stream;

  void closeStream() {
    _indication.close();
  }
}

class CalendarData {
  CalendarData() {
    loadFirebase();
  }

  void loadFirebase() async {
    _auth = auth.FirebaseAuth.instance;
  }

  final DatabaseHelper db =
      DatabaseHelper('calendarEvents', 'colors', 'settings');
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'https://www.googleapis.com/auth/calendar'],
  );
  auth.FirebaseAuth _auth;
  final _LoadingStream loadingStream = _LoadingStream();

  Map<String, dynamic> colors = Map<String, dynamic>();
  googleAPI.CalendarApi calendarAPI;
  GoogleSignInAccount googleUser;
  ValueNotifier<auth.FirebaseUser> currentUser =
      ValueNotifier<auth.FirebaseUser>(null);

  void closeStream() {
    loadingStream.closeStream();
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    final Color color = Color(int.parse(buffer.toString(), radix: 16));
    return color.withOpacity(1.0);
  }

  String getWeekDayString(DateTime date) {
    if (date == null) {
      return '';
    }

    final int _weekDay = date.weekday % 7;
    if (_weekDay == 0) {
      return 'SU';
    } else if (_weekDay == 1) {
      return 'MO';
    } else if (_weekDay == 2) {
      return 'TU';
    } else if (_weekDay == 3) {
      return 'WE';
    } else if (_weekDay == 4) {
      return 'TH';
    } else if (_weekDay == 5) {
      return 'FR';
    } else if (_weekDay == 6) {
      return 'SA';
    }

    return '';
  }

  String getTimeZone(String country) {
    if (country == null || country.isEmpty) {
      return null;
    }

    final Map<String, String> locationToTimeZone = <String, String>{};
    locationToTimeZone['Australia/Darwin'] = 'AUS Central Standard Time';
    locationToTimeZone['Australia/Sydney'] = 'AUS Eastern Standard Time';
    locationToTimeZone['Asia/Kabul'] = 'Afghanistan Standard Time';
    locationToTimeZone['America/Anchorage'] = 'Alaskan Standard Time';
    locationToTimeZone['Asia/Riyadh'] = 'Arab Standard Time';
    locationToTimeZone['Indian/Reunion'] = 'Arabian Standard Time';
    locationToTimeZone['Asia/Baghdad'] = 'Arabic Standard Time';
    locationToTimeZone['America/Argentina/Buenos_Aires'] =
        'Argentina Standard Time';
    locationToTimeZone['America/Halifax'] = 'Atlantic Standard Time';
    locationToTimeZone['Asia/Baku'] = 'Azerbaijan Standard Time';
    locationToTimeZone['Atlantic/Azores'] = 'Azores Standard Time';
    locationToTimeZone['America/Bahia'] = 'Bahia Standard Time';
    locationToTimeZone['Asia/Dhaka'] = 'Bangladesh Standard Time';
    locationToTimeZone['Europe/Minsk'] = 'Belarus Standard Time';
    locationToTimeZone['America/Regina'] = 'Canada Central Standard Time';
    locationToTimeZone['Atlantic/Cape_Verde'] = 'Cape Verde Standard Time';
    locationToTimeZone['Asia/Yerevan'] = 'Caucasus Standard Time';
    locationToTimeZone['Australia/Adelaide'] = 'Cen. Australia Standard Time';
    locationToTimeZone['America/Guatemala'] = 'Central America Standard Time';
    locationToTimeZone['Asia/Almaty'] = 'Central Asia Standard Time';
    locationToTimeZone['America/Cuiaba'] = 'Central Brazilian Standard Time';
    locationToTimeZone['Europe/Budapest'] = 'Central Europe Standard Time';
    locationToTimeZone['Europe/Warsaw'] = 'Central European Standard Time';
    locationToTimeZone['Pacific/Guadalcanal'] = 'Central Pacific Standard Time';
    locationToTimeZone['America/Chicago'] = 'Central Standard Time';
    locationToTimeZone['Asia/Shanghai'] = 'China Standard Time';
    locationToTimeZone['Etc/GMT+12'] = 'Dateline Standard Time';
    locationToTimeZone['Africa/Nairobi'] = 'E. Africa Standard Time';
    locationToTimeZone['Australia/Brisbane'] = 'E. Australia Standard Time';
    locationToTimeZone['America/Sao_Paulo'] = 'E. South America Standard Time';
    locationToTimeZone['America/New_York'] = 'Eastern Standard Time';
    locationToTimeZone['Africa/Cairo'] = 'Egypt Standard Time';
    locationToTimeZone['Asia/Yekaterinburg'] = 'Ekaterinburg Standard Time';
    locationToTimeZone['Europe/Kiev'] = 'FLE Standard Time';
    locationToTimeZone['Pacific/Fiji'] = 'Fiji Standard Time';
    locationToTimeZone['Europe/London'] = 'GMT Standard Time';
    locationToTimeZone['Europe/Bucharest'] = 'GTB Standard Time';
    locationToTimeZone['Asia/Tbilisi'] = 'Georgian Standard Time';
    locationToTimeZone['America/Godthab'] = 'Greenland Standard Time';
    locationToTimeZone['Atlantic/Reykjavik'] = 'Greenwich Standard Time';
    locationToTimeZone['Pacific/Honolulu'] = 'Hawaiian Standard Time';
    locationToTimeZone['Asia/Kolkata'] = 'India Standard Time';
    locationToTimeZone['Asia/Tehran'] = 'Iran Standard Time';
    locationToTimeZone['Asia/Jerusalem'] = 'Israel Standard Time';
    locationToTimeZone['Asia/Amman'] = 'Jordan Standard Time';
    locationToTimeZone['Europe/Kaliningrad'] = 'Kaliningrad Standard Time';
    locationToTimeZone['Asia/Seoul'] = 'Korea Standard Time';
    locationToTimeZone['Africa/Tripoli'] = 'Libya Standard Time';
    locationToTimeZone['Pacific/Kiritimati'] = 'Line Islands Standard Time';
    locationToTimeZone['Asia/Magadan'] = 'Magadan Standard Time';
    locationToTimeZone['Indian/Mauritius'] = 'Mauritius Standard Time';
    locationToTimeZone['Asia/Beirut'] = 'Middle East Standard Time';
    locationToTimeZone['America/Montevideo'] = 'Montevideo Standard Time';
    locationToTimeZone['Africa/Casablanca'] = 'Morocco Standard Time';
    locationToTimeZone['America/Denver'] = 'Mountain Standard Time';
    locationToTimeZone['America/Chihuahua'] = 'Mountain Standard Time (Mexico)';
    locationToTimeZone['Asia/Rangoon'] = 'Myanmar Standard Time';
    locationToTimeZone['Asia/Novosibirsk'] = 'N. Central Asia Standard Time';
    locationToTimeZone['Africa/Windhoek'] = 'Namibia Standard Time';
    locationToTimeZone['Asia/Kathmandu'] = 'Nepal Standard Time';
    locationToTimeZone['Pacific/Auckland'] = 'New Zealand Standard Time';
    locationToTimeZone['America/St_Johns'] = 'Newfoundland Standard Time';
    locationToTimeZone['Asia/Irkutsk'] = 'North Asia East Standard Time';
    locationToTimeZone['Asia/Krasnoyarsk'] = 'North Asia Standard Time';
    locationToTimeZone['America/Santiago'] = 'Pacific SA Standard Time';
    locationToTimeZone['America/Los_Angeles'] = 'Pacific Standard Time';
    locationToTimeZone['America/Santa_Isabel'] =
        'Pacific Standard Time (Mexico)';
    locationToTimeZone['Asia/Karachi'] = 'Pakistan Standard Time';
    locationToTimeZone['America/Asuncion'] = 'Paraguay Standard Time';
    locationToTimeZone['Europe/Paris'] = 'Romance Standard Time';
    locationToTimeZone['Asia/Srednekolymsk'] = 'Russia Time Zone 10';
    locationToTimeZone['Asia/Kamchatka'] = 'Russia Time Zone 11';
    locationToTimeZone['Europe/Samara'] = 'Russia Time Zone 3';
    locationToTimeZone['Europe/Moscow'] = 'Russian Standard Time';
    locationToTimeZone['America/Cayenne'] = 'SA Eastern Standard Time';
    locationToTimeZone['America/Bogota'] = 'SA Pacific Standard Time';
    locationToTimeZone['America/La_Paz'] = 'SA Western Standard Time';
    locationToTimeZone['Asia/Bangkok'] = 'SE Asia Standard Time';
    locationToTimeZone['Pacific/Apia'] = 'Samoa Standard Time';
    locationToTimeZone['Asia/Singapore'] = 'Singapore Standard Time';
    locationToTimeZone['Africa/Johannesburg'] = 'South Africa Standard Time';
    locationToTimeZone['Asia/Colombo'] = 'Sri Lanka Standard Time';
    locationToTimeZone['Asia/Damascus'] = 'Syria Standard Time';
    locationToTimeZone['Asia/Taipei'] = 'Taipei Standard Time';
    locationToTimeZone['Australia/Hobart'] = 'Tasmania Standard Time';
    locationToTimeZone['Asia/Tokyo'] = 'Tokyo Standard Time';
    locationToTimeZone['Pacific/Tongatapu'] = 'Tonga Standard Time';
    locationToTimeZone['Europe/Istanbul'] = 'Turkey Standard Time';
    locationToTimeZone['America/Indiana/Indianapolis'] =
        'US Eastern Standard Time';
    locationToTimeZone['America/Phoenix'] = 'US Mountain Standard Time';
    locationToTimeZone['America/Danmarkshavn'] = 'UTC';
    locationToTimeZone['Pacific/Tarawa'] = 'UTC+12';
    locationToTimeZone['America/Noronha'] = 'UTC-02';
    locationToTimeZone['Pacific/Midway'] = 'UTC-11';
    locationToTimeZone['Asia/Ulaanbaatar'] = 'Ulaanbaatar Standard Time';
    locationToTimeZone['America/Caracas'] = 'Venezuela Standard Time';
    locationToTimeZone['Asia/Vladivostok'] = 'Vladivostok Standard Time';
    locationToTimeZone['Australia/Perth'] = 'W. Australia Standard Time';
    locationToTimeZone['Africa/Lagos'] = 'W. Central Africa Standard Time';
    locationToTimeZone['Europe/Berlin'] = 'W. Europe Standard Time';
    locationToTimeZone['Asia/Tashkent'] = 'West Asia Standard Time';
    locationToTimeZone['Pacific/Port_Moresby'] = 'West Pacific Standard Time';
    locationToTimeZone['Asia/Yakutsk'] = 'Yakutsk Standard Time';

    if (locationToTimeZone.containsKey(country)) {
      return locationToTimeZone[country];
    }

    return null;
  }

  Future<bool> getConnectionStatus() async {
    if (kIsWeb) {
      return true;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }

      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  void deleteAppointment(
      GoogleDataSource dataSource, googleAPI.Event event) async {
    if (dataSource.appointments == null || dataSource.appointments.isEmpty) {
      return;
    }

    try {
      await calendarAPI.events.delete('primary', event.id);
    } catch (_) {
      print('Deletion failed');
      return;
    }

    dataSource.notifyListeners(
        CalendarDataSourceAction.remove, <googleAPI.Event>[event]);
    dataSource.appointments.removeAt(dataSource.appointments.indexOf(event));

    if (kIsWeb) {
      return;
    }
    db.deleteEntry(event.id, db.eventTableName);
  }

  void updateAppointment(
      GoogleDataSource dataSource, googleAPI.Event event) async {
    if (dataSource.appointments == null || dataSource.appointments.isEmpty) {
      return;
    }

    googleAPI.Event newEvent;
    try {
      newEvent = await calendarAPI.events.update(event, 'primary', event.id);
    } catch (_) {
      print('Updation failed');
      return;
    }

    dataSource.notifyListeners(
        CalendarDataSourceAction.remove, <googleAPI.Event>[event]);
    dataSource.appointments.removeAt(dataSource.appointments.indexOf(event));
    dataSource.appointments.add(newEvent);
    dataSource.notifyListeners(
        CalendarDataSourceAction.add, <googleAPI.Event>[newEvent]);
    if (kIsWeb) {
      return;
    }
    db.updateEntry(
        DatabaseEntry(id: newEvent.id, data: jsonEncode(newEvent.toJson())),
        db.eventTableName);
  }

  void addAppointment(
      GoogleDataSource dataSource, googleAPI.Event event) async {
    googleAPI.Event newEvent;
    try {
      newEvent = await calendarAPI.events.insert(event, 'primary');
    } catch (_) {
      print('Insertion failed');
      return;
    }

    dataSource.appointments.add(newEvent);
    dataSource.notifyListeners(
        CalendarDataSourceAction.add, <googleAPI.Event>[newEvent]);
    if (kIsWeb) {
      return;
    }
    db.addEntry(
        DatabaseEntry(id: newEvent.id, data: jsonEncode(newEvent.toJson())),
        db.eventTableName);
  }

  Future<void> handleSignIn(GoogleDataSource dataSource, BuildContext context,
      VoidCallback updateCalendarUI) async {
    final bool _connectionStatus = await getConnectionStatus();
    if (!_connectionStatus) {
      return;
    }

    try {
      googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.AuthCredential credential =
          auth.GoogleAuthProvider.getCredential(
              accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final auth.FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      currentUser.value = await _auth.currentUser();
      if (currentUser.value.uid != user.uid) {
        return;
      }

      await handleOnlineEvents(dataSource, updateCalendarUI);
    } catch (_) {
      print('Sign in failed');
    }
  }

  Future<void> updateSettingFromDB(VoidCallback updateCalendarUI) async {
    if (kIsWeb) {
      currentUser.value = await _auth.currentUser();
      if (currentUser.value != null) {
        googleUser ??= await _googleSignIn.signInSilently();
      }

      await _initializeSettings(updateCalendarUI);
      return;
    }
    try {
      User user = User.fromData(
          jsonDecode((await db.getEntry(db.settingsTableName)).first.data));
      if (user != null) {
        firstDayOfWeek = user.firstDayOfWeek;
        eventDuration = user.eventDuration;
        showArrows = user.showNavigationArrow;
        startHour = user.startTime;
        endHour = user.endTime;
      }
    } catch (_) {
      firstDayOfWeek = 7;
      eventDuration = 60;
      startHour = 0.0;
      endHour = 24.0;
      showArrows = false;
    }

    if (updateCalendarUI == null) {
      return;
    }
    updateCalendarUI();
  }

  void refresh(
      GoogleDataSource dataSource, VoidCallback updateCalendarUI) async {
    if (kIsWeb) {
      loadingStream.send.add(true);
      currentUser.value = await _auth.currentUser();
      if (currentUser.value != null) {
        googleUser ??= await _googleSignIn.signInSilently();
        await handleOnlineEvents(dataSource, updateCalendarUI);
      }
      loadingStream.send.add(false);
    } else {
      updateSettingFromDB(updateCalendarUI);
      loadExistingAppointments(dataSource, updateCalendarUI);
    }
  }

  Future<void> handleOnlineEvents(
      GoogleDataSource dataSource, VoidCallback updateCalendarUI) async {
    final GoogleAPIClient httpClient =
        GoogleAPIClient(await googleUser.authHeaders);
    calendarAPI = googleAPI.CalendarApi(httpClient);

    var color = calendarAPI.colors;
    colors = (await color.get()).event;
    _initializeSettings(updateCalendarUI);
    if (!kIsWeb) {
      await db.removeTable(db.colorTableName);
      await db.removeTable(db.eventTableName);
      await db.removeTable(db.settingsTableName);
      List<String> keys = colors.keys.toList();
      for (int i = 0; i < keys.length; i++) {
        var key = keys[i];
        db.addEntry(
            DatabaseEntry(id: key, data: jsonEncode(colors[key].toJson())),
            db.colorTableName);
      }

      final User user = User(
          email: googleUser.email,
          firstDayOfWeek: firstDayOfWeek,
          eventDuration: eventDuration,
          startTime: startHour,
          endTime: endHour,
          showNavigationArrow: showArrows);
      db.addEntry(
          DatabaseEntry(id: user.email, data: jsonEncode(user.toJson())),
          db.settingsTableName);
    }

    googleAPI.Events calEvents = await calendarAPI.events.list(
      "primary",
    );

    List<googleAPI.Event> appointments = <googleAPI.Event>[];
    while (true) {
      if (calEvents != null && calEvents.items != null) {
        for (int i = 0; i < calEvents.items.length; i++) {
          final googleAPI.Event event = calEvents.items[i];
          if (event.start == null) {
            continue;
          }

          final String data = jsonEncode(event.toJson());
          appointments.add(event);
          if (kIsWeb) {
            continue;
          }
          db.addEntry(
              DatabaseEntry(id: event.id, data: data), db.eventTableName);
        }
      }

      if (calEvents.nextPageToken != null) {
        calEvents = await calendarAPI.events
            .list("primary", pageToken: calEvents.nextPageToken);
      } else {
        break;
      }
    }

    dataSource.appointments = appointments;
    dataSource.notifyListeners(CalendarDataSourceAction.reset, appointments);
  }

  Future<void> signOut(
      GoogleDataSource dataSource, VoidCallback updateCalendarUI) async {
    try {
      final bool _connectionStatus = await getConnectionStatus();
      if (!_connectionStatus) {
        return;
      }

      if (_googleSignIn.currentUser == null && currentUser.value != null) {
        await _googleSignIn.signInSilently();
      }

      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
        await _auth.signOut();
        currentUser.value = null;
        googleUser = null;
        if (!kIsWeb) {
          await db.removeTable(db.colorTableName);
          await db.removeTable(db.eventTableName);
        }

        dataSource.appointments = <googleAPI.Event>[];
        dataSource.notifyListeners(
            CalendarDataSourceAction.reset, <googleAPI.Event>[]);
      }
    } catch (_) {
      print('Sign out failed');
    }
  }

  void loadExistingAppointments(
      GoogleDataSource dataSource, VoidCallback updateCalendarUI) async {
    loadingStream.send.add(true);
    try {
      currentUser.value = await _auth.currentUser();
      final bool _connectionStatus = await getConnectionStatus();
      if (!_connectionStatus && currentUser == null) {
        dataSource.appointments = <googleAPI.Event>[];
        dataSource.notifyListeners(
            CalendarDataSourceAction.reset, <googleAPI.Event>[]);
      } else if (!_connectionStatus && currentUser.value != null) {
        List<DatabaseEntry> colorEntry = await db.getEntry(db.colorTableName);
        if (colorEntry != null && colors.length == 0) {
          for (int i = 0; i < colorEntry.length; i++) {
            colors[colorEntry[i].id] = googleAPI.ColorDefinition.fromJson(
                jsonDecode(colorEntry[i].data));
          }
        }

        List<googleAPI.Event> appointments = <googleAPI.Event>[];
        List<DatabaseEntry> dataEntry = await db.getEntry(db.eventTableName);
        for (int i = 0; i < dataEntry.length; i++) {
          appointments.add(googleAPI.Event.fromJson(
              jsonDecode(dataEntry[i].data) as Map<String, dynamic>));
        }

        dataSource.appointments = appointments;
        dataSource.notifyListeners(
            CalendarDataSourceAction.reset, appointments);
      } else if (_connectionStatus && currentUser.value != null) {
        List<DatabaseEntry> colorEntry = await db.getEntry(db.colorTableName);
        if (colors.length == 0) {
          for (int i = 0; i < colorEntry.length; i++) {
            colors[colorEntry[i].id] = googleAPI.ColorDefinition.fromJson(
                jsonDecode(colorEntry[i].data));
          }
        }

        googleUser ??= await _googleSignIn.signInSilently();
        await handleOnlineEvents(dataSource, updateCalendarUI);
      }
    } catch (_) {
      print('Events loading failed');
    }
    loadingStream.send.add(false);
  }

  Future<void> _initializeSettings(VoidCallback updateCalendarUI) async {
    if (googleUser == null) {
      return;
    }

    await getFirebaseData();
    if (updateCalendarUI == null) {
      return;
    }
    updateCalendarUI();
  }

  Future<void> getFirebaseData() async {
    User user;
    try {
      final firestore.CollectionReference settings =
          firestore.Firestore.instance.collection('settings');
      await settings
          .where('email', isEqualTo: googleUser.email)
          .getDocuments()
          .then((querySnapshot) {
        if (querySnapshot.documents.isNotEmpty) {
          var data = querySnapshot.documents[0];
          user = User(
              email: data['email'],
              firstDayOfWeek: data['firstDayOfWeek'],
              eventDuration: data['eventDuration'],
              startTime: data['startTime'].toDouble(),
              endTime: data['endTime'].toDouble(),
              showNavigationArrow: data['showNavigationArrow']);
        }
      });

      if (user == null) {
        user = User(
            email: googleUser.email,
            firstDayOfWeek: firstDayOfWeek,
            eventDuration: eventDuration,
            startTime: startHour,
            endTime: endHour,
            showNavigationArrow: showArrows);
        await settings.add(user.toJson());
      }
    } catch (_) {
      print('Setting fetch failed');
    }

    if (user != null) {
      firstDayOfWeek = user.firstDayOfWeek;
      eventDuration = user.eventDuration;
      showArrows = user.showNavigationArrow;
      startHour = user.startTime;
      endHour = user.endTime;
    }
  }

  void updateFirebaseData() async {
    if (googleUser == null) {
      if (kIsWeb) {
        return;
      }
      await db.removeTable(db.settingsTableName);
      final User user = User(
          email: 'setting',
          firstDayOfWeek: firstDayOfWeek,
          eventDuration: eventDuration,
          startTime: startHour,
          endTime: endHour,
          showNavigationArrow: showArrows);

      db.addEntry(
          DatabaseEntry(id: user.email, data: jsonEncode(user.toJson())),
          db.settingsTableName);
      return;
    }

    try {
      User user;
      final firestore.CollectionReference settings =
          firestore.Firestore.instance.collection('settings');
      await settings
          .where('email', isEqualTo: googleUser.email)
          .getDocuments()
          .then((querySnapshot) {
        if (querySnapshot.documents.isNotEmpty) {
          var data = querySnapshot.documents[0];
          user = User(
              email: googleUser.email,
              firstDayOfWeek: firstDayOfWeek,
              eventDuration: eventDuration,
              startTime: startHour,
              endTime: endHour,
              showNavigationArrow: showArrows);
          settings.document(data.documentID).updateData(user.toJson());
        }
      });

      if (user == null) {
        user = User(
            email: googleUser.email,
            firstDayOfWeek: firstDayOfWeek,
            eventDuration: eventDuration,
            startTime: startHour,
            endTime: endHour,
            showNavigationArrow: showArrows);
        await settings.add(user.toJson());
      }

      if (kIsWeb) {
        return;
      }

      await db.removeTable(db.settingsTableName);
      db.addEntry(
          DatabaseEntry(id: user.email, data: jsonEncode(user.toJson())),
          db.settingsTableName);
    } catch (_) {
      print('Setting updation failed');
    }
  }
}

class User {
  final String email;
  final int firstDayOfWeek;
  final int eventDuration;
  final double startTime;
  final double endTime;
  final bool showNavigationArrow;

  User(
      {this.email,
      int firstDayOfWeek,
      int eventDuration,
      double startTime,
      double endTime,
      bool showNavigationArrow})
      : firstDayOfWeek = firstDayOfWeek ?? 7,
        eventDuration = eventDuration ?? 60,
        startTime = startTime ?? 0.0,
        endTime = endTime ?? 24.0,
        showNavigationArrow = showNavigationArrow ?? false;

  User.fromData(Map<dynamic, dynamic> data)
      : email = data['email'],
        firstDayOfWeek = data['firstDayOfWeek'],
        eventDuration = data['eventDuration'],
        startTime = data['startTime'].toDouble(),
        endTime = data['endTime'].toDouble(),
        showNavigationArrow = data['showNavigationArrow'];

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstDayOfWeek': firstDayOfWeek,
      'eventDuration': eventDuration,
      'startTime': startTime,
      'endTime': endTime,
      'showNavigationArrow': showNavigationArrow,
    };
  }
}
