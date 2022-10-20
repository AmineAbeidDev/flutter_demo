import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

//this class and any subclasses of it are gonna be immutable
@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;

  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  }); // its a const 'cause we are not changing the initialized var

  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
  //even tho i changed the parameter to required type, the code didn't break 'cause i'm not initializing the authUer anywhere except for here
}
