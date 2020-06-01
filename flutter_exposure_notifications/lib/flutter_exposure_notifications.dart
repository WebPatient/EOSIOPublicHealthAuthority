import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

import 'package:uuid/uuid.dart';
import 'package:eosdart/eosdart.dart' as eos;
import 'package:eosdart_ecc/eosdart_ecc.dart';

import 'package:flutter_exposure_notifications/database.dart';
import 'package:flutter_exposure_notifications/uuid.dart' as eosUUID;
import 'package:flutter_exposure_notifications/uuid_dao.dart';

///
class FlutterExposureNotifications {
  final Function() notifyParent;
  final GlobalKey<NavigatorState> navigatorKey;
  static const MAJOR_ID = 1;
  static const MINOR_ID = 1;
  static const TRANSMISSION_POWER = -59;
  static const IDENTIFIER = 'org.webpatient.exponot';
  static const LAYOUT = "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25";

  static const MANUFACTURER_ID = 0x0118;
  var beaconBroadcast = BeaconBroadcast();

  eos.EOSClient client;
  eos.EOSClient clientTest;

  BeaconStatus isTransmissionSupported;
  var isAdvertising = false;
  StreamSubscription<bool> isAdvertisingSubscription;
  String scanResult = "Beacons: Please Press 'Scan Beacons'";

  AppDatabase database;
  UuidDao uuidDao;

  StreamSubscription uuidStreamSubscription;

  int totalUUIDsFound;

  List<eosUUID.Uuid> uuidList;

  bool notifying = false;

  ///
  void onUUIDsData(List<eosUUID.Uuid> _uuidList) {
    totalUUIDsFound = _uuidList.length;
    uuidList = _uuidList;
    if (notifying) {
      notify_other_button_label = "NOTIFYING OTHERS (${totalUUIDsFound})...";
    } else {
      notify_other_button_label = "NOTIFY OTHERS (${totalUUIDsFound})";
    }
    notifyParent();
  }

  Future<void> setDatabase() async {
    await $FloorAppDatabase
        .databaseBuilder('flutter_database.db')
        .build()
        .then((_database) {
      print("database found");
      database = _database;
      uuidDao = database.uuidDao;
      uuidStreamSubscription =
          uuidDao.findAllUuidsAsStream().listen(onUUIDsData);
    });
  }

  @override
  void dispose() {
    if (uuidStreamSubscription != null) {
      uuidStreamSubscription.cancel();
    }
  }

  ///
  FlutterExposureNotifications(this.navigatorKey, this.notifyParent) {
    print("FlutterExposureNotifications()");
    setDatabase();

    beaconBroadcast.checkTransmissionSupported().then((transmissionSupported) {
      isTransmissionSupported = transmissionSupported;
      notifyParent();
      if (isTransmissionSupported != null &&
          isTransmissionSupported
                  .toString()
                  .compareTo("BeaconStatus.SUPPORTED") !=
              0) {
        showDialog<String>(
          context: navigatorKey.currentState.overlay.context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Bluetooth settings"),
              content: Text(
                  "Beacon status: ${isTransmissionSupported} \nBeacon running: ${isAdvertising}"),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });

    isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((advertising) {
      isAdvertising = advertising;
      notifyParent();
    });
  }

  static const MethodChannel _channel =
      const MethodChannel('flutter_exposure_notifications');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void get showAlertDialog async {
    final String version = await _channel.invokeMethod('showAlertDialog');
  }

  static void showContactInfo(int contactID) async {
    String _void =
        await _channel.invokeMethod('showContactInfo', <String, dynamic>{
      'contactID': contactID,
    });
  }

  ///
  void scanBeacons() async {
//    scanResult = await beaconBroadcast.scan();
//    notifyParent();
  }

  ///  Generate unique identifier
  String generateUUID() {
    var uuidAsStringList = Uuid().v4().split("-");

    // Patch UUID with 0xfd6f per https://blog.google/documents/58/Contact_Tracing_-_Bluetooth_Specification_v1.1_RYGZbKW.pdf
    var ret =
        "${uuidAsStringList[0].substring(0, 4)}fd6f-${uuidAsStringList[1]}-fd6f-${uuidAsStringList[3]}-${uuidAsStringList[4]}";

    print("UUID: $ret");
    return ret;
  }

  ///
  String newAccountName;

  ///
  String uuid, seed;

  ///
  String notify_other_button_label = "NOTIFY OTHERS";

  ///
  String debug_uuid = "UUID: ";

  ///
  void getNewAccountName() {
    var rand = Random();
    var codeUnits = List.generate(12, (index) {
      return ((122 - 97) * rand.nextDouble()).toInt() + 97;
    });
    newAccountName = String.fromCharCodes(codeUnits);
  }

  ///
  void turnOnExposureNotifications() async {
    // Stop previous broadcast
    await turnOffExposureNotifications();

    uuid = generateUUID();
    seed = Uuid().v4();
    // Start Bluetooth Broadcast with UUID
    if (uuid != null) {
      beaconBroadcast
          .setUUID(uuid)
          .setMajorId(MAJOR_ID)
          .setMinorId(MINOR_ID)
          .setTransmissionPower(-59)
          .setIdentifier(IDENTIFIER)
          .setLayout(LAYOUT)
          .setManufacturerId(MANUFACTURER_ID)
          .start();

      // Generate and Save Private EOS keys
      // into database for later query
      var privateKey = EOSPrivateKey.fromSeed(uuid + seed);
      var publicKey = privateKey.toEOSPublicKey();

      print(
          "public: ${publicKey.toString()}\nprivate: ${privateKey.toString()}");

      await uuidDao.insertUuid(eosUUID.Uuid(
          null,
          uuid,
          publicKey.toString(),
          privateKey.toString(),
          DateTime.now().millisecondsSinceEpoch.toString()));

      notify_other_button_label = "NOTIFY OTHERS (${totalUUIDsFound})";
      debug_uuid = "UUID: $uuid";
      notifyParent();
    }
  }

  ///
  void notifyOthers(String privateEOSOwner, String privateEOSActive,
      String mainAccount) async {
    if (notifying) {
      print("already notifying...");
      return;
    }

    await turnOffExposureNotifications();
    notifying = true;

    if (totalUUIDsFound <= 0) {
      notify_other_button_label = "NOTIFY OTHERS (0)";
      notifyParent();
      return;
    }

    String publicKey;
    var ret = false;
    var fail = false;

    notify_other_button_label = "NOTIFYING OTHERS (${totalUUIDsFound})...";
    notifyParent();

    clientTest = eos.EOSClient('https://api.testnet.eos.io', 'v1',
        privateKeys: [privateEOSOwner, privateEOSActive]);
    client = eos.EOSClient('http://jungle.atticlab.net:8888', 'v1',
        privateKeys: [privateEOSOwner, privateEOSActive]);

    for (var i = 0; i < totalUUIDsFound; i++) {
      getNewAccountName();
      publicKey = uuidList.elementAt(i).eosio_public_key;

      print("public: ${publicKey}");

//      https://github.com/adyliu/jeos/wiki/create-eos-account-with-rpc-api
      if (client != null && clientTest != null) {
        var authorization = <eos.Authorization>[
          eos.Authorization()
            ..actor = mainAccount
            ..permission = 'active'
        ];

        var data = <String, dynamic>{
          'creator': mainAccount,
          'name': newAccountName,
          'owner': <String, dynamic>{
            "threshold": 1,
            "keys": [
              <String, dynamic>{"key": publicKey, "weight": 1}
            ],
            "accounts": <String>[],
            "waits": <String>[]
          },
          'active': <String, dynamic>{
            "threshold": 1,
            "keys": [
              <String, dynamic>{"key": publicKey, "weight": 1}
            ],
            "accounts": <String>[],
            "waits": <String>[]
          }
        };

        var actions = [
          eos.Action()
            ..account = 'eosio'
            ..name = 'newaccount'
            ..authorization = authorization
            ..data = data,
          eos.Action()
            ..account = 'eosio'
            ..name = 'buyrambytes'
            ..authorization = authorization
            ..data = <String, dynamic>{
              'payer': mainAccount,
              'receiver': newAccountName,
              'bytes': 8192
            },
          eos.Action()
            ..account = 'eosio'
            ..name = 'buyrambytes'
            ..authorization = authorization
            ..data = <String, dynamic>{
              'payer': mainAccount,
              'receiver': mainAccount,
              'bytes': 8192
            },
          eos.Action()
            ..account = 'eosio'
            ..name = 'delegatebw'
            ..authorization = authorization
            ..data = <String, dynamic>{
              'from': mainAccount,
              'receiver': newAccountName,
              'stake_net_quantity': '0.0100 EOS',
              'stake_cpu_quantity': '0.0100 EOS',
              'transfer': false
            },
          eos.Action()
            ..account = 'eosio.token'
            ..name = 'transfer'
            ..authorization = authorization
            ..data = {
              'from': mainAccount,
              'to': newAccountName,
              'quantity': '0.0001 EOS',
              'memo':
                  '${uuidList.elementAt(i).uuid}@${uuidList.elementAt(i).broadcasted}@${DateTime.now().millisecondsSinceEpoch}',
            }
        ];

        var transaction = eos.Transaction()..actions = actions;
        ret = false;
        try {
          await client
              .pushTransaction(transaction, broadcast: true)
              .then((dynamic trx) async {
            if (trx.toString().contains(", processed:")) {
              ret = true;
            } else {
              ret = false;
              fail = true;
            }
            print("tx: $trx");
          });
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          print('error caught: $e');
          if (e.toString().contains("account_name_exists_exception")) {
            getNewAccountName();
            print("new account name: $newAccountName");
            i--;
            continue;
          } else if (e.toString().contains("UnAuthorized")) {
            print("Wrong keys...");

            notify_other_button_label = "NOTIFY OTHERS \u274C";
            notifyParent();
            notifying = false;
            turnOnExposureNotifications();
            return;
          }
        }
        if (ret) {
          notify_other_button_label = "$notify_other_button_label.";
          notifyParent();
        } else {}
      }
//      client.getInfo().then((nodeInfo) {
//        print("node: $nodeInfo\nTX: $ret");
//      });

//      client.getCurrencyBalance('eosio.token', 'iowebpatient').then((balance) {
//        print("balance of iowebpatient@Jungle: $balance");
//      });

//      clientTest
//          .getCurrencyBalance('eosio.token', 'vgwlaniqicse')
//          .then((balance) {
//        print("balance of iowebpatient@Test: $balance");
//      });
    }
    if (ret) {
      notify_other_button_label = "NOTIFY OTHERS \u2713";
      notifyParent();
    }
    notifying = false;
    if (!fail) {
      print("deleting...");
      await uuidDao.deleteAllUuid();
    }
    turnOnExposureNotifications();
  }

  ///
  void turnOffExposureNotifications() async {
    debug_uuid = "UUID: ";
    notifyParent();
    beaconBroadcast.stop();
  }
}
