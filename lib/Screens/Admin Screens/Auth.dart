import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking_system/Screens/signInPage.dart';


class AuthRedirect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data!;

          Future.delayed(Duration.zero, () async {
            final role = await getUserRole(user.uid); // Implement this function

            if (role == 'Admin') {
              context.go('/adminView');
            }
          });

          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return SignInPage();
        }
      },
    );
  }

  Future<String> getUserRole(String uid) async {

    return 'Admin'; // Default role for testing
  }
}
