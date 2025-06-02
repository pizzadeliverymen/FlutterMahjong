import 'dart:math';

import 'utils.dart';
import 'melds.dart';
import 'player.dart';
import 'dart:io';

class MahjongGame {
  // default dealer is the user (aka the down direction)
  PlayerDirection east = PlayerDirection.down;
  late PlayerDirection turn;
  List<Player> playerList = [];
  List<TileSet> deck = generateDeck();

  // if ai and player can call at the same time, we add them to aiFight
  // the different difficulties change how long it takes the ai to call
  // ToDo: finish ai calling
  List<Player> aiFight = [];

  MahjongGame({this.east = PlayerDirection.down, bool human = true}) {
    turn = east;
    if (human){
      var human = Player(name: "Human", hand: deck.take(13).toList());
      deck.removeRange(0, 13);
      human.sortHand();
      playerList.add(human);
    } else {
      playerList.add(AiPlayer(name: "Down AI", hand: deck.take(13).toList(), diffLevel: Difficulty.easy));
      deck.removeRange(0, 13);
    }
    playerList.add(AiPlayer(name: "Left AI", hand: deck.take(13).toList(), diffLevel: Difficulty.easy));
    deck.removeRange(0, 13);
    playerList.add(AiPlayer(name: "Opposite AI", hand: deck.take(13).toList(), diffLevel: Difficulty.easy));
    deck.removeRange(0, 13);
    playerList.add(AiPlayer(name: "Right AI", hand: deck.take(13).toList(), diffLevel: Difficulty.easy));
    deck.removeRange(0, 13);

    for (Player player in playerList) {
      player.sortHand();
    }
    // print(playerList[1].hand.map((o)=>o.name).join(","));
    // print(playerList[2].hand.map((o)=>o.name).join(","));
    // print(playerList[3].hand.map((o)=>o.name).join(","));
  }

  void randomizeEast() {
    east = PlayerDirection.values[Random().nextInt(4)];
    turn = east;
  }

  void startGame() {
    singleTurn();
  }
  
  Future<void> singleTurn({bool draw = true}) async {
    if (deck.isEmpty) {
      finishGame();
      return;
    }
    var nextTile = deck.removeLast();
    if (turn == PlayerDirection.down && false) {
      humanTurn(nextTile, draw);
    } else {
      // ai turn
      AiPlayer currentPlayer = playerList[ turn.index ] as AiPlayer;
      currentPlayer.drawnTile = nextTile;
      TileSet discardedTile = currentPlayer.chooseDiscard();
      print("Player '${currentPlayer.name}' is discarding ${discardedTile.name}");
      currentPlayer.discardTile(discardedTile);
      // do a chow/pung/kong check for everyone
      for (int i = 1; i < 4; i++) {
        Player playerCheck = playerList[ (turn.index + i) % 4 ];
        List<TileSet> kongList = playerCheck.callKong(discardedTile);
        if (kongList.isNotEmpty) {
          print("${playerCheck.name} can call a kong (and a pung) on ${discardedTile.name}");
        } else if (playerCheck.callPung(discardedTile).isNotEmpty) {
          print("${playerCheck.name} can call a pung on ${discardedTile.name}");
        }
      }
      // checkHumanCalls(discardedTile);
      await Future.delayed(Duration(milliseconds: 500));
    }

    turn = turn.next;
    singleTurn();
  }
  
  void humanTurn(TileSet nextTile, bool draw) {
    Player human = playerList[ turn.index ];
    if (draw) human.drawnTile = nextTile;
    if (human.canWin()) {
      print("YOU WON!!!");
      deck = [];
      return;
    }
    print("Your hand ${human.hand.map((o) => o.name).join(",")}");
    print("Drawn Tile: ${nextTile.name}");
    print("Your Discards: ${human.discards.map((o) => o.name).join(",")}");
    print("Which tile do you want to discard?");
    print("");
    List<String> possibleAnswers = human.hand.map((tile) => tile.name.toLowerCase()).toList(growable: true);
    if (human.drawnTile != null ) {
      possibleAnswers.add(human.drawnTile!.name.toLowerCase());
    }
    String? answer = _userAsk(possibleAnswers);
    TileSet discard = TileSet.playableTiles.firstWhere( (tile) => tile.name.toLowerCase() == answer!);
    human.discardTile(discard);
    // print("tile has been found and removed");
    // print(human);
  }

  String? _userAsk(List<String> possibleAnswers, [bool forceAnswer = true, int timeOut = -1]) {
    // if timeout >0 then we wait that many seconds before continuing
    String? answer = stdin.readLineSync()?.toLowerCase();
    if (!possibleAnswers.contains(answer) && forceAnswer) {
      return _userAsk(possibleAnswers);
    }
    return answer;
  }
  
  void checkHumanCalls(TileSet nextTile) {
    Player human = playerList[ (PlayerDirection.down.index) ];
    List<TileSet> kongList = human.callKong(nextTile);
    bool kongAble = kongList.isNotEmpty;
    List<TileSet> pungList = human.callPung(nextTile);
    bool pungAble = pungList.isNotEmpty;
    List<TileSet> chowList = human.callChow(nextTile);
    bool chowAble = chowList.isNotEmpty;
    Meld? upgradablePung = human.upgradablePung(nextTile);
    bool upgradeAble = upgradablePung != null;

    List<String> options = [];
    if(upgradeAble) options.add("upgrade");
    if (kongAble) options.add("kong");
    if (pungAble) options.add("pung");
    if (chowAble) options.add("chow");
    if (options.isEmpty) return;
    String question = "You can call ${options.join(",")}, or you can 'cancel'";
    print(question);
    options.add("cancel");
    String? answer = _userAsk(options, false);
    if (answer == null) return;
    switch(answer) {
      case "upgrade":
        List<TileSet> meldTiles = upgradablePung!.tilesInHand;
        meldTiles.add(upgradablePung.stolenTile);
        Meld meld = Meld(type: MeldType.kong, tilesInHand: meldTiles, stolenTile: nextTile, direction: turn, fromPung: true);
        human.pungToKong(meld);
        turn = PlayerDirection.down;
        singleTurn(draw: false);
        break;
      case "kong":
        Meld meld = Meld(type: MeldType.kong, tilesInHand: kongList, stolenTile: nextTile, direction: turn);
        human.addMeld(meld);
        turn = PlayerDirection.down;
        singleTurn(draw: false);
        break;
      case "pung":
        Meld meld = Meld(type: MeldType.pung, tilesInHand: pungList, stolenTile: nextTile, direction: turn);
        human.addMeld(meld);
        turn = PlayerDirection.down;
        singleTurn(draw: false);
        break;
      default:
        print("Not calling");
    }
  }
  
  void finishGame() {
    for (Player player in playerList) {
      print(player.toString());
    }
  }
}


void main(List<String> args) {
  MahjongGame game = MahjongGame(human: false);
  game.randomizeEast();
  game.startGame();
}


