import 'package:notes/services/auth/firebase_auth_provider.dart';
import 'package:notes/views/notes/create_update_note_view.dart';
import 'package:notes/helpers/loading/loading_screen.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/views/forgot_password_view.dart';
import 'package:notes/views/verify_email_view.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/register_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/views/login_views.dart';
import 'package:notes/constants/routes.dart';
import 'package:flutter/material.dart';

//! if you wanna use something independent from the navigation stack and on the top of it you should use overlays
void main() {
  WidgetsFlutterBinding.ensureInitialized(); //?
  runApp(
    //! Runs the root widget
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      //! it injects an instance of the created to multi widgets within a subtree
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        //! Creates the bloc (will only get called when the instance is accessed)
        child: const HomePage(),
        //! Child has access to all the intances of BLoC
      ),
      routes: {
        // A map of strings, funcs
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //! reads from AuthBloc
    //! then add to notify bloc of new event
    context.read<AuthBloc>().add(const AuthEventInitialize());
    //! Builds new widget according to state type changes
    return (BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else {
          return (const Scaffold(
            body: CircularProgressIndicator(),
          ));
        }
      },
    ));
  }
}
