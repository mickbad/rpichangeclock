import 'dart:io';

import 'package:intl/intl.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isChangeDateTime = false;
  bool isResetNTPService = false;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  void onDateChanged(DateTime newDate) {
    // sauvegarde de la nouvelle date avec détection du changement utilisateur depuis la dernière sauvegarde
    setState(() {
      isChangeDateTime = false;
      if (_date.compareTo(newDate) != 0) {
        isChangeDateTime = true;
        _date = newDate;
      }
    });
  }

  void onTimeChanged(TimeOfDay newTime) {
    // mise en place du nouveau temps
    setState(() {
      _time = newTime;
    });

    // mise en place de la nouvelle date (détection si changement utilisateur depuis la dernière sauvegarde)
    DateTime newDate = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute, _date.second, _date.millisecond, _date.microsecond);
    onDateChanged(newDate);

    // activation pour linux de la nouvelle date
    List<List<String>> cmds = [];
    String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(_date);
    cmds.add(["date"]);
    if (Platform.isLinux || Platform.isMacOS) {
      /* Python
      subprocess.call(shlex.split("timedatectl set-ntp false"))  # May be necessary
      subprocess.call(shlex.split("sudo date -s 'YYYY-MM-DD HH:MM:SS'"))
      subprocess.call(shlex.split("sudo hwclock -w"))
       */
      if (isResetNTPService) {
        cmds.add(["sudo", "timedatectl", "set-ntp", "false"]);
      }
      cmds.add(["sudo", "date", "-s", formattedDate]);
      cmds.add(["sudo", "hwclock", "-w"]);
      cmds.add(["date"]);
      if (isResetNTPService) {
        cmds.add(["sudo", "timedatectl", "set-ntp", "true"]);
      }
    }

    // exécution des commandes demandées
    executeCommands(cmds);
  }

  Future<void> executeCommands(List<List<String>> commands) async {
    // exécution du code système
    String output = "";

    // détermination si on doit exécuter les commandes
    if (isChangeDateTime) {
      for (List<String> command in commands) {
        // pour l'affichage debug utilisateur
        var l = command.join(" ");
        output += "\n\$> $l\n";

        // exécution de la commande externe
        try {
          var process = await Process.run(command[0], command.sublist(1));
          // print("returns: ${process.stdout}\n");
          output += "${process.stdout}";
        } catch (e) {
          output += "$e\n";
        }
      }
    } // fin si : exécution des commandes

    // pas de commande exécutée
    if (output.isEmpty) {
      output = "no change detected,\nso no command executed!";
    }

    // affichage d'un message utilisateur de l'action menée
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Output commands'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(output),
          ],
        ),
        scrollable: true,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Set Picker Date",
                  style: Theme.of(context).textTheme.headline6,
                ),
                TextButton(
                    onPressed: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          //minTime: DateTime(2022, 1, 1),
                          theme: const DatePickerTheme(
                              headerColor: Colors.orange,
                              backgroundColor: Colors.blue,
                              itemStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
                          onConfirm: (date) => onDateChanged(date),
                          currentTime: DateTime.now(),
                          locale: LocaleType.fr,
                      );
                    },
                    child: const Text(
                      'Select your current date (use mouse wheel)',
                      style: TextStyle(color: Colors.blue),
                    )
                ),

                const SizedBox(height: 10),

                Text(
                  "Set Picker Time",
                  style: Theme.of(context).textTheme.headline6,
                ),
                // Render inline widget
                createInlinePicker(
                  elevation: 1,
                  value: _time,
                  onChange: onTimeChanged,
                  minuteInterval: MinuteInterval.ONE,
                  iosStylePicker: false,
                  minHour: 0,
                  maxHour: 23,
                  is24HrFormat: true,
                  borderRadius: 30,
                ),

                Text(
                  "Temporary stop NTP Service",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Switch(
                  value: isResetNTPService,
                  onChanged: (newVal) {
                    setState(() {
                      isResetNTPService = newVal;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
