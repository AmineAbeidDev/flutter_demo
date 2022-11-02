import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    optionsBuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
    context: context,
    content: 'Are you sure you want to log out?',
    title: 'Log out',
  ).then((value) => value ?? false);
}
