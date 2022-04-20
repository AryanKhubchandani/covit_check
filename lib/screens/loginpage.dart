import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:covit_check/screens/homepage.dart';
import 'package:covit_check/services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 200, height: 40),
          child: ElevatedButton.icon(
            icon: const FaIcon(
              FontAwesomeIcons.google,
              color: Colors.white,
            ),
            label: const Text("Sign In with Google",
                style: TextStyle(color: Colors.white, fontSize: 14)),
            onPressed: () async {
              await _auth.signInGoogle().then(
                    (userCredential) => {
                      setState(() => {userCredential}),
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      ),
                    },
                  );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.grey,
              side: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
