
import 'package:test/test.dart';
import '../bin/melds.dart';
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


  group('Easy Level AI', () {
    // as an easy ai, steve should only take into account his own discards/shown tiles

    
    test("Only Hand", () {
      final easyHand = [
        TileSet.redDragon, TileSet.redDragon, TileSet.redDragon,
        TileSet.nineBamboo, TileSet.nineBamboo,
        TileSet.eastWind,TileSet.eastWind,
        TileSet.oneBamboo,
        TileSet.fiveBamboo,
        TileSet.westWind
      ];
      AiPlayer easySteve = AiPlayer(name: "Easy Steve", diffLevel: Difficulty.easy);

      /**
       * The order of discards for this hand should be:
       *  westWind->oneBamboo->fiveBamboo->eastWind->eastWind->nineBamboo->nineBamboo->redDragon...->tileBack
       */
      easySteve.hand = easyHand;
      easySteve.clearMelds();
      easySteve.discards = [];
      TileSet discardable;
      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.westWind);
      easySteve.discardTile(discardable);
      
      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.oneBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.fiveBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.eastWind);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.eastWind);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.nineBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.nineBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.tileBack);
    });

    test('What About Discards?', () {
      final easyHand = [
        TileSet.redDragon, TileSet.redDragon, TileSet.redDragon,
        TileSet.nineBamboo, TileSet.nineBamboo,
        TileSet.eastWind,TileSet.eastWind,
        TileSet.oneBamboo,
        TileSet.fiveBamboo,
        TileSet.westWind
      ];
      List<TileSet> discard = [TileSet.nineBamboo, TileSet.nineBamboo];
      // so the ai should discard ninebamboo first
      AiPlayer easySteve = AiPlayer(name: "Easy Steve", diffLevel: Difficulty.easy);
      easySteve.hand = easyHand;
      easySteve.clearMelds();
      easySteve.discards = [];
      easySteve.discards = discard;
      /**
       * The order of discards for this hand should be:
       *  westWind->oneBamboo->fiveBamboo->nineBamboo->nineBamboo->eastWind->eastWind->redDragon...->tileBack
       */

      TileSet discardable;
      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.westWind);
      easySteve.discardTile(discardable);
      
      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.oneBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.fiveBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.nineBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.nineBamboo);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.eastWind);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.eastWind);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      easySteve.discardTile(discardable);

      discardable = easySteve.chooseDiscard();
      expect(discardable, TileSet.tileBack);
    });

    test("Time For Melds", () {
      final easyHand = [
        TileSet.redDragon, TileSet.redDragon, TileSet.redDragon,
        TileSet.nineBamboo, TileSet.nineBamboo,
        TileSet.eastWind,TileSet.eastWind,
        TileSet.oneBamboo,
        TileSet.fiveBamboo,
        TileSet.westWind
      ];
      AiPlayer steveEasy = AiPlayer(name: "Easy Steve", diffLevel: Difficulty.easy);
      steveEasy.hand = easyHand;
      steveEasy.clearMelds();
      steveEasy.discards = [];
      steveEasy.addToHand(TileSet.fiveBamboo);
      steveEasy.addToHand(TileSet.fiveBamboo);
      
      steveEasy.addMeld(Meld(type: MeldType.pung, tilesInHand: [TileSet.fiveBamboo,TileSet.fiveBamboo], stolenTile: TileSet.fiveBamboo, direction: PlayerDirection.up));
      // this means easysteve should have a 3 of a kind shown, but still have a fivebamboo in hand, which should cause it to be removed first
      /**
       * The order of discards for this hand should be:
       *  fiveBamboo->westWind->oneBamboo->eastWind->eastWind->nineBamboo->nineBamboo->redDragon...->tileBack
       */
      TileSet discardable;

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.fiveBamboo);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.westWind);
      steveEasy.discardTile(discardable);
      
      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.oneBamboo);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.eastWind);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.eastWind);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.nineBamboo);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.nineBamboo);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.redDragon);
      steveEasy.discardTile(discardable);

      discardable = steveEasy.chooseDiscard();
      expect(discardable, TileSet.tileBack);
    });
  });

  // this player should always return the drawn tile or the last tile
}