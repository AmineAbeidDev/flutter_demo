import 'package:notes/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/cupertino.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
      optionsBuilder: () => {
            'Ok': null,
          },
      context: context,
      content: 'You cannot share an empty note!',
      title: 'Sharing');
}
