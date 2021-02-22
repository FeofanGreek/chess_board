library chess_board;

export 'src/chess_board.dart';
export 'src/chess_board_controller.dart';

import 'dart:async';

import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess;
import 'dart:collection';

import 'package:chess_board/pages/play_game_page.dart';

typedef Null MoveCallback(String moveNotation);
typedef Null CheckMateCallback(String winColor);
typedef Null CheckCallback(PieceColor color);

bool switchColor=false;
String squareClick = '', squareClick2 = '';
var pieceType;
var pieceColor;
var Selected = 1;
bool firstClick = false;
bool isCheckmateW = false;
bool isCheckW = false;
bool isCheckmateB = false;
bool isCheckB = false;


List SL = ["a8",  "b8",  "c8",   "d8",  "e8",  "f8",  "g8",   "h8", "a7",  "b7", "c7",  "d7",  "e7",  "f7",  "g7",   "h7", "a6",  "b6",   "c6",  "d6",  "e6",  "f6",  "g6",  "h6","a5",  "b5",  "c5",   "d5",  "e5",  "f5",   "g5",  "h5", "a4",  "b4",   "c4",   "d4",   "e4",  "f4",  "g4",  "h4", "a3",   "b3",   "c3",    "d3",   "e3",   "f3",   "g3",   "h3",  "a2",   "b2",   "c2",   "d2",   "e2",    "f2",   "g2",    "h2",  "a1",   "b1",   "c1",    "d1",   "e1",   "f1",   "g1",  "h1"  ];
//enum Keys {a8,b8,c8,d8,e8,f8,g8,h8,a7,b7,c7,d7,e7,f7,g7,h7,a6,b6,c6,d6,e6,f6,g6,h6,a5,b5,c5,d5,e5,f5,g5,h5,a4,b4,c4,d4,e4,f4,g4,h4,a3,b3,c3,d3,e3,f3,g3,h3,a2,b2,c2,d2,e2,f2,g2,h2,a1,b1,c1,d1,e1,f1,g1,h1}
//final Map<Keys, dynamic> SLcolors = {};


class InvalidKeyError<K> extends Error {
  final Object key;
  final Set<K> keys;
  InvalidKeyError(this.key, this.keys);

  @override
  String toString() => "InvalidKeyError: $key not found in $keys";
}
class SpecialMap<K, V> extends MapMixin<K, V> {
  final Set<K> availableKeys;
  final Map<K, V> _map = {};
  SpecialMap(this.availableKeys) : assert(availableKeys != null);

  @override
  Iterable<K> get keys => _map.keys;

  @override
  void clear() => _map.clear();

  @override
  V remove(Object key) => _map.remove(key);

  @override
  V operator [](Object key) => availableKeys.contains(key)
      ? _map[key]
      : throw InvalidKeyError(key, availableKeys);

  @override
  operator []=(K key, V value) => availableKeys.contains(key)
      ? _map[key] = value
      : throw InvalidKeyError(key, availableKeys);
}
final availableKeys = {"a8",  "b8",  "c8",   "d8",  "e8",  "f8",  "g8",   "h8", "a7",  "b7", "c7",  "d7",  "e7",  "f7",  "g7",   "h7", "a6",  "b6",   "c6",  "d6",  "e6",  "f6",  "g6",  "h6","a5",  "b5",  "c5",   "d5",  "e5",  "f5",   "g5",  "h5", "a4",  "b4",   "c4",   "d4",   "e4",  "f4",  "g4",  "h4", "a3",   "b3",   "c3",    "d3",   "e3",   "f3",   "g3",   "h3",  "a2",   "b2",   "c2",   "d2",   "e2",    "f2",   "g2",    "h2",  "a1",   "b1",   "c1",    "d1",   "e1",   "f1",   "g1",  "h1"};
final SLcolors = SpecialMap<String, dynamic>(availableKeys);



Color colorSQ = Colors.transparent;

class ChessBoard extends StatefulWidget {
  // Defines the length and width of the chess board.
  final size;

  // Defines the callback on move.
  final MoveCallback onMove;

  // Defines the callback on checkmate.
  final CheckMateCallback onCheckMate;

  // Defines the callback on check.
  final CheckCallback onCheck;

  // Defines the callback on draw.
  final VoidCallback onDraw;

  // Defines what orientation to draw the board.
  // If the user is white, the white pieces face the user.
  final bool whiteSideTowardsUser;

  // A Controller to make programmatic moves instead of drag-and-drop.
  final ChessBoardController chessBoardController;

  // Disables the chessboard from user moves when set to false;
  final bool enableUserMoves;

  final List initMoves;

  ChessBoard(
      {this.size = 200.0,
        this.whiteSideTowardsUser = true,
        @required this.onMove,
        @required this.onCheckMate,
        @required this.onCheck,
        @required this.onDraw,
        this.chessBoardController,
        this.enableUserMoves = true,
        this.initMoves});

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  //chess.Chess game = chess.Chess();
  chess.Chess game = chess.Chess.fromFEN(fen);// разобрались так можно грузить свой фен

  @override
  void initState() {
    super.initState();
    if (widget.chessBoardController != null) {
      widget.chessBoardController.game = game;
      widget.chessBoardController.refreshBoard = refreshBoard;
    }

    if(widget.initMoves != null) {
      for (var i in widget.initMoves) {
        game.move({
          "from": i[0],
          "to": i[1],
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size,
      width: widget.size,
      child: Stack(
        // The base chessboard image
        children: <Widget>[
          Container(
            height: widget.size,
            width: widget.size,
            child: Image.asset(
              "images/chess_board_digits.png",
              //package: 'flutter_chess_board',
            ),
          ),

          //Overlaying draggables/ dragTargets onto the squares
          Center(
            child: Container(
              height: widget.size,
              width: widget.size,
              child: buildChessBoard(),
            ),
          )
        ],
      ),
    );
  }

  void refreshBoard() {
    setState(() {});
    if (game.in_checkmate) {
      widget.onCheckMate(game.turn == chess.Color.WHITE ? "Черные" : "Белые");
      game.turn == chess.Color.WHITE ? isCheckmateW = true : isCheckmateB = true;
      setState(() {});
      //refreshBoard();

    } else if (game.in_check) {
      game.turn == chess.Color.WHITE ? isCheckW = true : isCheckB = true;
      setState(() {});
      //refreshBoard();
    } else if (game.in_draw || game.in_stalemate) {
      widget.onDraw();
    }
  }

  Widget buildChessBoard() {
    var whiteSquareList = [
      [
        "a8",
        "b8",
        "c8",
        "d8",
        "e8",
        "f8",
        "g8",
        "h8",
      ],
      [
        "a7",
        "b7",
        "c7",
        "d7",
        "e7",
        "f7",
        "g7",
        "h7",
      ],
      [
        "a6",
        "b6",
        "c6",
        "d6",
        "e6",
        "f6",
        "g6",
        "h6",
      ],
      [
        "a5",
        "b5",
        "c5",
        "d5",
        "e5",
        "f5",
        "g5",
        "h5",
      ],
      [
        "a4",
        "b4",
        "c4",
        "d4",
        "e4",
        "f4",
        "g4",
        "h4",
      ],
      [
        "a3",
        "b3",
        "c3",
        "d3",
        "e3",
        "f3",
        "g3",
        "h3",
      ],
      [
        "a2",
        "b2",
        "c2",
        "d2",
        "e2",
        "f2",
        "g2",
        "h2",
      ],
      [
        "a1",
        "b1",
        "c1",
        "d1",
        "e1",
        "f1",
        "g1",
        "h1",
      ],
    ];

    return Column(
      children: widget.whiteSideTowardsUser
          ? whiteSquareList.map((row) {
        return ChessBoardRank(
          children: row,
          game: game,
          size: widget.size,
          onMove: widget.onMove,
          refreshBoard: refreshBoard,
          enableUserMoves: widget.enableUserMoves,
        );
      }).toList()
          : whiteSquareList.reversed.map((row) {
        return ChessBoardRank(
          children: row.reversed.toList(),
          game: game,
          size: widget.size,
          onMove: widget.onMove,
          refreshBoard: refreshBoard,
          enableUserMoves: widget.enableUserMoves,
        );
      }).toList(),
    );
  }
}

// A "Rank" is a Row on the chessboard.
class ChessBoardRank extends StatelessWidget {
  // Children are the squares in the row.
  final List<String> children;
  final chess.Chess game;
  final double size;
  final MoveCallback onMove;
  final Function refreshBoard;
  final bool enableUserMoves;

  ChessBoardRank(
      {this.children = const [],
        @required this.game,
        this.size,
        this.onMove,
        this.refreshBoard,
        this.enableUserMoves});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        children: children
            .map((squareName) => BoardSquare(
            squareName, game, size, onMove, refreshBoard, enableUserMoves))
            .toList(),
      ),
    );
  }
}

// A single square on the chessboard.
// This is a dragTarget with an optional piece displayed.
class BoardSquare extends StatefulWidget {
  final String squareName;
  final chess.Chess game;
  final double size;
  final MoveCallback onMove;
  final Function refreshBoard;
  final bool enableUserMoves;

  BoardSquare(this.squareName, this.game, this.size, this.onMove,
      this.refreshBoard, this.enableUserMoves);

  @override
  _BoardSquareState createState() => _BoardSquareState();
}

class _BoardSquareState extends State<BoardSquare> {
  @override
  Widget build(BuildContext context) {
    return
        Expanded(
              flex: 1,
              child: widget.enableUserMoves? DragTarget(builder: (context, accepted, rejected) {
              return widget.game.get(widget.squareName) != null
              ?GestureDetector(
                  onTap: () {
                    if(firstClick){
                      if (squareClick != widget.squareName) {
                        squareClick2 = widget.squareName;
                        // A way to check if move occurred.
                        chess.Color moveColor = widget.game.turn;
                        if (pieceType == "P" &&
                            ((squareClick.substring(1, 2) == "7" &&
                                squareClick2.substring(1, 2) == "8" &&
                                pieceColor.toString() == 'w') ||
                                (squareClick.substring(1, 2) == "2" &&
                                    squareClick2.substring(1, 2) == "1" &&
                                    pieceColor.toString() == 'b'))) {
                          _promotionDialog().then((value) {
                            widget.game.move({
                              "from": squareClick,
                              "to": squareClick2,
                              "promotion": value
                            });
                            pieceType = '';
                            pieceColor = '';
                            firstClick = false;
                            for(int i = 0; i < SL.length; i++) {SLcolors[SL[i]]= Colors.transparent;}
                            setState(() {});
                            widget.refreshBoard();
                          });
                        } else {
                          widget.game.move({"from": squareClick, "to": squareClick2});
                        }
                        if (widget.game.turn != moveColor) {
                          widget.onMove(pieceType == "P"
                              ? squareClick2
                              : squareClick + squareClick2);
                        }
                        pieceType = '';
                        pieceColor = '';
                        firstClick = false;
                        for(int i = 0; i < SL.length; i++) {SLcolors[SL[i]]= Colors.transparent;}
                        setState(() {});
                        widget.refreshBoard();
                      }
                    }

                  },
                  onTapDown: (d){
                    if(firstClick){
                      if (squareClick == widget.squareName) {
                        squareClick = '';
                        pieceType = '';
                        pieceColor = '';
                        firstClick = false;
                        for(int i = 0; i < SL.length; i++) {SLcolors[SL[i]]= Colors.transparent;}
                        setState(() {});
                        widget.refreshBoard();
                      }
                    }else{
                      if(widget.game.get(widget.squareName).color == widget.game.turn) {
                        //вычислить доступные ходы
                        for(int i = 0; i < SL.length; i++) {
                          bool test = widget.game.move({
                            "from": widget.squareName,
                            "to": SL[i],
                          });
                          if (test) {
                            widget.game.undo_move();
                            //print(SL[i] + 'ход доступен');
                            SLcolors[SL[i]]= Colors.blue;
                          } else {
                            //print(SL[i] + 'ход не доступен');
                            SLcolors[SL[i]]= Colors.transparent;
                          }
                          setState(() {});
                          widget.refreshBoard();
                        }
                        squareClick = widget.squareName;
                        pieceType = widget.game
                            .get(widget.squareName)
                            .type
                            .toUpperCase();
                        pieceColor = widget.game
                            .get(widget.squareName)
                            .color;
                        firstClick = true;
                        SLcolors[widget.squareName]= Colors.green;
                        setState(() {});
                      }
                    }
                  },child: Draggable(
                child: _getImageToDisplay(size: widget.size / 8),
                feedback: _getImageToDisplay(size: (1.2 * (widget.size / 8))),
                childWhenDragging: Container(),
                onDragCompleted: () {},
                data: [
                  widget.squareName,
                  widget.game.get(widget.squareName).type.toUpperCase(),
                  widget.game.get(widget.squareName).color,
                ],
              ))
                  : GestureDetector(
                  onTap: () {
                    if(firstClick){
                      squareClick2 = widget.squareName;
                      // A way to check if move occurred.
                      chess.Color moveColor = widget.game.turn;
                      if (pieceType == "P" &&
                          ((squareClick.substring(1, 2) == "7" &&
                              squareClick2.substring(1, 2) == "8" &&
                              pieceColor.toString() == 'w') ||
                              (squareClick.substring(1, 2) == "2" &&
                                  squareClick2.substring(1, 2) == "1" &&
                                  pieceColor.toString() == 'b'))) {
                        _promotionDialog().then((value) {
                          widget.game.move({
                            "from": squareClick,
                            "to": squareClick2,
                            "promotion": value
                          });
                          pieceType = '';
                          pieceColor = '';
                          firstClick = false;
                          for(int i = 0; i < SL.length; i++) {SLcolors[SL[i]]= Colors.transparent;}

                          setState(() {});
                          //colorSQ = Colors.transparent;
                          widget.refreshBoard();
                        });
                      } else {
                        widget.game.move(
                            {"from": squareClick, "to": squareClick2});
                      }
                      if (widget.game.turn != moveColor) {
                        widget.onMove(pieceType == "P"
                            ? squareClick2
                            : squareClick + squareClick2);
                      }
                      pieceType = '';
                      pieceColor = '';
                      firstClick = false;
                      for(int i = 0; i < SL.length; i++) {SLcolors[SL[i]]= Colors.transparent;}
                      isCheckmateW = false;
                      isCheckW = false;
                      isCheckmateB = false;
                      isCheckB = false;
                      setState(() {});
                      widget.refreshBoard();
                    }
                  }, child: Container(
                  decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width,
                          child: Text('')

              ));
            }, onWillAccept: (willAccept) {
              return widget.enableUserMoves ? true : false;
            }, onAccept: (List moveInfo) {
              // A way to check if move occurred.
              chess.Color moveColor = widget.game.turn;
              if (moveInfo[1] == "P" &&
                  ((moveInfo[0][1] == "7" &&
                      widget.squareName[1] == "8" &&
                      moveInfo[2] == chess.Color.WHITE) ||
                      (moveInfo[0][1] == "2" &&
                          widget.squareName[1] == "1" &&
                          moveInfo[2] == chess.Color.BLACK))) {
                _promotionDialog().then((value) {
                  widget.game.move({
                    "from": moveInfo[0],
                    "to": widget.squareName,
                    "promotion": value
                  });
                  pieceType = '';
                  pieceColor = '';
                  firstClick = false;
                  for(int i = 0; i < SL.length; i++) {SLcolors[SL[i]]= Colors.transparent;}

                  setState(() {});
                  widget.refreshBoard();
                });
              } else {
                widget.game.move({"from": moveInfo[0], "to": widget.squareName});
              }
              if (widget.game.turn != moveColor) {
                widget.onMove(moveInfo[1] == "P"
                    ? widget.squareName
                    : moveInfo[1] + widget.squareName);
              }
              pieceType = '';
              pieceColor = '';
              firstClick = false;
              for(int i = 0; i < SL.length; i++) {SLcolors[SL[i]]= Colors.transparent;}
              isCheckmateW = false;
              isCheckW = false;
              isCheckmateB = false;
              isCheckB = false;
              setState(() {});
              widget.refreshBoard();
            }): _getImageToDisplay(size: widget.size/8),
    );

  }

  Widget _getImageToDisplay({double size}) {

    Widget imageToDisplay = Container();

    if (widget.game.get(widget.squareName) == null) {
      return Container();
    }

    String piece = widget.game
        .get(widget.squareName)
        .color
        .toString()
        .substring(0, 1)
        .toUpperCase() +
        widget.game.get(widget.squareName).type.toUpperCase();

    switch (piece) {
      case "WP":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                child: WhitePawn(size: size));
        break;
      case "WR":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                child: WhiteRook(size: size));
        break;
      case "WN":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                  child: WhiteKnight(size: size));
        break;
      case "WB":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                  child: WhiteBishop(size: size));
        break;
      case "WQ":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                  child: WhiteQueen(size: size));
        break;
      case "WK":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: isCheckmateW?Colors.redAccent:isCheckW?Colors.lightBlueAccent:SLcolors[widget.squareName]),
                                child: WhiteKing(size: size));
        break;
      case "BP":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                child: BlackPawn(size: size));
        break;
      case "BR":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                child: BlackRook(size: size));
        break;
      case "BN":
        imageToDisplay = Container(
                              decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                  child: BlackKnight(size: size));
        break;
      case "BB":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                  child: BlackBishop(size: size));
        break;
      case "BQ":
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                  child: BlackQueen(size: size));
        break;
      case "BK":
        imageToDisplay = Container(
                              decoration: BoxDecoration(color: isCheckmateB?Colors.redAccent:isCheckB?Colors.lightBlueAccent:SLcolors[widget.squareName]),
                                  child: BlackKing(size: size));
        break;
      default:
        imageToDisplay = Container(
                            decoration: BoxDecoration(color: SLcolors[widget.squareName]),
                                  child: WhitePawn(size: size));
    }

    return imageToDisplay;
  }

  Future<String> _promotionDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Выберите превращение'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                child: WhiteQueen(),
                onTap: () {
                  Navigator.of(context).pop("q");
                },
              ),
              InkWell(
                child: WhiteRook(),
                onTap: () {
                  Navigator.of(context).pop("r");
                },
              ),
              InkWell(
                child: WhiteBishop(),
                onTap: () {
                  Navigator.of(context).pop("b");
                },
              ),
              InkWell(
                child: WhiteKnight(),
                onTap: () {
                  Navigator.of(context).pop("n");
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }
}

enum PieceType { Pawn, Rook, Knight, Bishop, Queen, King }

enum PieceColor {
  White,
  Black,
}

class ChessBoardController {
  chess.Chess game;
  Function refreshBoard;

  void loadFen(fen){
    game.load(fen);
    refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  }

  void makeMove(String from, String to) {
    game?.move({"from": from, "to": to});
    refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  }

  void makeMoveWithPromotion(String from, String to, String pieceToPromoteTo) {
    game?.move({"from": from, "to": to, "promotion": pieceToPromoteTo});
    refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  }

  void resetBoard() {
    game?.reset();
    refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  }

  void clearBoard() {
    game?.clear();
    refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  }

  void putPiece(PieceType piece, String square, PieceColor color) {
    game?.put(_getPiece(piece, color), square);
    refreshBoard == null ? this._throwNotAttachedException() : refreshBoard();
  }

  void _throwNotAttachedException() {
    throw Exception("Controller not attached to a ChessBoard widget!");
  }

  chess.Piece _getPiece(PieceType piece, PieceColor color) {
    chess.Color _getColor(PieceColor color) {
      return color == PieceColor.White ? chess.Color.WHITE : chess.Color.BLACK;
    }

    switch (piece) {
      case PieceType.Bishop:
        return chess.Piece(chess.PieceType.BISHOP, _getColor(color));
      case PieceType.Queen:
        return chess.Piece(chess.PieceType.QUEEN, _getColor(color));
      case PieceType.King:
        return chess.Piece(chess.PieceType.KING, _getColor(color));
      case PieceType.Knight:
        return chess.Piece(chess.PieceType.KNIGHT, _getColor(color));
      case PieceType.Pawn:
        return chess.Piece(chess.PieceType.PAWN, _getColor(color));
      case PieceType.Rook:
        return chess.Piece(chess.PieceType.ROOK, _getColor(color));
    }

    return chess.Piece(chess.PieceType.PAWN, chess.Color.WHITE);
  }
}

