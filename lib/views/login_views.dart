import 'package:notes/utilities/dialogs/loading_dialog.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // text controller in which the textfield writes its data and its a pipe between the textfield and the button
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;
          //! We're not loading now but we were loading before
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
            //! if state is loading but we don't have a dialog on the screen
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle =
                showLoadingDialog(context: context, text: 'Loading...');
          }
          if (state is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User not found');
          } else if (state is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
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
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(
                        AuthEventLogIn(email, password),
                      );
                },
                child: const Text('Login')),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventShouldRegister(),
                      );
                },
                child: const Text('Not registered yet? Register now!'))
          ],
        )),
      ),
    );
  } // to dispose what we created
}
