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

enum TileSet {
  oneCharacter("🀇"),
  twoCharacter("🀈"),
  threeCharacter("🀉"),
  fourCharacter("🀊"),
  fiveCharacter("🀋"),
  sixCharacter("🀌"),
  sevenCharacter("🀍"),
  eightCharacter("🀎"),
  nineCharacter("🀏"),
  onePin("🀙"),
  twoPin("🀚"),
  threePin("🀛"),
  fourPin("🀜"),
  fivePin("🀝"),
  sixPin("🀞"),
  sevenPin("🀟"),
  eightPin("🀠"),
  ninePin("🀡"),
  oneBamboo("🀐"),
  twoBamboo("🀑"),
  threeBamboo("🀒"),
  fourBamboo("🀓"),
  fiveBamboo("🀔"),
  sixBamboo("🀕"),
  sevenBamboo("🀖"),
  eightBamboo("🀗"),
  nineBamboo("🀘"),
  eastWind("🀀"),
  southWind("🀁"),
  westWind("🀂"),
  northWind("🀃"),
  whiteDragon("🀆"),
  greenDragon("🀅"),
  redDragon("🀄︎");

  const TileSet(this.value);
  static const invalid = "null";
  final String value;
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
  TileSet.values.forEach((_) {
    deck.add(TileSet.eastWind);
    deck.add(TileSet.eastWind);
    deck.add(TileSet.eastWind);
    deck.add(TileSet.eastWind);
  });
  return deck;
}