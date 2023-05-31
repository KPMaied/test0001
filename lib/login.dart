import 'package:application_project_1/profile.dart';
import 'package:application_project_1/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  Profile profile = Profile(email: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  bool stayLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Login'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email"),
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Please enter your email"),
                      EmailValidator(errorText: "Invalid email format")
                    ]),
                    onSaved: (String? email) {
                      profile.email = email!;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text("Password"),
                  TextFormField(
                    validator: RequiredValidator(
                        errorText: "Please enter your password"),
                    obscureText: true,
                    onSaved: (String? password) {
                      profile.password = password!;
                    },
                  ),
                  SizedBox(height: 15),
                  CheckboxListTile(
                    title: Text("Stay Logged In"),
                    value: stayLoggedIn,
                    onChanged: (newValue) {
                      setState(() {
                        stayLoggedIn = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text("Login"),
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          formkey.currentState!.save();
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: profile.email,
                                    password: profile.password)
                                .then((value) {
                              formkey.currentState!.reset();
                              if (stayLoggedIn) {
                                FirebaseAuth.instance.setPersistence(
                                    Persistence.LOCAL);
                              }
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return Home();
                              }));
                            });
                          } on FirebaseAuthException catch (e) {
                            Fluttertoast.showToast(
                                msg: e.message!,
                                gravity: ToastGravity.CENTER);
                          }
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return RegisterPage();
                          }));
                        },
                        child: Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}