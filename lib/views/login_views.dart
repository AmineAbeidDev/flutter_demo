import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/constants/routes.dart';
import '../utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _email.text, password: _password.text); //!
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    //! try an algorithm for this
                    await showErrorDialog(
                      context,
                      'User not found',
                    );
                  } else if (e.code == 'wrong-password') {
                    await showErrorDialog(
                      context,
                      'Wrong password',
                    );
                  } else {
                    await showErrorDialog(
                      context,
                      'Error: ${e.code}',
                    );
                  }
                } catch (e) {
                  await showErrorDialog(
                    context,
                    'Error: ${e.toString()}',
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
