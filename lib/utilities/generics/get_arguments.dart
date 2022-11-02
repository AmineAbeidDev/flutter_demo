import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext {
  //* Extensions allows you to add functionalities and members to existing classes
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;
      /*
      ! if there are an argument and the argument is of the type you asked
      ! for <T> then return else fall to null
      */
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
