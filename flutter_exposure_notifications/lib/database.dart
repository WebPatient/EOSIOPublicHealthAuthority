import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'uuid_dao.dart';
import 'uuid.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Uuid])
abstract class AppDatabase extends FloorDatabase {
  UuidDao get uuidDao;
}