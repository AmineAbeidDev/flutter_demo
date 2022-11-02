import 'package:notes/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
    context: context,
    content: 'Are you sure you want to delete this note?',
    title: 'Delete',
  ).then((value) => value ?? false);
}
