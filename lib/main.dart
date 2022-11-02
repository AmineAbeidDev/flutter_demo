import 'package:notes/services/auth/firebase_auth_provider.dart';
import 'package:notes/views/notes/create_update_note_view.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/views/verify_email_view.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/register_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      //! it injects an instance of the created to multi widgets within a subtree
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        //! Creates the bloc (will only get called when the instance is accessed)
        child: const HomePage(),
        //! Child has access to the bloc's intances via BlocProvider.of(context)
      ),
      routes: {
        // A map of strings, funcs
        loginRoute: (context) => const LoginView(), // Named routes
        notesRoute: (context) => const NotesView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const RegisterView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //! put read and then specifiy where to read from
    //! then add to notify bloc of new event
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return (BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return (const Scaffold(
            body: CircularProgressIndicator(),
          ));
        }
      },
    ));

  //   return FutureBuilder(
  //     //return an async Future
  //     future: AuthService.firebase().initialize(),
  //     builder: (context, snapshot) {
  //       switch (snapshot.connectionState) {
  //         case ConnectionState.done:
  //           final user = AuthService.firebase().currentUser;
  //           if (user != null) {
  //             // if there is a user
  //             if (user.isEmailVerified) {
  //               return const NotesView(); // if verified
  //             } else {
  //               return const VerifyEmailView(); //if not verified
  //             }
  //           } else {
  //             return const LoginView(); // if there is no user
  //           }
  //         default:
  //           return const CircularProgressIndicator();
  //       }
  //     },
  //   );
  }
}
