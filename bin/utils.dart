enum PlayerDirection { 
   down, left, up, right;
}

extension PlayerDirectionExtension on PlayerDirection {
  PlayerDirection get next {
    final values = PlayerDirection.values;
    final currentIndex = values.indexOf(this);
    return values[(currentIndex + 1) %  values.length];
  }
  PlayerDirection get previous {
    final values = PlayerDirection.values;
    final currentIndex = values.indexOf(this);
    return values[(currentIndex - 1 + values.length) % values.length];
  }
}

enum MeldType { chow, pung, kong }


enum TileSuit { character, bamboo, pin, wind, dragon } 
enum TileSet {
  // Characters
  oneCharacter("🀇", TileSuit.character, 1),
  twoCharacter("🀈", TileSuit.character, 2),
  threeCharacter("🀉", TileSuit.character, 3),
  fourCharacter("🀊", TileSuit.character, 4),
  fiveCharacter("🀋", TileSuit.character, 5),
  sixCharacter("🀌", TileSuit.character, 6),
  sevenCharacter("🀍", TileSuit.character, 7),
  eightCharacter("🀎", TileSuit.character, 8),
  nineCharacter("🀏", TileSuit.character, 9),

  // Bamboos
  oneBamboo("🀐", TileSuit.bamboo, 1),
  twoBamboo("🀑", TileSuit.bamboo, 2),
  threeBamboo("🀒", TileSuit.bamboo, 3),
  fourBamboo("🀓", TileSuit.bamboo, 4),
  fiveBamboo("🀔", TileSuit.bamboo, 5),
  sixBamboo("🀕", TileSuit.bamboo, 6),
  sevenBamboo("🀖", TileSuit.bamboo, 7),
  eightBamboo("🀗", TileSuit.bamboo, 8),
  nineBamboo("🀘", TileSuit.bamboo, 9),

  // Pins
  onePin("🀙", TileSuit.pin, 1),
  twoPin("🀚", TileSuit.pin, 2),
  threePin("🀛", TileSuit.pin, 3),
  fourPin("🀜", TileSuit.pin, 4),
  fivePin("🀝", TileSuit.pin, 5),
  sixPin("🀞", TileSuit.pin, 6),
  sevenPin("🀟", TileSuit.pin, 7),
  eightPin("🀠", TileSuit.pin, 8),
  ninePin("🀡", TileSuit.pin, 9),

  // Winds
  eastWind("🀀", TileSuit.wind, 1),
  southWind("🀁", TileSuit.wind, 2),
  westWind("🀂", TileSuit.wind, 3),
  northWind("🀃", TileSuit.wind, 4),

  // Dragons
  whiteDragon("🀆", TileSuit.dragon, 1),
  greenDragon("🀅", TileSuit.dragon, 2),
  redDragon("🀄︎", TileSuit.dragon, 3);

  const TileSet(this.value, this.suit, this.rank);
  final String value;
  final TileSuit suit;
  final int rank;
}



List<TileSet> generateDeck() {
  List<TileSet> deck = List<TileSet>.empty(growable: true);
  for (TileSet tile in TileSet.values) {
    deck.add(tile);
    deck.add(tile);
    deck.add(tile);
    deck.add(tile);
  }
  deck.shuffle();
  return deck;
}


List<TileSet> testingDeck() {
  List<TileSet> deck = List<TileSet>.empty(growable: true);
  for (var _ in TileSet.values) {
    deck.add(TileSet.eastWind);
    deck.add(TileSet.eastWind);
    deck.add(TileSet.eastWind);
    deck.add(TileSet.eastWind);
  }
  return deck;
}