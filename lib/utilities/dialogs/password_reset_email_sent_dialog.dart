import 'package:flutter/cupertino.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
      optionsBuilder: () => {
            'Ok': null,
          },
      context: context,
      content: 'Password reset email has been sent',
      title: 'Password reset');
}
