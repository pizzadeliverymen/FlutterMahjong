import 'utils.dart';

class Meld {
    
  late MeldType type;

  List<TileSet> tilesInHand;

  late PlayerDirection? direction;

  TileSet? stolenTile;

  late bool fromPung;

  Meld({
    required this.type,
    required this.tilesInHand,
    required this.stolenTile,
    this.direction,
    this.fromPung = false
  });


  Meld.selfMeld({
    required this.type,
    required this.tilesInHand
  }) {
    stolenTile = null;
    direction = PlayerDirection.down;
    fromPung = false;
  }

  Meld.pairMeld({
    required this.tilesInHand
  }) {
    type = MeldType.pair;
    stolenTile = null;
    direction = PlayerDirection.down;
    fromPung = false;
  }

  Meld.pungMeld({
    required this.tilesInHand
  }) {
    type = MeldType.pung;
    stolenTile = null;
    direction = PlayerDirection.down;
    fromPung = false;
  }

  Meld.kongMeld({
    required this.tilesInHand
  }) {
    type = MeldType.kong;
    stolenTile = null;
    direction = PlayerDirection.down;
    fromPung = false;
  }

  @override
  String toString() {
    if (fromPung) return "Upgraded ${type.name} of ${tilesInHand.map((o) => o.name).join(",")} : ${stolenTile?.name}";
    if (type == MeldType.pair) return "${type.name} of ${tilesInHand.map((o) => o.name).join(",")}";
    return "${type.name} of ${tilesInHand.map((o) => o.name).join(",")} : ${stolenTile?.name}";
  }
}



