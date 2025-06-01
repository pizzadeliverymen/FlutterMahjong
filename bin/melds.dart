import 'utils.dart';

class Meld {
    
  MeldType type;

  List<TileSet> tiles;

  PlayerDirection direction;

  TileSet stolenTile;

  bool fromPung;

  Meld({
    required this.type,
    required this.tiles,
    required this.stolenTile,
    required this.direction,
    this.fromPung = false
  });

  getHandTiles() {
    return tiles;
  }

  getStolenTile() {
    return stolenTile;
  }

  getDirection() {
    return direction;
  }

  getType() {
    return type;
  }

  isKongFromPung() {
    return fromPung;
  }

  @override
  String toString() {
    return "$type of ${tiles.join(", ")} : $stolenTile";
  }
}



