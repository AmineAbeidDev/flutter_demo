import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/utilities/show_error_dialog.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/constants/routes.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController
      _password; // text controller in which the textfield writes its data and its a pipe between the textfield and the button

  @override
  void initState() {
    //flutter calls it when you create your home page
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  } //to create all your variables once

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  } // to dispose what we created

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                  await AuthService.firebase().createUser(
                    email: _email.text,
                    password: _password.text,
                  );
                  Navigator.of(context).pushNamed(
                      verifyEmailRoute); // so you can return in case of wrong email
                  await AuthService.firebase().sendEmailVerification();
                } on WeakPasswordAuthException {
                  await showErrorDialog(
                    context,
                    'weak password',
                  );
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(
                    context,
                    'email already in use',
                  );
                } on InvalidEmailAuthException {
                  await showErrorDialog(
                    context,
                    'invalid email',
                  );
                } on GenericAuthException {
                  await showErrorDialog(
                    context,
                    'Authentication exception',
                  );
                }
              },
              child: const Text('Register')),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              //Navigator.of(context).pop();
            },
            child: const Text('Already registered? Login now!'),
          ),
        ],
      )),
    );
  }
}
