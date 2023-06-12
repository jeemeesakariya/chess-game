import 'package:chess/components/piece.dart';
import 'package:flutter/material.dart';
import 'package:chess/values/colors.dart';

class Square extends StatelessWidget{
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
  });

  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;



  @override
  Widget build(BuildContext context) {

    Color? squareColor;

    //if selected square is green
    if(isSelected){
      squareColor = Colors.green;
    }

    //otherwise it's white or black
    else{
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return Container(
      color: squareColor,
      child: piece != null ? Image.asset(
          piece!.imagepath,
          color: piece!.isWhite?  Colors.white  :  Colors.black,
      ) : null ,
      //(condition) ? (value if true) : (value if false)
    );
  }
}