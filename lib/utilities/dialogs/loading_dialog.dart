import 'package:flutter/material.dart';

typedef CloseDialog = void Function();
//! we used a typedef to put this whole code in a return

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(text),
      ],
    ),
  );
  showDialog(
    context: context,
    barrierDismissible: false,
    //! do not allow the user to dismiss this by taping outside its borders
    builder: (context) => dialog,
  );
  //! it returns a function and when that returned function gets called it
  //! will pop the dialog
  return () => Navigator.of(context).pop();
}
