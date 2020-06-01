import 'package:floor/floor.dart';
import 'package:flutter_exposure_notifications/uuid.dart';

///
@dao
abstract class UuidDao {
  @Query('SELECT * FROM Uuid')
  Future<List<Uuid>> findAllUuids();

  @Query('SELECT * FROM Uuid WHERE id = :id')
  Stream<Uuid> findUuidById(int id);

  @insert
  Future<void> insertUuid(Uuid uuid);

  @Query('SELECT * FROM Uuid')
  Stream<List<Uuid>> findAllUuidsAsStream();

  @delete
  Future<void> deleteUuid(Uuid uuid);

  @Query('DELETE FROM Uuid')
  Future<void> deleteAllUuid();

  @update
  Future<void> updateUuid(Uuid uuid);

}