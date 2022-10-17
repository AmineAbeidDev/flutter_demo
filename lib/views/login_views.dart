import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/utilities/show_error_dialog.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/constants/routes.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController
      _password;// text controller in which the textfield writes its data and its a pipe between the textfield and the button

  @override
  void initState() {
    //flutter calls it when you create your home page
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  } //to create all your variables once

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: (Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),
          TextButton(
              onPressed: () async {
                try {
                  await AuthService.firebase().logIn(
                    email: _email.text,
                    password: _password.text,
                  );
                  if (AuthService.firebase().currentUser?.isEmailVerified ??
                      false) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  }
                } on UserNotFoundAuthException {
                  await showErrorDialog(
                    context,
                    'User not found',
                  );
                } on WrongPasswordAuthException {
                  await showErrorDialog(
                    context,
                    'Wrong password',
                  );
                } on GenericAuthException {
                  await showErrorDialog(
                    context,
                    'Authentication error',
                  );
                }
              },
              child: const Text('Login')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                ); // pushes a route on the screen and removes everything behind and that what false means
              },
              child: const Text('Not registered yet? Register now!'))
        ],
      )),
    );
  } // to dispose what we created
}
