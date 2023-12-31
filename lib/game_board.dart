//import 'dart:ffi';

import 'package:chess/components/dead_piece.dart';
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

  // a list of white piece that have been tyaken by the black player
  List<ChessPiece> whitePieceTaken = [];

  // a list of white piece that have been tyaken by the white player
  List<ChessPiece> blackPieceTaken = [];

  //a boolean to indicat whose turn it is
  bool isWhiteTurn = true;

  //initial position of king (keep track of this to make it easir later to see if king is in checker....
  List<int>whiteKingPosition = [7, 4];
  List<int>blackKingPosition = [0, 4];
  bool checkStatus = false;


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
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagepath: 'lib/images/queen.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagepath: 'lib/images/queen.png',
    );

    //PLACE KING
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagepath: 'lib/images/king.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagepath: 'lib/images/king.png',
    );


    board=newBoard;
  }

//user selected a piece
  void pieceSelected(int row,int col ){
    setState(() {
      //no piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null){
       if(board[row][col]!.isWhite == isWhiteTurn){
         selectedPiece = board[row][col];
         selectedRow = row;
         selectedCol = col;
       }
      }

      //there is a piece alreadymselected, but user can    selected another one of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite){
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
      validMoves = calculateRealValidMoves(
        selectedRow,
        selectedCol,
        selectedPiece,
        true
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
        if((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

       //pawns can kill diagonaly
        if(isInBoard(row + direction, col -1) &&
            board[row + direction][col -1] != null &&
            board[row + direction][col -1]!.isWhite != piece.isWhite){
          candidateMoves.add(([row + direction, col -1]));
        }
        if(isInBoard(row + direction, col +1) &&
            board[row + direction][col +1] != null &&
            board[row + direction][col +1]!.isWhite != piece.isWhite){
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

  //calculate real valid moves
  List<List<int>>calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // after generating all candidate moves , filter out any that eould result in acheck
    if(checkSimulation){
      for(var move in candidateMoves){
        int endRow = move[0];
        int endCol = move[1];

        // this will simulate the future move to see if it's safe
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)){
          realValidMoves.add(move);
        }
      }
    } else{
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  // move piece
  void movePiece(int newRow, int newCol){

    // if the new spot has an enemy piece
    if (board[newRow][newCol] != null){
      // add the captured piece to the approriate list
      var capturedPice = board[newRow][newCol];
      if (capturedPice!.isWhite){
        whitePieceTaken.add(capturedPice);
      } else{
        blackPieceTaken.add(capturedPice);
      }
    }

    // check if the piece being moved in aking
    if(selectedPiece!.type == ChessPieceType.king){
      //update this appropriate king position
      if(selectedPiece!.isWhite){
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }


    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // see if any kings are under attack
    if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    } else{
      checkStatus = false;
    }

    // clear section
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    //check if it's check  mate
    if (isCheckMate(!isWhiteTurn)){
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("CHECK MATE"),
            actions: [
              //play agin button
              TextButton(
                  onPressed: resetGame,
                  child: const Text("play again"))
            ],
          )
      );
    }

    // chenge turn
    isWhiteTurn = !isWhiteTurn;
  }

  //is king in check?
  bool isKingInCheck(bool isWhiteKing){
    //get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemoy poece can attack the king
    for(int i =0; i < 8; i++){
      for(int j=0; j < 8; j++){
        //skip empty squares and piece of the same color as the king
        if(board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        // check if the king's position is tn this piece's valid moves
        if (pieceValidMoves.any((move)=>move[0] == kingPosition[0] && move[1] == kingPosition[1])){
          return true;
        }
      }
    }
    return false;
  }

  //simulaten a future move to see if it's safe (dosen't put your own king under attack
  bool simulatedMoveIsSafe(
      ChessPiece piece,
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      ){

    // save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    //if the piece is the kking , save it's current position and update to the new one
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king){
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update the king position
      if (piece.isWhite){
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own kiing is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    //if the piece was the king, restore it original position
    if(piece.type == ChessPieceType.king){
      if(piece.isWhite){
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    //if the king is in check = true, means it's not a safe move. safe move = false

    return !kingInCheck;
  }

  //is it check mate
  bool isCheckMate(bool isWhiteKing){
    //if the the king is not in check, then it's not check mate
    if (!isKingInCheck(isWhiteKing)){
      return false;
    }

    // if thre is at latest legal move for any of the player's pieces then it's not check mate
    for(int i = 0; i < 8; i++){
      for (int j = 0; j < 8; j++){
        //skip empty squares and pieces of the other color
        if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMove = calculateRealValidMoves(i, j, board[i][j], true);

        //if this piece has any valid move , then it's not checkete
        if (pieceValidMove.isNotEmpty){
          return false;
        }
      }
    }

    //if none of the above conditions are met, then there are not legal moves lafte to make
    //it's checkn mate!
    return true;
  }

  // Reset to new game
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus =false;
    whitePieceTaken.clear();
    blackPieceTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  //restsrt game
  void restsrt(){
    _initializeBoard();
    checkStatus =false;
    whitePieceTaken.clear();
    blackPieceTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          //white pieces taken
          Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: whitePieceTaken.length,
                gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context, index) =>  DeadPiece(
                  imagePath: whitePieceTaken[index].imagepath,
                  isWhite: true,
                ),
              ),
          ),

          //game status
          Text(checkStatus ? "CHECK!" :"" ),

          ElevatedButton(
              onPressed: restsrt,
              child:const Text('RESTART')
          ),

          //chess board
          Expanded(
            flex: 3,

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
          //black pieces taken
          Expanded(

            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackPieceTaken.length,
              gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) =>  DeadPiece(
                imagePath: blackPieceTaken[index].imagepath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}