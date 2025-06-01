
import 'package:test/test.dart';
import '../bin/player.dart';
import '../bin/utils.dart';


void main() {
  group("Edge Cases", () {
    AiPlayer edger = AiPlayer(name: "Edger", diffLevel: Difficulty.unknowing);
    
    test("No tiles in hand should return tileBack", () {
      edger.hand = [];
      expect(edger.chooseDiscard(), TileSet.tileBack);
    });

      test("Only one tile should return that tile", () {
    edger.hand = [TileSet.eastWind];
      expect(edger.chooseDiscard(), TileSet.eastWind);
    });
  });

  group("Oblivious AI", () {
    AiPlayer oblivious = AiPlayer(name: "Oblivious", diffLevel: Difficulty.unknowing);
    oblivious.hand = generateHand();
    test("Oblivious should discard drawn tile each time", () {
      oblivious.drawnTile = TileSet.eastWind;
      expect(oblivious.chooseDiscard(), oblivious.drawnTile);
      oblivious.drawnTile = TileSet.westWind;
      expect(oblivious.chooseDiscard(), oblivious.drawnTile);
      oblivious.drawnTile = TileSet.sevenPin;
      expect(oblivious.chooseDiscard(), oblivious.drawnTile);
      oblivious.drawnTile = TileSet.redDragon;
      expect(oblivious.chooseDiscard(), oblivious.drawnTile);
      oblivious.drawnTile = TileSet.redDragon;
      expect(oblivious.chooseDiscard(), oblivious.drawnTile);
    });
    test("Oblivious should discard last tile if no discard", () {
      oblivious.drawnTile = null;
      oblivious.sortHand();
      expect(oblivious.chooseDiscard(), oblivious.hand.last, reason: oblivious.toString());
      oblivious.discardTile(oblivious.hand.first);
      expect(oblivious.chooseDiscard(), oblivious.hand.last, reason: oblivious.toString());
      oblivious.discardTile(oblivious.hand.first);
      expect(oblivious.chooseDiscard(), oblivious.hand.last, reason: oblivious.toString());
      oblivious.discardTile(oblivious.hand.first);
      expect(oblivious.chooseDiscard(), oblivious.hand.last, reason: oblivious.toString());
      oblivious.discardTile(oblivious.hand.first);
      expect(oblivious.chooseDiscard(), oblivious.hand.last, reason: oblivious.toString());
    });
  });



  // this player should always return the drawn tile or the last tile
}