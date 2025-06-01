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

  sortHand() {
    hand.sort((a,b) => a.index.compareTo(b.index));
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

  bool _canFormSets(Map<TileSet, int> tiles, int setsNeeded) {
    // print("checking sets");
    // we have formed al needed sets
    // all tiles must be used up
    if (setsNeeded == 0) {
      return tiles.values.every((count) => count == 0);
    }

    // we havent formed all needed sets but no more tiles left
    if (tiles.values.every((count) => count == 0)) {
      return false;
    }

    // first tile available that has more than 0 copies
    TileSet? firstTile;
    for (var tile in TileSet.values) {
      if ((tiles[tile] ?? 0 ) > 0) {
        firstTile = tile;
        break;
      }
    }

    // just double checking
    if (firstTile == null) {
      return false;
    }


    final currentCount = tiles[firstTile]!;

    if (currentCount >= 3) {
      // trying to form a pung first.
      tiles[firstTile] = currentCount - 3;
      if (_canFormSets(tiles, setsNeeded-1)) {
        return true;
      }
      // otherwise we add back the tiles
      tiles[firstTile] = currentCount;
    }

    // then we try with kongs
    if (currentCount >= 4) {
      tiles[firstTile] = currentCount - 4;
      if (_canFormSets(tiles, setsNeeded-1)) {
        return true;
      }
      // once again go back otherwise
      tiles[firstTile] = currentCount;
    }
    return false;
  }

  
  Map<TileSet, int> _countFrequencies({Meld? additionalMeld}) {
    final counts = <TileSet, int>{};
    for (var tile in hand) {
      counts[tile] = (counts[tile] ?? 0) + 1;
    }
    for (Meld meld in shownMelds) {
      for (TileSet tile in meld.tiles) {
        counts[tile] = (counts[tile] ?? 0) + 1;
      }
    }
    if (additionalMeld != null) {
      for (TileSet tile in additionalMeld.tiles) {
        counts[tile] = (counts[tile] ?? 0) + 1;
      }
    }
    if (drawnTile != null) counts[drawnTile!] = (counts[drawnTile] ?? 0) + 1;
    return counts;
  }

  // bool _winCondition(Meld additionalMeld) {

  // }

  bool canWin() {
    if (getTileCount() < 14) return false;
    final frequencies = _countFrequencies(); 
    // go through each and see if we can succeed with each tile as a pair;
    for (var entry in frequencies.entries) {
      final potentialPairTile = entry.key;
      final count = entry.value;
      // if we have at least 2 it could be the pair
      if (count >= 2) {
        // print("Checking for if we have a pair of $potentialPairTile");
        // create a copy so we dont break everything when we iterate
        final remainingFrequencies = Map<TileSet, int>.from(frequencies);

        // check if these tiles can be the pair
        remainingFrequencies[potentialPairTile] = count-2;
        // 14 - 2 / (~3) is 4, so we need 4 more sets
        if (_canFormSets(remainingFrequencies, 4)) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  String toString() {
    var result = "$name has ${getHandSize()} tiles in hand\nTheir hand consists of ${hand.map((element) => element.name).join(", ")}";
    if (drawnTile != null) result += "\nThey drew a ${drawnTile!.name}";
    var shown = "";
    result += "\nWith The Following Shown Tiles:";
    for (Meld meld in shownMelds) {
        shown += "\n\t$meld";
    }
    result += shown;
    result += "\nTheir Discard Has ${discards.length} tiles:\n\t${discards.map((element) => element.name).join(", ")}";
    return result;
  }

  addToHand(TileSet newTile) {
    hand.add(newTile);
    sortHand();
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
        addToHand(drawnTile!);
      }
      drawnTile = null;
    }
  }


  addMeld(Meld meld) {
    print("Adding Meld $meld");
    List<TileSet> removeFromHand = meld.tiles;
    for (TileSet tile in removeFromHand) {
      hand.remove(tile);
    }
    shownMelds.add(meld);
    sortHand();
  }

  pungToKong(Meld meld) {
    shownMelds.removeWhere((item) => item.type == MeldType.pung && item.stolenTile == meld.stolenTile);
    shownMelds.add(meld);
  }

  Meld? upgradablePung(TileSet tile) {
    var meldList = shownMelds.where((meld) => meld.type==MeldType.pung && meld.stolenTile == tile);
    if (meldList.isEmpty) return null;
    return meldList.first;
  }

  List<TileSet> callChow(TileSet tile) {
    // TODO: Implement chow determination
    return [];
  }

  List<TileSet> callPung(TileSet tile) {
    var sameTiles = hand.where((item) => item == tile);
    if (sameTiles.length >= 2) {
      return sameTiles.toList().sublist(0,2);
    } else {
      return [];
    }
  }

  List<TileSet> callKong(tile) {
    var sameTiles = hand.where((item) => item == tile);
    if (sameTiles.length >= 3) {
      return sameTiles.toList().sublist(0,3);
    } else {
      return [];
    }
  }

}