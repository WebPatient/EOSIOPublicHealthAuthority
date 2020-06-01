import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exposure_notifications/flutter_exposure_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
void main() {
  runApp(MyApp());
}

///
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

///
class Choice {
  const Choice({this.id, this.title, this.icon});

  final int id;
  final String title;
  final IconData icon;
}

const List<Choice> currentTab = const <Choice>[
  const Choice(id: 0, title: 'Exposures', icon: Icons.notification_important),
  const Choice(id: 1, title: 'Notify others', icon: Icons.flag),
  const Choice(id: 2, title: 'Debug', icon: Icons.settings_applications),
];

String isTransmissionSupported;
bool ExposureNotificationsON = false;
int RecentExposures = 0;
FlutterExposureNotifications notifications;
String beaconScanResults;

String notify_other_button_label = "NOTIFY OTHERS";
String debug_uuid = "UUID: ";
int totalUUIDsFound;

class ChoiceCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      ChoiceCardState(key: key, choice: choice, startTimer: startTimer);

  const ChoiceCard({Key key, this.choice, this.startTimer}) : super(key: key);

  final Choice choice;
  final Function startTimer;
}

Timer _timer;
int _start = 15;

class ChoiceCardState extends State<ChoiceCard> {
  final Choice choice;

  final Function startTimer;

  ChoiceCardState({Key key, @required this.choice, this.startTimer});

  @override
  void initState() {
    print("initState...");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialButton turnOnButton = MaterialButton(
        disabledColor: Colors.deepPurple[50],
        onPressed: (notifications.isTransmissionSupported
                    .toString()
                    .compareTo("BeaconStatus.SUPPORTED") !=
                0)
            ? null
            : () {
                turnOn();
              },
        child: Text("TURN ON EXPOSURE NOTIFICATIONS",
            style: TextStyle(color: Colors.white)),
        color: Colors.deepPurple);

    final MaterialButton turnOffButton = MaterialButton(
        onPressed: () {
          turnOff();
        },
        child: Text("TURN OFF EXPOSURE NOTIFICATIONS",
            style: TextStyle(color: Colors.white)),
        color: Colors.deepPurple);

    final MaterialButton notifyOthers = MaterialButton(
        onPressed: () {
          if (!notifications.notifying) {
            notify();
          }
        },
        child: Text(notify_other_button_label,
            style: TextStyle(color: Colors.white)),
        color: Colors.deepPurple);

    final TextStyle textStyle = Theme.of(context).textTheme.headline6;
    final TextStyle textStyle2 = Theme.of(context).textTheme.subtitle2;
    Center currentCard;

    var on = Column(children: <Widget>[
      Text("Exposure notifications are turned:", style: textStyle),
      Text("ON",
          style: TextStyle(color: Colors.green, fontSize: textStyle.fontSize)),
    ]);

    var off = Column(children: <Widget>[
      Text("Exposure notifications are turned:", style: textStyle),
      Text("OFF",
          style:
              TextStyle(color: Colors.redAccent, fontSize: textStyle.fontSize)),
    ]);

    switch (choice.id) {
      case 0:
        {
          var RecentExposuresList = List<Widget>();

          if (RecentExposures > 0) {
            for (var i = 0; i < RecentExposures; i++) {
              RecentExposuresList.add(Row(children: <Widget>[
                Text("Exposure #$i: ", style: textStyle2),
                MaterialButton(
                  onPressed: () {
                    FlutterExposureNotifications.showContactInfo(i);
                  },
                  child: Text("Details", style: TextStyle(color: Colors.white)),
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                )
              ]));
            }
          } else {
            RecentExposuresList.add(Text(
              "No recent exposures",
              style: textStyle2,
            ));
          }

          currentCard = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: const EdgeInsets.all(4.0)),
                Text(choice.title, style: textStyle),
                Padding(padding: const EdgeInsets.all(4.0)),
                (ExposureNotificationsON) ? on : off,
                Padding(padding: const EdgeInsets.all(4.0)),
                (ExposureNotificationsON) ? turnOffButton : turnOnButton,
                (notifications.isTransmissionSupported
                            .toString()
                            .compareTo("BeaconStatus.SUPPORTED") !=
                        0)
                    ? Text(
                        "Device's Bluetooth chipset or driver doesn't support transmitting",
                        style: textStyle2)
                    : Container(),
                Padding(padding: const EdgeInsets.all(4.0)),
                Divider(color: Colors.deepPurple, thickness: 1.2),
                Padding(padding: const EdgeInsets.all(4.0)),
                Text("EXPOSURES IN PAST 14 DAYS", style: textStyle),
                Padding(padding: const EdgeInsets.all(4.0)),
                Column(children: RecentExposuresList),
                Padding(padding: const EdgeInsets.all(4.0)),
                Divider(color: Colors.deepPurple, thickness: 1.2),
                Padding(padding: const EdgeInsets.all(4.0)),
                Row(children: <Widget>[
                  Padding(padding: const EdgeInsets.all(4.0)),
                  Icon(Icons.info_outline, color: textStyle.color),
                  Padding(padding: const EdgeInsets.all(4.0)),
                  Flexible(
                      flex: 2,
                      child: Text(
                          "You will be notified if you have been exposed to someone who reported a positive COVID-19 result",
                          style: textStyle2))
                ]),
                Padding(padding: const EdgeInsets.all(16.0)),
              ],
            ),
          );
        }
        break;
      case 1:
        {
          currentCard = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: const EdgeInsets.all(4.0)),
                Text(choice.title, style: textStyle),
                Padding(padding: const EdgeInsets.all(4.0)),
                (ExposureNotificationsON) ? on : off,
                Padding(padding: const EdgeInsets.all(4.0)),
                (ExposureNotificationsON) ? turnOffButton : turnOnButton,
                Padding(padding: const EdgeInsets.all(4.0)),
                Divider(color: Colors.deepPurple, thickness: 1.2),
                Padding(padding: const EdgeInsets.all(4.0)),
                Text(
                    "If you think you have been exposed to COVID‑19 and develop a fever and symptoms, such as cough or difficulty breathing, call your healthcare provider for medical advice.\n\n"
                    "If you have been diagnosed with COVID‑19 please notify others.",
                    style: textStyle2),
                Padding(padding: const EdgeInsets.all(4.0)),
                notifyOthers,
                Padding(padding: const EdgeInsets.all(4.0)),
                Text("Generated notifications: $totalUUIDsFound",
                    style: textStyle2),
                Padding(padding: const EdgeInsets.all(4.0)),
                (notifications.isTransmissionSupported
                            .toString()
                            .compareTo("BeaconStatus.SUPPORTED") !=
                        0)
                    ? Text(
                        "Device's Bluetooth chipset or driver doesn't support transmitting",
                        style: textStyle2)
                    : Container(),
                Padding(padding: const EdgeInsets.all(16.0)),
              ],
            ),
          );
        }
        break;
      case 2:
        {
          currentCard = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: const EdgeInsets.all(4.0)),
                Text(choice.title, style: textStyle),
                Padding(padding: const EdgeInsets.all(4.0)),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Exposure Notifications API Master",
                          style: textStyle),
                      Switch(
                        value: ExposureNotificationsON,
                        onChanged: (value) {
                          if (ExposureNotificationsON) {
                            _timer.cancel();
                            notifications.turnOffExposureNotifications();
                          } else {
                            turnOn();
                          }
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red,
                      ),
                      (ExposureNotificationsON)
                          ? Text(" ON",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: textStyle.fontSize))
                          : Text(" OFF",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: textStyle.fontSize)),
                      Padding(padding: const EdgeInsets.all(4.0)),
                      (debug_uuid.compareTo("UUID: ") == 0)
                          ? Text(debug_uuid, style: textStyle2)
                          : Text(
                              '${debug_uuid}\nRefreshing in $_start minutes...',
                              style: textStyle2),
                    ]),
                Padding(padding: const EdgeInsets.all(4.0)),
                Text("Bluetooth status", style: textStyle),
                Text("${isTransmissionSupported}", style: textStyle),
                Padding(padding: const EdgeInsets.all(4.0)),
/*
                Divider(color: Colors.deepPurple, thickness: 1.2),
                Padding(padding: const EdgeInsets.all(4.0)),
                MaterialButton(
                    onPressed: () {
                      notifications
                          .scanBeacons(); // 101@flutter_exposure_notifications
                      // TODO: HERE!
                    },
                    child: Text("SCAN BEACONS",
                        style: TextStyle(color: Colors.white)),
                    color: Colors.deepPurple),
                Padding(padding: const EdgeInsets.all(8.0)),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Flexible(
                      flex: 1,
                      child: Text("${beaconScanResults}", style: textStyle))
                ]),
                Padding(padding: const EdgeInsets.all(4.0)),
                Divider(color: Colors.deepPurple, thickness: 1.2),
                Padding(padding: const EdgeInsets.all(4.0)),
                Text("TEST EXPOSURE NOTIFICATION", style: textStyle),
                Padding(padding: const EdgeInsets.all(4.0)),
                Text(
                    "This will notify the app that you have been exposed so you can see the exposure experience in the app UI until you reset.",
                    style: textStyle2),
                Padding(padding: const EdgeInsets.all(4.0)),
                MaterialButton(
                    onPressed: () {
                      FlutterExposureNotifications.showAlertDialog;
                    },
                    child: Text("ADD TEST EXPOSURES",
                        style: TextStyle(color: Colors.white)),
                    color: Colors.deepPurple),
                Padding(padding: const EdgeInsets.all(8.0)),
                MaterialButton(
                    onPressed: () {
                      FlutterExposureNotifications.showAlertDialog;
                    },
                    child: Text("RESET EXPOSURES",
                        style: TextStyle(color: Colors.white)),
                    color: Colors.deepPurple),
                Padding(padding: const EdgeInsets.all(4.0)),
                Divider(color: Colors.deepPurple, thickness: 1.2),
                Padding(padding: const EdgeInsets.all(4.0)),
                Text("DIAGNOSIS KEYS", style: textStyle),
                Padding(padding: const EdgeInsets.all(4.0)),
                Text(
                    "This will enqueue a background job to provide diagnosis keys into the exposure notifications API.",
                    style: textStyle2),
                Padding(padding: const EdgeInsets.all(4.0)),
                MaterialButton(
                    onPressed: () {
                      FlutterExposureNotifications.showAlertDialog;
                    },
                    child: Text("PROVIDE DIAGNOSIS KEYS",
                        style: TextStyle(color: Colors.white)),
                    color: Colors.deepPurple),
                Padding(padding: const EdgeInsets.all(16.0)),
  */
              ],
            ),
          );
        }
        break;
    }

    if (currentCard != null) {
      return currentCard;
    } else {
      return Container();
    }
  }

  final _formKey = GlobalKey<FormState>();
  final myKeyController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myKeyController.dispose();
    super.dispose();
  }

  Future<void> notify() async {
    String privateEOSOwner;
    String privateEOSActive;
    String mainAccount;

    await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(controller: myKeyController,
                          validator: (value) {
                          if (value.isEmpty) {
                            return 'Please type:\nOwner Private Key/\nActive Private Key/\nAccount name';
                          }
                          return null;
                        },),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Text("Submitß"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              var keys = myKeyController.text.split("/");

                              if (keys.length == 3) {
                                print("owner: ${keys[0]}");
                                print("active: ${keys[1]}");
                                print("account: ${keys[2]}");

                                privateEOSOwner = keys[0];
                                privateEOSActive = keys[1];
                                mainAccount = keys[2];

                                if (privateEOSOwner == null ||
                                    privateEOSOwner.length == 0 ||
                                    privateEOSActive == null ||
                                    privateEOSActive.length == 0 ||
                                    mainAccount == null ||
                                    mainAccount.length == 0) {
                                  print("ERROR");
                                }
                                else {
                                  Navigator.of(context).pop();
                                }
                              }
                              else {
                                Fluttertoast.showToast(
                                    msg: "Invalid format",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                );
                              }

                            }
                            else {
                              print("invalid");
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });

    if (privateEOSOwner == null || privateEOSOwner.length == 0 || privateEOSActive == null || privateEOSActive.length == 0 || mainAccount == null || mainAccount.length == 0) {
      return;
    }

    if (_timer != null) {
      _timer.cancel();
    }
    await notifications.notifyOthers(
        privateEOSOwner, privateEOSActive, mainAccount);
    startTimer();
  }

  Future<void> turnOff() async {
    if (_timer != null) {
      _timer.cancel();
    }
    await notifications.turnOffExposureNotifications();
  }

  Future<void> turnOn() async {
    startTimer();
    await notifications.turnOnExposureNotifications();
  }
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final navigatorKey = GlobalKey<NavigatorState>();

  ///
  void startTimer() {
    const aMinute = Duration(minutes: 1); // X _start = 15 minutes
//    const aMinute = Duration(seconds: 1); // X _start = 15 secs
    _timer = Timer.periodic(
      aMinute,
      (timer) => setState(
        () {
          if (_start < 1) {
//            timer.cancel();
            try {
              notifications.turnOffExposureNotifications();
            } catch (e) {}
            print("refreshing...");
            _start = 15;
            notifications.turnOnExposureNotifications();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  void refresh() {
    setState(() {
      switch (notifications.isTransmissionSupported.toString()) {
        case "BeaconStatus.SUPPORTED":
          isTransmissionSupported = "Device supports transmitting as a beacon";
          break;
        case "BeaconStatus.NOT_SUPPORTED_MIN_SDK":
          isTransmissionSupported =
              "Android system version on the device is too low (min. is 21)";
          break;
        case "BeaconStatus.NOT_SUPPORTED_BLE":
          isTransmissionSupported =
              "Device doesn't support Bluetooth Low Energy";
          break;
        case "BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER":
          isTransmissionSupported =
              "Device's Bluetooth chipset or driver doesn't support transmitting";
          break;
      }

      ExposureNotificationsON = notifications.isAdvertising;
      beaconScanResults = notifications.scanResult;
      notify_other_button_label = notifications.notify_other_button_label;
      totalUUIDsFound = notifications.totalUUIDsFound;
      debug_uuid = notifications.debug_uuid;
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      print("disposing...");
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    notifications = FlutterExposureNotifications(navigatorKey, refresh);

//    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EOSIO Public Health Authority',
      color: Colors.deepPurple,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: currentTab.length,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: const Text('EOSIO Public Health Authority'),
            bottom: TabBar(
              indicatorColor: Colors.deepPurple,
              isScrollable: true,
              tabs: currentTab.map((choice) {
                return Tab(
                  text: choice.title.toUpperCase(),
                  icon: Icon(choice.icon),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            children: currentTab.map((choice) {
              return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ListView(children: <Widget>[
                    ChoiceCard(
                      choice: choice,
                      startTimer: startTimer,
                    )
                  ]));
            }).toList(),
          ),
        ),
      ),

      // add home here
//      Scaffold(
//        appBar: AppBar(
//          title: const Text('Plugin example app'),
//        ),
//        body: Center(
//          child: Column(children: <Widget>[
//            Text('Running on: $_platformVersion\n'),
//            MaterialButton(
//              onPressed: (){
//                FlutterExposureNotifications.showAlertDialog;
//              },
//              child: Text("Show Native Alert", style: TextStyle(color: Colors.white)),
//              color: Colors.blue),
//            MaterialButton(
//                onPressed: (){
//                  showDialog<String>(
//                    context: navigatorKey.currentState.overlay.context,
//                    builder: (BuildContext context) {
//                      return AlertDialog(
//                        title: Text("Dialog: AlertDialog(flutter)"),
//                        content: Text("AlertDialog in flutter"),
//                        actions: [
//                          FlatButton(
//                            child: Text("OK"),
//                            onPressed: () {
//                              Navigator.of(context).pop();
//                            },
//                          ),
//                        ],
//                      );
//                    },
//                  );
//
//                  },
//                child: Text("Show Flutter Alert", style: TextStyle(color: Colors.white)),
//                color: Colors.blue)
//
//          ]),
//        ),
//      ),
    );
  }
}
