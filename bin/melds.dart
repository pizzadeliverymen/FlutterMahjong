import 'utils.dart';

class Meld {
    
  MeldType type;

  List<TileSet> tilesInHand;

  PlayerDirection direction;

  TileSet stolenTile;

  bool fromPung;

  Meld({
    required this.type,
    required this.tilesInHand,
    required this.stolenTile,
    required this.direction,
    this.fromPung = false
  });

  @override
  String toString() {
    if (fromPung) return "Upgraded ${type.name} of ${tilesInHand.map((o) => o.name).join(",")} : ${stolenTile.name}";
    return "${type.name} of ${tilesInHand.map((o) => o.name).join(",")} : ${stolenTile.name}";
  }
}



