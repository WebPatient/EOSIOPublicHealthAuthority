// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UuidDao _uuidDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Uuid` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `uuid` TEXT, `eosio_public_key` TEXT, `eosio_private_key` TEXT, `broadcasted` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UuidDao get uuidDao {
    return _uuidDaoInstance ??= _$UuidDao(database, changeListener);
  }
}

class _$UuidDao extends UuidDao {
  _$UuidDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _uuidInsertionAdapter = InsertionAdapter(
            database,
            'Uuid',
            (Uuid item) => <String, dynamic>{
                  'id': item.id,
                  'uuid': item.uuid,
                  'eosio_public_key': item.eosio_public_key,
                  'eosio_private_key': item.eosio_private_key,
                  'broadcasted': item.broadcasted
                },
            changeListener),
        _uuidUpdateAdapter = UpdateAdapter(
            database,
            'Uuid',
            ['id'],
            (Uuid item) => <String, dynamic>{
                  'id': item.id,
                  'uuid': item.uuid,
                  'eosio_public_key': item.eosio_public_key,
                  'eosio_private_key': item.eosio_private_key,
                  'broadcasted': item.broadcasted
                },
            changeListener),
        _uuidDeletionAdapter = DeletionAdapter(
            database,
            'Uuid',
            ['id'],
            (Uuid item) => <String, dynamic>{
                  'id': item.id,
                  'uuid': item.uuid,
                  'eosio_public_key': item.eosio_public_key,
                  'eosio_private_key': item.eosio_private_key,
                  'broadcasted': item.broadcasted
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _uuidMapper = (Map<String, dynamic> row) => Uuid(
      row['id'] as int,
      row['uuid'] as String,
      row['eosio_public_key'] as String,
      row['eosio_private_key'] as String,
      row['broadcasted'] as String);

  final InsertionAdapter<Uuid> _uuidInsertionAdapter;

  final UpdateAdapter<Uuid> _uuidUpdateAdapter;

  final DeletionAdapter<Uuid> _uuidDeletionAdapter;

  @override
  Future<List<Uuid>> findAllUuids() async {
    return _queryAdapter.queryList('SELECT * FROM Uuid', mapper: _uuidMapper);
  }

  @override
  Stream<Uuid> findUuidById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Uuid WHERE id = ?',
        arguments: <dynamic>[id],
        queryableName: 'Uuid',
        isView: false,
        mapper: _uuidMapper);
  }

  @override
  Stream<List<Uuid>> findAllUuidsAsStream() {
    return _queryAdapter.queryListStream('SELECT * FROM Uuid',
        queryableName: 'Uuid', isView: false, mapper: _uuidMapper);
  }

  @override
  Future<void> deleteAllUuid() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Uuid');
  }

  @override
  Future<void> insertUuid(Uuid uuid) async {
    await _uuidInsertionAdapter.insert(uuid, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUuid(Uuid uuid) async {
    await _uuidUpdateAdapter.update(uuid, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteUuid(Uuid uuid) async {
    await _uuidDeletionAdapter.delete(uuid);
  }
}
