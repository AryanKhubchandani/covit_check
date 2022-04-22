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
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("CoVIT Check",
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 14.0),
                child: Text("Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    )),
              ),
              const Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text("Teacher's Portal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 100.0),
                child: Image.asset(
                  'assets/images/mask.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints.tightFor(width: 260, height: 52),
                  child: ElevatedButton.icon(
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.greenAccent,
                    ),
                    label: const Text("Sign In with Google",
                        style: TextStyle(color: Colors.black, fontSize: 18)),
                    onPressed: () async {
                      await _auth.signInGoogle().then(
                            (userCredential) => {
                              setState(() => {userCredential}),
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                              ),
                            },
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      primary: Colors.white,
                      side: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
