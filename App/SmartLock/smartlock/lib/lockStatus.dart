import 'package:flutter/material.dart';

class LockStatus extends StatelessWidget {
  String lockText;

  LockStatus(this.lockText);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text(
        lockText,
        style: TextStyle(fontSize: 28),
        textAlign: TextAlign.center,
      ),
    );
  }
}
