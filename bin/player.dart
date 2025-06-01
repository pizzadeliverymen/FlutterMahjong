import 'melds.dart';
import 'utils.dart';

class Player {
  List<TileSet> hand = [];
  List<TileSet> discards = [];
  List<Meld> shownMelds = [];
  TileSet? drawnTile;

  String name = "PlayerName";

  Player({
    required this.name,
    List<TileSet>? hand,
    }) : hand = hand ?? [];

  getName() {
    return name;
  }

  getHand() {
    return hand;
  }

  getHandSize() {
    return hand.length;
  }

  getTileCount() {
    var count = hand.length;
    count += drawnTile != null ? 1 : 0;

    for (Meld meld in shownMelds) {
      if (meld.getType() == MeldType.chow || meld.getType() == MeldType.pung) {
        count += 3;
      } else {
        count += 4;
      }
    }

    return count;
  }

  getDiscards() {
    return discards;
  }

  getshownMelds() {
    return shownMelds;
  }

  getDrawnTile() {
    return drawnTile;
  }

  @override
  String toString() {
    var result = "$name has ${getHandSize()} tiles in hand\nTheir hand consists of ${hand.join(', ')}";
    if (drawnTile != null) result += "\nThey drew a $drawnTile";
    var shown = "";
    result += "\nWith The Following Shown Tiles:";
    for (Meld meld in shownMelds) {
        shown += "\n\t$meld";
    }
    result += shown;
    result += "\nTheir Discard Has ${discards.length} tiles:\n\t${discards.join()}";
    return result;
  }

  addToHand(TileSet newTile) {
    hand.add(newTile);
    hand.sort();
  }

  drawTile(TileSet newTile) {
    drawnTile = newTile;
  }

  discardTile(TileSet tile) {
    if (drawnTile == tile) {
      drawnTile = null;
      discards.add(tile);
      return true;
    }
    var tileIndex = hand.indexOf(tile);
    if (tileIndex != -1) {
      discards.add(tile);
      hand.removeAt(tileIndex);
      if (drawnTile != null) {
        hand.add(drawnTile!);
      }
      drawnTile = null;
    }
  }

  pungToKong(Meld meld) {
    shownMelds.removeWhere((item) => item.type == MeldType.kong && item.stolenTile == meld.stolenTile);
    shownMelds.add(meld);
  }

  // callChow(TileSet tile) {

  // }

  callPung(TileSet tile) {
    var sameTiles = hand.where((item) => item == tile);
    if (sameTiles.length >= 2) {
      return sameTiles;
    } else {
      return null;
    }
  }

  callKong(tile) {
    var sameTiles = hand.where((item) => item == tile);
    if (sameTiles.length >= 3) {
      return sameTiles;
    } else {
      return null;
    }
  }

}