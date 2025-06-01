enum PlayerDirection { left, up, right, down }

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
  final String value;
}