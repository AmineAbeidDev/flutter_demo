import 'package:firebase_auth/firebase_auth.dart';
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
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email, password: password);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') print('user not found');
                }
              },
              child: const Text('Register')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                   .pushNamedAndRemoveUntil('/login/', (route) => false);
                //Navigator.of(context).pop();
              },
              child: const Text('Already registered? Login now!'))
        ],
      )),
    );
  }
}
