import 'melds.dart';
import 'utils.dart';

class Player {
  List<TileSet> _hand = [];
  List<TileSet> discards = [];
  List<Meld> shownMelds = [];
  TileSet? drawnTile;

  String name = "PlayerName";

  Player({
    required this.name,
    List<TileSet>? hand,
  }) : _hand = hand ?? [];

  List<TileSet> get hand => _hand;

  set hand(List<TileSet> newHand) {
    _hand = newHand;
    sortHand();
  }

  int getHandSize() {
    return hand.length;
  }

  void clearHand() {
    hand = [];
  }

  void forceMeld(Meld newMeld) {
    shownMelds.add(newMeld);
  }

  void clearMelds() {
    shownMelds = List<Meld>.empty(growable: true);
  }

  int getTileCount() {
    var count = hand.length;
    count += drawnTile != null ? 1 : 0;

    for (Meld meld in shownMelds) {
      if (meld.type == MeldType.chow || meld.type == MeldType.pung) {
        count += 3;
      } else {
        // technically we dont count one of the tiles in pungs, so...
        // we increment count by 3 instead of four
        // count += 4;
        count += 3;
      }
    }
    return count;
  }

  void sortHand() {
    _hand.sort((a,b) => a.index.compareTo(b.index));
  }

  bool wonHand() {
    int tileCount = getTileCount();
    final frequencies = _countFrequencies(); 
    if (tileCount < 14) return false;
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
        // ( 14 - 2 ) / 3 is 4, so we need 4 more sets
        List<Meld>? otherMelds = _canFormSets(remainingFrequencies, 4);
        if (otherMelds != null) {
          return true;
        }
      }
    }
    return true;
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

  void addToHand(TileSet newTile) {
    _hand.add(newTile);
    sortHand();
  }

  /// moves {tile} from hand list to the discard list.
  /// if tile is the same as drawnTile, move drawnTile to discard and clear drawnTile
  /// If player has a drawnTile, then move drawnTile to hand and clear drawnTile
  bool discardTile(TileSet tile) {
    if (drawnTile == tile) {
      drawnTile = null;
      discards.add(tile);
      sortHand();
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
      sortHand();
      return true;
    }
    sortHand();
    return false;
  }

  /// adds a given meld to the shownMelds list
  void addMeld(Meld meld) {
    List<TileSet> removeFromHand = meld.tilesInHand;
    for (TileSet tile in removeFromHand) {
      hand.remove(tile);
    }
    shownMelds.add(meld);
    sortHand();
  }

  /// upgrades a pung meld to a kong meld if available
  void pungToKong(Meld meld) {
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


  List<Meld>? _canFormSets(Map<TileSet, int> tiles, int setsNeeded) {
    // print("checking sets");
    // we have formed all needed sets
    // all tiles must be used up
    if (setsNeeded == 0) {
      if (tiles.values.every((count) => count == 0)) return [];
      return null;
    }
    // we havent formed all needed sets but no more tiles left
    if (tiles.values.every((count) => count == 0)) {
      return null;
    }
    // first tile available that has more than 0 copies
    TileSet? firstTile;
    for (var tile in TileSet.playableTiles) {
      if ((tiles[tile] ?? 0 ) > 0) {
        firstTile = tile;
        break;
      }
    }
    // just double checking
    if (firstTile == null) {
      return null;
    }
    // hold onto the current count for the firstTile
    final currentCount = tiles[firstTile]!;
    if (currentCount >= 3) {
      // trying to form a pung first. if it works we return these melds
      tiles[firstTile] = currentCount - 3;
      List<Meld>? testedMelds = _canFormSets(tiles, setsNeeded-1);
      if (testedMelds != null) {
        Meld pung = Meld.pungMeld(tilesInHand: [firstTile,firstTile,firstTile]);
        testedMelds.add(pung);
        return testedMelds;
      }
      // otherwise we add back the tiles
      tiles[firstTile] = currentCount;
    }

    // then we try with kongs
    if (currentCount >= 4) {
      tiles[firstTile] = currentCount - 4;
      List<Meld>? testedMelds = _canFormSets(tiles, setsNeeded-1);
      if (testedMelds != null) {
        Meld kong = Meld.kongMeld(tilesInHand: [firstTile,firstTile,firstTile,firstTile]);
        testedMelds.add(kong);
        return testedMelds;
      }
      // once again go back otherwise
      tiles[firstTile] = currentCount;
    }
    return null;
  }

  Map<TileSet, int> _handFrequencies() {
    return TileSet.frequencyCount(hand);
  }
  
  Map<TileSet, int> _tileValues() {
    Map<TileSet, int> tileValue = _handFrequencies();
    // double counts above 1 to get values
    // a pair where the rest of the tiles have been discarded is more valuable than a singleton w/no discards (1 vs 4-2)
    // and a pung with a discard is more valuable than a pair with no discards (4 vs 6-1)
    // and a kong is the most valuble
    return tileValue.map( (tile, count)  {
      if (count > 1) {
        return MapEntry(tile, count*2);
      } else {
        return MapEntry(tile, count);
      }}
    );
  }

  Map<TileSet, int> _countFrequencies({Meld? additionalMeld}) {
    final counts = _handFrequencies();
    for (Meld meld in shownMelds) {
      for (TileSet tile in meld.tilesInHand) {
        counts[tile] = (counts[tile] ?? 0) + 1;
      }
      if (meld.stolenTile != null){
        counts[meld.stolenTile!] = (counts[meld.stolenTile] ?? 0) + 1;
      }
    }
    if (additionalMeld != null) {
      for (TileSet tile in additionalMeld.tilesInHand) {
        counts[tile] = (counts[tile] ?? 0) + 1;
      }
      if (additionalMeld.stolenTile != null){
        counts[additionalMeld.stolenTile!] = (counts[additionalMeld.stolenTile] ?? 0) + 1;
      }
    }
    if (drawnTile != null) counts[drawnTile!] = (counts[drawnTile] ?? 0) + 1;
    return counts;
  }

  /// Returns a list of lists of melds that win the game
  List<List<Meld>> canWin([TileSet? additionalTile]) {
    List<List<Meld>> result = [];
    int tileCount = getTileCount();
    final frequencies = _countFrequencies(); 
    if (additionalTile != null) {
      tileCount++;
      frequencies[additionalTile] = ( frequencies[additionalTile] ?? 0 ) + 1;
    }
    if (tileCount < 14) return [];
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
        // ( 14 - 2 ) / 3 is 4, so we need 4 more sets
        List<Meld>? otherMelds = _canFormSets(remainingFrequencies, 4);
        if (otherMelds != null) {
          Meld pairMeld = Meld.pairMeld(tilesInHand: [potentialPairTile,potentialPairTile]);
          otherMelds.add(pairMeld);
          result.add(otherMelds);
        }
      }
    }
    return result;
  }

  /// Returns a List of Winning melds from a given hand that include newTile
  List<Meld> _findNewMeld(TileSet newTile, List<Meld> winner) {
    // now make sure its not a meld we already showed
    for (Meld m in shownMelds) {
      winner.remove(m);
    }
    // now we need to find only the melds that has newTile
    List<Meld> hasTile = winner.where( (meld) => 
      meld.stolenTile == newTile || meld.tilesInHand.contains(newTile)
    ).toList(growable: true);
    // thoretically we could win through two in-hand melds 
    // i.e. we have 2b3b4b4b4b, and newtile is 4b
    // 2b3b4b chow and 4b4b4b pung
    return hasTile;
  } 

  /// Returns list of all melds that would win the game if we called newTile
  List<Meld> findWinningMelds(TileSet newTile) {
    List<List<Meld>> winningMelds = canWin(newTile);
    List<Meld> result = [];

    for (List<Meld> winner in winningMelds) {
      result.addAll(_findNewMeld(newTile, winner));
    }
    // return all melds that win the game
    return result;
  }


  ///This function returns a list of all possible complete melds in hand
  List<Meld> completeMeldsInHand([TileSet? newTile]) {
    List<Meld> result = [];
    Map<TileSet, int> frequencies = _handFrequencies();
    if (newTile != null) {
      
    }
    frequencies.forEach( (tile, count) {
      // if a hand has at least 2 its a pair
      // if a hand has at least 3 its a pung
      // if a hand has at least 4 its a kong
      if (count >= 2) {
        result.add(Meld.selfMeld(type: MeldType.pair, tilesInHand: [tile,tile]));
      }
      if (count >= 3) {
        result.add(Meld.selfMeld(type: MeldType.pung, tilesInHand: [tile,tile,tile]));
      }
      if (count >= 4) {
        result.add(Meld.selfMeld(type: MeldType.kong, tilesInHand: [tile,tile,tile,tile]));
      }
    });

    result.addAll(completeChows());

    return result;
  }

  List<Meld> completeChows() { return [];}
}

class AiPlayer extends Player{


  // Player({
  //   required this.name,
  //   List<TileSet>? hand,
  // }) : _hand = hand ?? [];
  late Difficulty diffLevel;
  AiPlayer({required super.name, super.hand, this.diffLevel = Difficulty.unknowing});
  AiPlayer.withHand({required super.name, required super.hand, this.diffLevel = Difficulty.unknowing});



// Default cutoff is -2, because thats the worst outcome (you have a tile and all other versions are discarded/melded)
  TileSet _leastValuable({int cutoff = -2, List<TileSet> discards = const [], List<Meld> melds = const []}) {
    TileSet chosenTile = TileSet.tileBack;
    // we create a map between tiles and their values.
    Map<TileSet, int> tileValues = _tileValues();
    // the base value increases based on the count we have in hand (more tiles in hand are more valuable)
    for (TileSet tile in discards) {
      // and we decrease value if a tile is in the discard
      if (tileValues.containsKey(tile)) {
        tileValues[tile] = tileValues[tile]! - 1;
      }
    }

    // and we also decrease value if we know a tile is already in a meld (i.e. there is one less on the board)
    for (Meld m in melds) {
      for (TileSet tile in m.tilesInHand) {
        if (tileValues.containsKey(tile)) {
          tileValues[tile] = tileValues[tile]! - 1;
        }
      }
      if (tileValues.containsKey(m.stolenTile)) {
        tileValues[m.stolenTile!] = tileValues[m.stolenTile!]! - 1;
      }
    }
    // first we decide to remove any honor tiles of count of -2 (lowest possible count)
    chosenTile = hand.lastWhere( (tile) => tileValues[tile]! <= cutoff && tile.isHonor, orElse: () => TileSet.tileBack);
    // if we didnt get an honor tile, now we need to test the terminal tiles (1s and 9s)
    if (chosenTile == TileSet.tileBack) {
      chosenTile = hand.lastWhere( (tile) => tileValues[tile]! <= cutoff && tile.isTerminal, orElse: () => TileSet.tileBack);
    }
    // if we still dont have tile, we do any tile that meets cutoff
    if (chosenTile == TileSet.tileBack) {
      chosenTile = hand.lastWhere( (tile) => tileValues[tile]! <= cutoff, orElse: () => TileSet.tileBack);
    }
    // and if we still dont have a good tile, we increase the cutoff and try again
    if (chosenTile == TileSet.tileBack) {
      chosenTile = _leastValuable(cutoff: cutoff+1, discards: discards, melds: melds);
    }
    return chosenTile;
  }

  /// Have the ai decide if they want to call on a tile
  /// if a call wins the ai, they will take it no matter what
  /// otherwise the ai will decide to call based on other factors
  Meld? decideCall(TileSet tile) {

    // if a meld wins the game, call it no matter what (ai not smart enough to strategize delaying calls)
    List<Meld> winningMelds = findWinningMelds(tile);
    if (winningMelds.isNotEmpty) return winningMelds.first;

    // otherwise test each meld for if the ai CAN call it first.
    List<TileSet> chowMelds = callChow(tile);
    List<TileSet> pungMelds = callPung(tile);
    List<TileSet> kongMelds = callKong(tile);
    Meld potentialKong = Meld(type: MeldType.kong, tilesInHand: kongMelds, stolenTile: tile);
    Meld potentialPung = Meld(type: MeldType.pung, tilesInHand: pungMelds, stolenTile: tile);
    Meld potentialChow = Meld(type: MeldType.chow, tilesInHand: chowMelds, stolenTile: tile);
    // if a meld doesn't break a meld already in hand then we can call
    // kong -> pung -> chow
    List<Meld> inHandMeld = completeMeldsInHand();
    // but we want to double check that we dont have conflicts first
    List<Meld> conflictMelds = inHandMeld.where( (meld) => 
            (!meld.tilesInHand.contains(tile) || meld.stolenTile == tile)
            ).toList();
    if (kongMelds.isNotEmpty && conflictMelds.where((m) => m.type != MeldType.pung).isEmpty) {
      // we can call on a kong, as long as only conflict we ignore is pung
      return potentialKong;
    }
    if (conflictMelds.isEmpty) {
      // now check for pung
      if (pungMelds.isNotEmpty) {
          return potentialPung;
      }
      if (chowMelds.isNotEmpty) {
        return potentialChow;
      }
    }
    // for now thats the only reason an ai would call

    return null;
  }

  // Determine how the ai will choose to discard a tile from their hand
  TileSet chooseDiscard({List<TileSet> previousDiscards = const [], List<Meld> allShownMelds = const []}) {
    TileSet toDiscard = TileSet.tileBack;
    if (hand.isEmpty) return toDiscard;
    switch (diffLevel) {
      case Difficulty.medium:
        /**
         * Medium will use discards/melds
         */
        toDiscard = _leastValuable(discards: previousDiscards);
        break;

      case Difficulty.easy:
        /**
         * The second easiest will only check their own hand.
         */
        toDiscard = _leastValuable(discards: discards, melds: shownMelds);
        break;

      case Difficulty.unknowing:
      default:
        // the simplest ai will just discard the drawn tile if possible, otherwise it will just discard the first tile in its hand
        if (drawnTile != null) {
          toDiscard = drawnTile!;
        } else {
          toDiscard = hand.last;
        }
        break;
    }
    // discardTile(toDiscard);
    return toDiscard;
  }
}