import 'package:flutter/material.dart';

class EngageStatus extends StatelessWidget {
  String engageText;

  EngageStatus(this.engageText);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text(
        engageText,
        style: TextStyle(fontSize: 28),
        textAlign: TextAlign.center,
      ),
    );
  }
}
