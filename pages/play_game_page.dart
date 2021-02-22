import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chess_board/flutter_chess_board.dart';

String fen = '8/8/8/4k3/5p2/8/6PK/8 w - - 0 1';

class PlayGamePage extends StatefulWidget {
  @override
  _PlayGamePageState createState() => _PlayGamePageState();
}

class _PlayGamePageState extends State<PlayGamePage> {
  ChessBoardController controller;
  List<String> gameMoves = [];
  var flipBoardOnMove = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller = ChessBoardController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Игра с другом"),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _buildChessBoard(),
            _buildNotationAndOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildChessBoard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: ChessBoard(
        size: MediaQuery.of(context).size.width,
        onMove: (moveNotation) {
          gameMoves.add(moveNotation);
          setState(() {});
        },
        onCheck: (winColor) {
          _showDialog();
        },
        onCheckMate: (winColor) {
          _showDialog(winColor: winColor);
        },
        onDraw: () {
          _showDialog();
        },
        chessBoardController: controller,
        whiteSideTowardsUser:
            flipBoardOnMove ? gameMoves.length % 2 == 0 ? true : false : true,
      ),
    );
  }

  Widget _buildNotationAndOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Вращать доску после хода",
                style: TextStyle(fontSize: 18.0),
              ),
              Switch(
                  value: flipBoardOnMove,
                  onChanged: (value) {
                    flipBoardOnMove = value;
                    setState(() {});
                  }),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      isCheckmateW = false;
                      isCheckW = false;
                      isCheckmateB = false;
                      isCheckB = false;
                      _resetGame();
                    },
                    child: Text("Начать заново"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      isCheckmateW = false;
                      isCheckW = false;
                      isCheckmateB = false;
                      isCheckB = false;
                      _undoMove();
                    },
                    child: Text("Вернуть ход"),
                  ),
                ),
              ),
            ],
          ),
          Container(
              //width: 60.0,
              //height: 50.0,
              padding: EdgeInsets.fromLTRB(20,10,20,10),
              child:TextFormField(
                enabled: true,
                //keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Введите Fen',
                  contentPadding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),),
                onChanged: (value){
                  setState(() {
                    fen = value;
                  });
                },
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () {
                if(fen.length > 1){loadFen(fen);}
                     },
              child: Text("Загрузить FEN"),
            ),
          ),
          Row(
            children: _buildMovesList(),
          )
        ],
      ),
    );
  }

  void _showDialog({String winColor}) {
    winColor != null
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Шах и Мат!"),
                content: new Text("$winColor победили!"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("Играсть снова"),
                    onPressed: () {
                      isCheckmateW = false;
                      isCheckW = false;
                      isCheckmateB = false;
                      isCheckB = false;
                      _resetGame();
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("Закрыть"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          )
        : showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Ничья!"),
                content: new Text("Игра окончилась в ничью!"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("Играть снова"),
                    onPressed: () {
                      _resetGame();
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("Закрыть"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
  }


  void _resetGame() {
    controller.resetBoard();
    gameMoves.clear();
    setState(() {});
  }

  void loadFen(fen){
      controller.loadFen(fen);
      gameMoves.clear();
      setState(() {});
  }

  void _undoMove() {
    controller.game.undo_move();
    if(gameMoves.length != 0)
      gameMoves.removeLast();
    setState(() {
    });
  }

  List<Widget> _buildMovesList() {
    List<Widget> children = [];

    for(int i = 0; i < gameMoves.length; i++) {
      if(i%2 == 0) {
        children.add(Text("${(i/2+ 1).toInt()}. ${gameMoves[i]} ${gameMoves.length > (i+1) ? gameMoves[i+1] : ""}"));
      }else {

      }
    }

    return children;

  }

}
