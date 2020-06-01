import 'package:floor/floor.dart';

@entity
class Uuid {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String uuid;
  final String eosio_public_key;
  final String eosio_private_key;
  final String broadcasted;
  Uuid(this.id, this.uuid, this.eosio_public_key, this.eosio_private_key, this.broadcasted);
}