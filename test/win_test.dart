import 'dart:math';

import 'package:mahjong/melds.dart';
import 'package:mahjong/player.dart';
import 'package:mahjong/utils.dart';
import 'package:test/test.dart';

void main() {
  // --- Test Cases ---

  // Winning Hand 1: 4 Pungs + 1 Pair
  // 3x 1Character, 3x 2Character, 3x 3Character, 3x Red Dragon, 2x Green Dragon
  List<TileSet> winningHand1 = [
    TileSet.oneCharacter, TileSet.oneCharacter, TileSet.oneCharacter,
    TileSet.twoCharacter, TileSet.twoCharacter, TileSet.twoCharacter,
    TileSet.threeCharacter, TileSet.threeCharacter, TileSet.threeCharacter,
    TileSet.redDragon, TileSet.redDragon, TileSet.redDragon,
    TileSet.greenDragon, TileSet.greenDragon,
  ];
  Player testPlayer = Player(name: "TestPlayer");
  

  // Winning Hand 2: Mixed Pungs/Kongs + 1 Pair
  // 4x 1Bamboo, 3x 2Bamboo, 3x 3Bamboo, 3x White Dragon, 2x East Wind
  List<TileSet> winningHand2 = [
    TileSet.oneBamboo, TileSet.oneBamboo, TileSet.oneBamboo, TileSet.oneBamboo, // Kong
    TileSet.twoBamboo, TileSet.twoBamboo, TileSet.twoBamboo, // Pung
    TileSet.threeBamboo, TileSet.threeBamboo, TileSet.threeBamboo, // Pung
    TileSet.whiteDragon, TileSet.whiteDragon, TileSet.whiteDragon, // Pung
    TileSet.eastWind, TileSet.eastWind, // Pair
  ];

  group("Winning", () {
    test('Player should win with just their hand:', () {
      testPlayer.hand = winningHand1;
      expect(testPlayer.canWin().isNotEmpty, true);
    });
    test('Player should win with just their hand (1 Kong):', () {
      testPlayer.hand = winningHand2;
      expect(testPlayer.canWin().isNotEmpty, true);
    });

    test('Randomly Generated Players with winning hands:', () {
      Player randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
      randomPlayer = createWinningPlayer();
      expect(randomPlayer.canWin().isNotEmpty, true, reason: randomPlayer.toString());
    }, tags: 'random');
  });
  

  // Losing Hand 1: Not 14 tiles
  List<TileSet> losingHand1 = [
    TileSet.oneCharacter, TileSet.oneCharacter, TileSet.oneCharacter,
    TileSet.twoCharacter, TileSet.twoCharacter, TileSet.twoCharacter,
    TileSet.threeCharacter, TileSet.threeCharacter, TileSet.threeCharacter,
    TileSet.redDragon, TileSet.redDragon,
    TileSet.greenDragon, TileSet.greenDragon, // Only 13 tiles
  ];
  
  // print('Hand 3 (Losing - 13 tiles): ${doesHandWin(losingHand1)}'); // Expected: false

  // Losing Hand 2: Not enough sets/pair
  List<TileSet> losingHand2 = [
    TileSet.oneCharacter, TileSet.oneCharacter, TileSet.oneCharacter,
    TileSet.twoCharacter, TileSet.twoCharacter,
    TileSet.threeCharacter, TileSet.threeCharacter,
    TileSet.redDragon,
    TileSet.greenDragon, TileSet.greenDragon,
    TileSet.whiteDragon,
    TileSet.northWind,
    TileSet.southWind,
    TileSet.eastWind,
  ]; // This is a mixed, unorganized hand.
  
  // print('Hand 4 (Losing - Mixed): ${doesHandWin(losingHand2)}'); // Expected: false

  // Losing Hand 3: Has a pair, but remaining cannot form 4 sets of 3/4
  List<TileSet> losingHand3 = [
    TileSet.oneCharacter, TileSet.oneCharacter, TileSet.oneCharacter, // Pung
    TileSet.twoCharacter, TileSet.twoCharacter, TileSet.twoCharacter, // Pung
    TileSet.threeCharacter, TileSet.threeCharacter, TileSet.threeCharacter, // Pung
    TileSet.redDragon, TileSet.redDragon,
    TileSet.greenDragon,
    TileSet.whiteDragon,
    TileSet.northWind,
  ]; // Has 3 pungs, 1 pair, and 2 singles (14 tiles but not 4 sets + pair)


  group("Losing", () {
    test('Player doesnt have enough tiles:', () {
      testPlayer.hand = losingHand1;
      expect(testPlayer.canWin(), []);
    });
    test('Player should lose with just their hand:', () {
      testPlayer.hand = losingHand2;
      expect(testPlayer.canWin(), []);
    });
    test('Player missing a meld:', () {
      testPlayer.hand = losingHand3;
      expect(testPlayer.canWin(), []);
    });

    test('Losing Through Missing Single Tile:', () {
      Player randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
      randomPlayer = createLosingPlayer();
      expect(randomPlayer.canWin(), [], reason: randomPlayer.toString());
    }, tags: 'random');
  });
  
}



Player createWinningPlayer() {
  final Random random = Random();
  // get the entire list of every tile
  final List<TileSet> allPossibleTiles = List.of(TileSet.playableTiles);
  // shuffle them up
  allPossibleTiles.shuffle();
  // and take the first 5 to use in the winning hand
  // 1 is going to be pair, 4 are going to be pung/kong
  final List<TileSet> chosenTiles = allPossibleTiles.sublist(0,5);
  
  final TileSet pair = chosenTiles.removeAt(0);
  final List<TileSet> melds = chosenTiles;
  Player randomPlayer = Player(name: "RandomGeneration ${random.nextDouble()}");
  randomPlayer.addToHand(pair);
  // -1 for pair, 0 for the melds[0]... 3 for melds[3]
  // [0,5) = 0, 1, 2, 3, 4
  // subract 1 => -1, 0, 1, 2, 3
  int handTile = random.nextInt(5) - 1;
  if (handTile == -1) {
    randomPlayer.drawnTile = pair;
  } else {
    randomPlayer.addToHand(pair);
  }
  int index = 0;
  for (TileSet tile in melds) {
    bool isShown = random.nextBool();
    if (index == handTile) {
      randomPlayer.drawnTile = tile;
      isShown = false;
    } else {
      randomPlayer.addToHand(tile);
    }
    index ++;
    bool isKong = random.nextBool();
    randomPlayer.addToHand(tile);
    if (isKong) {
      randomPlayer.addToHand(tile);
      if (isShown) {
        // we create a meld with these tiles and add it to player
        Meld generatedMeld = Meld(type: MeldType.kong, tilesInHand: [tile,tile,tile], stolenTile: tile, direction: PlayerDirection.up);
        randomPlayer.addMeld(generatedMeld);
      } else {
        // otherwise its just in the players hand
        randomPlayer.addToHand(tile);
      }
    } else if (isShown) {
      // it is a pung and shown so meld again
      Meld generatedMeld = Meld(type: MeldType.pung, tilesInHand: [tile,tile], stolenTile: tile, direction: PlayerDirection.up);
      randomPlayer.addMeld(generatedMeld);
    } else {
      // in-hand pung
      randomPlayer.addToHand(tile);
    }
  }
  return randomPlayer;
}

Player createLosingPlayer() {
  final Random random = Random();
  Player loser = createWinningPlayer();
  TileSet discardWinningTile = loser.hand[random.nextInt(loser.getHandSize())];
  do {
    loser.discardTile(discardWinningTile);
  } while (loser.getTileCount() >= 14 && loser.hand.where((tile) => tile==discardWinningTile).length >= 3);
  return loser;
}