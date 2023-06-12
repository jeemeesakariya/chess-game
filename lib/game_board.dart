//import 'dart:ffi';

import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:chess/helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;

  //the row index of the selected piece
  //default value -1 indicated no piece is currently selected;
  int selectedRow = -1;

  //the col index of the selected piece
  //default value -1 indicated no piece is currently selected;
  int selectedCol = -1;


  @override
  void initState(){
    super.initState();
    _initializeBoard();
  }

  //INITIALIZE BOARD
  void _initializeBoard(){
    //INITIALIZE THE BOARD WITH NILLS, MEANING NO PIECES IN THOSE POSITIONS
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8,(index) => null));

    //PLACE PAWN
    for(int i=0; i<8; i++){
      newBoard[1][i] = ChessPiece(
          type: (ChessPieceType.pawn),
          isWhite: false,
          imagepath: 'lib/images/pawn.png',
      );
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagepath: 'lib/images/pawn.png',
      );
    }

    //PLACE ROOKS
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagepath: 'lib/images/rook.png',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagepath: 'lib/images/rook.png',
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagepath: 'lib/images/rook.png',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagepath: 'lib/images/rook.png',
    );

    //PLACE KNIGHTS
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagepath: 'lib/images/knight.png',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagepath: 'lib/images/knight.png',
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagepath: 'lib/images/knight.png',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagepath: 'lib/images/knight.png',
    );

    //PLACE BISHOPS
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagepath: 'lib/images/bishop.png',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagepath: 'lib/images/bishop.png',
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagepath: 'lib/images/bishop.png',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagepath: 'lib/images/bishop.png',
    );

    //PLACE QUEEN
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagepath: 'lib/images/queen.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagepath: 'lib/images/queen.png',
    );

    //PLACE KING
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagepath: 'lib/images/king.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagepath: 'lib/images/king.png',
    );


    board=newBoard;
  }

//user selected a piece
  void pieceSelected(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: InteractiveViewer(
        child: SafeArea(
          child: GridView.builder(
              itemCount: 8 * 8,
              //physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context,  index) {

                //get the row and col position of this square
                int row = index ~/ 8;
                int col = index % 8;

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: false,

                );
              }
          ),
        ),
      ),
    );
  }
}