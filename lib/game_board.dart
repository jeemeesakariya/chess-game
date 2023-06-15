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

  //a list of valid move
  //each move is represented as a list with 2 element: row and col
  List<List<int>> validMoves = [];


  @override
  void initState(){
    super.initState();
    _initializeBoard();
  }

  //INITIALIZE BOARD
  void _initializeBoard(){
    //INITIALIZE THE BOARD WITH NILLS, MEANING NO PIECES IN THOSE POSITIONS
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8,(index) => null));

    //

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
  void pieceSelected(int row,int col ){
    setState(() {
      //selected a piece if ther is a piece in that position
      if(board[row][col] != null){
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // if there is a piece selected and user taps on a square that is a valid move, move there
      else if(selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)){
        movePiece(row, col);
      }

      //if piece is selected, calculate it's valid moves
      validMoves = calculateRawValidMoves(
        selectedRow,
        selectedCol,
        selectedPiece,
      );
    });
  }
  //calculate row valid moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece){
    List<List<int>> candidateMoves = [];

    if(piece == null){
      return [];
    }

    //different direction based on their color
    int direction = piece.isWhite ? -1:1;

    switch(piece.type){
      case ChessPieceType.pawn:
        // pawn can move forward if the squre ic not occupied
        if(isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
           candidateMoves.add([row + direction, col]);
        }
       //pawn can move 2 sequares forward if they are at intial positions
        if(isInBoard(row + 2 * direction,col) &&
            board[row + 2 * direction][col] == null &&
            board[row + direction][col] == null){
          candidateMoves.add([row + 2 * direction, col]);
        }

       //pawns can capture diagonaly
        if(isInBoard(row + direction, col -1) &&
            board[row + direction][col -1] != null &&
            board[row + direction][col -1]!.isWhite){
          candidateMoves.add(([row + direction, col -1]));
        }
        if(isInBoard(row + direction, col +1) &&
            board[row + direction][col +1] != null &&
            board[row + direction][col +1]!.isWhite){
          candidateMoves.add(([row + direction, col +1]));
        }


        break;
      case ChessPieceType.rook:
        //horizontal and vertical directions
      var directions = [
        [-1, 0],  //up
        [1, 0],  //down
        [0, -1],  //left
        [0, 1],   //right
      ];

      for (var direction in directions){
        var i = 1;
        while (true){
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];
          if(!isInBoard(newRow, newCol)){
            break;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]); //kill
            }
            break; //blocked
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
        break;
      case ChessPieceType.knight:
        //all eight possible l shapes the knight can move
      var knightMoves = [
        [-2, -1], // up 2 left 1
        [-2, 1], // up 2 right 1
        [-1, -2], // up 1 left 2
        [-1, 2], // up 1 right 2
        [1, -2], // down 1 left 2
        [1, 2], // down 1 right 2
        [2, -1], // down 2 left 1
        [2, 1], // down 2 right 1
      ];

      for(var move in knightMoves) {
        var newRow = row + move[0];
        var newCol = col + move[1];
        if (!isInBoard(newRow, newCol)) {
          continue;
        }
        if (board[newRow][newCol] != null) {
          if (board[newRow][newCol]!.isWhite != piece.isWhite){
            candidateMoves.add([newRow, newCol]);  // capture
          }
          continue;  // blocked
        }
        candidateMoves.add([newRow, newCol]);
      }
        break;
      case ChessPieceType.bishop:
        // diagonal directions
      var directions = [
        [-1, -1], // up left
        [-1, 1], // up right
        [1, -1], // down left
        [1, 1], // down righjt
      ];

      for (var direction in directions){
        var i = 1;
        while(true){
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];
          if(!isInBoard(newRow, newCol)){
            break;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]);  // capture
            }
            break; // blocke
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }

        break;
      case ChessPieceType.queen:
        // all eight directionsP : up, down, left, right, and 4 digonals
      var directions = [
        [-1, 0], // up
        [1, 0], // down
        [0, -1], // left
        [0, 1], // right
        [-1, -1], // up left
        [-1, 1], // up right
        [1, -1], // down left
        [1, 1], // down right
      ];

      for(var direction in directions){
        var i = 1;
        while(true){
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];
          if(!isInBoard(newRow, newCol)){
            break;
          }
          if(board[newRow][newCol] != null){
            if (board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow, newCol]); // capture
            }
            break;
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
        break;
      case ChessPieceType.king:
        // all eight directions
      var directions = [
        [-1, 0], // up
        [1, 0], // down
        [0, -1], // left
        [0, 1], // right
        [-1, -1], // up left
        [-1, 1], // up right
        [1, -1], // down left
        [1, 1], // down right
      ];

      for(var direction in directions){
        var newRow = row + direction[0];
        var newCol = col + direction[1];
        if(!isInBoard(newRow, newCol)){
          continue;
        }
        if(board[newRow][newCol] != null){
          if (board[newRow][newCol]!.isWhite != piece.isWhite){
            candidateMoves.add([newRow, newCol]); // capture
          }
          continue; // blocked
        }
        candidateMoves.add([newRow, newCol]);
      }
        break;
      default:
    }
    return candidateMoves;
  }

  // move piece
  void movePiece(int newRow, int newCol){
    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // clear section
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
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

                //check if this square is selected
                bool isSelected = selectedRow == row && selectedCol == col;

                //check if this square is a valid move
                bool isValidMove = false;
                for(var position in validMoves){
                  // compare row ans col
                  if(position[0] == row && position[1] == col){
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  onTap:() => pieceSelected(row, col),
                  isValidMove: isValidMove,
                );
              }
          ),
        ),
      ),
    );
  }
}