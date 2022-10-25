import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/views/notes/new_note_view.dart';
import 'package:notes/views/verify_email_view.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/register_view.dart';
import 'package:notes/views/login_views.dart';
import 'package:notes/constants/routes.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //?
  runApp(
    //! Runs the root widget
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomePage(),
      routes: {
        // A map of strings, funcs
        loginRoute: (context) => const LoginView(), // Named routes
        notesRoute: (context) => const NotesView(),
        newNoteRoute: (context) => const NewNoteView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const RegisterView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //return an async Future
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              // if there is a user
              if (user.isEmailVerified) {
                return const NotesView(); // if verified
              } else {
                return const VerifyEmailView(); //if not verified
              }
            } else {
              return const LoginView(); // if there is no user
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
