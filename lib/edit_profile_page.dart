import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  void _changeEmail() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Email'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'New Email',
              ),
              validator: MultiValidator([
                RequiredValidator(errorText: 'Email is required'),
                EmailValidator(errorText: 'Enter a valid email address'),
              ]),
              onChanged: (value) => _email = value,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Change'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    try {
                      await user.updateEmail(_email);
                      Fluttertoast.showToast(msg: "Email update successfully");
                      Navigator.of(context).pop();
                      setState(() {});
                    } catch (e) {
                      Fluttertoast.showToast(msg: 'Failed to update email');
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _changePassword() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              validator:
                  RequiredValidator(errorText: "Please enter your password"),
              onChanged: (value) => _password = value,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Change'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    try {
                      await user.updatePassword(_password);
                      Fluttertoast.showToast(
                          msg: 'Password updated successfully');
                      Navigator.of(context).pop();
                      setState(() {});
                    } catch (e) {
                      Fluttertoast.showToast(msg: 'Failed to update password');
                    }
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Email: ${user?.email ?? "Email not available"}'),
          ElevatedButton(
            child: Text('Change Email'),
            onPressed: _changeEmail,
          ),
          ElevatedButton(
            child: Text('Change Password'),
            onPressed: _changePassword,
          ),
        ],
      ),
    );
  }
}
