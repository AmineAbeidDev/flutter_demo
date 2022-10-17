import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/constants/routes.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email verification'),
      ),
      body: Column(children: [
        const Text(
            "We've sent you a verification link, please open your email and click on it"),
        const Text(
            "If you haven't received an email yet, press on the button below"),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().sendEmailVerification();
          },
          child: const Text('resend email verification'),
        ),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
              registerRoute,
              (route) => false,
            );
          },
          child: const Text('Restart'),
        )
      ]),
    );
  }
}
