import 'dart:math';
import 'dart:developer' as developer;

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
  List<TileSet> discardedTiles = [];
  bool human = true;

  // if ai and player can call at the same time, we add them to aiFight
  // the different difficulties change how long it takes the ai to call
  // ToDo: finish ai calling
  List<Player> aiFight = [];

  MahjongGame({this.east = PlayerDirection.down, this.human = true}) {
    turn = east;
    if (human){
      var human = Player(name: "Human", hand: deck.take(13).toList());
      deck.removeRange(0, 13);
      human.sortHand();
      playerList.add(human);
    } else {
      playerList.add(AiPlayer(name: "Down AI", hand: deck.take(13).toList(), diffLevel: Difficulty.unknowing));
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
    // print(playerList[0].hand.map((o)=>o.name).join(","));
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
    if (human && turn == PlayerDirection.down) {
      humanTurn(nextTile, draw);
    } else {
      // ai turn
      AiPlayer currentPlayer = playerList[ turn.index ] as AiPlayer;
      if (draw) {
        currentPlayer.drawnTile = nextTile;
      }
      if (currentPlayer.wonHand()) {
        developer.log("Player ${currentPlayer.name} has won:\n$currentPlayer");
        deck = [];
        finishGame();
        return;
      }
      TileSet discardedTile = currentPlayer.chooseDiscard();
      developer.log("Player '${currentPlayer.name}' is discarding ${discardedTile.name}");
      currentPlayer.discardTile(discardedTile);
      discardedTiles.add(discardedTile);
      List<Meld?> playerMelds = [];
      // do a chow/pung/kong check for everyone
      for (PlayerDirection dir in PlayerDirection.values) {
        if (( dir == PlayerDirection.down && human) || dir == turn) {
          // ignore for now
          playerMelds.add(null);
        } else {
          playerMelds.add((playerList[dir.index] as AiPlayer).decideCall(discardedTile));
        }
      }
      if (human) {
        // for now let human go first
        checkHumanCalls(discardedTile);
      }
      // if human doesnt call then first/fastest ai
      if (discardedTiles.last == discardedTile){
        aiMeldCall(playerMelds, discardedTile);
      }
      // await Future.delayed(Duration(milliseconds: 500));
    }

    turn = turn.next;
    singleTurn();
  }

  void aiMeldCall(List<Meld?> playerMelds, TileSet discardedTile) {
    // print(playerMelds);
    for (PlayerDirection dir in PlayerDirection.values) {
      if (playerMelds[dir.index] != null) {
        // player will call this meld
        Meld m = playerMelds[dir.index]!;
        m.direction = turn;
        (playerList[dir.index] as AiPlayer).addMeld(m);
        developer.log("${playerList[dir.index].name} has called ${m.type.name} on $discardedTile");
        discardedTiles.removeLast();
        turn = dir;
        singleTurn(draw: false);
        return;
      }
    }
  }
  
  void humanTurn(TileSet nextTile, bool draw) {
    Player human = playerList[ turn.index ];
    if (draw) human.drawnTile = nextTile;
    if (human.wonHand()) {
      developer.log("YOU WON!!!");
      deck = [];
      return;
    }
    developer.log("Your hand ${human.hand.map((o) => o.name).join(",")}");
    developer.log("Drawn Tile: ${nextTile.name}");
    developer.log("Your Discards: ${human.discards.map((o) => o.name).join(",")}");
    developer.log("Which tile do you want to discard?");
    developer.log("");
    List<String> possibleAnswers = human.hand.map((tile) => tile.name.toLowerCase()).toList(growable: true);
    if (human.drawnTile != null ) {
      possibleAnswers.add(human.drawnTile!.name.toLowerCase());
    }
    String? answer = _userAsk(possibleAnswers);
    TileSet discard = TileSet.playableTiles.firstWhere( (tile) => tile.name.toLowerCase() == answer!);
    human.discardTile(discard);
    discardedTiles.add(discard);
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
    developer.log(question);
    options.add("cancel");
    String? answer = _userAsk(options, false, 5);
    if (answer == null) return;
    switch(answer) {
      case "upgrade":
        List<TileSet> meldTiles = upgradablePung!.tilesInHand;
        meldTiles.add(upgradablePung.stolenTile!);
        Meld meld = Meld(type: MeldType.kong, tilesInHand: meldTiles, stolenTile: nextTile, direction: turn, fromPung: true);
        human.pungToKong(meld);
        turn = PlayerDirection.down;
        discardedTiles.removeLast();
        singleTurn(draw: false);
        break;
      case "kong":
        Meld meld = Meld(type: MeldType.kong, tilesInHand: kongList, stolenTile: nextTile, direction: turn);
        human.addMeld(meld);
        turn = PlayerDirection.down;
        discardedTiles.removeLast();
        singleTurn(draw: false);
        break;
      case "pung":
        Meld meld = Meld(type: MeldType.pung, tilesInHand: pungList, stolenTile: nextTile, direction: turn);
        human.addMeld(meld);
        turn = PlayerDirection.down;
        discardedTiles.removeLast();
        singleTurn(draw: false);
        break;
      default:
        developer.log("Not calling");
    }
  }
  
  void finishGame([PlayerDirection? winner]) {
    if (winner != null) {
      Player winningPlayer = playerList[winner.index];
      developer.log("The Winner of the game is ${winningPlayer.name}");
      developer.log(winningPlayer.toString());
    }
  }
}


void main(List<String> args) {
  MahjongGame game = MahjongGame(human: true);
  game.randomizeEast();
  game.startGame();
}


