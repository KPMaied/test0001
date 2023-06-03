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
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  late String _currentEmail;
  late String _currentPassword;

  @override
  void initState() {
    super.initState();
    _currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    _currentPassword = '********'; // Replace this with the actual password
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Edit Profile"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email: $_currentEmail"),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _showEmailDialog();
                    },
                    child: Text("Change Email"),
                  ),
                  SizedBox(height: 30),
                  Text("Password: $_currentPassword"),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _showPasswordDialog();
                    },
                    child: Text("Change Password"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Email"),
          content: TextFormField(
            controller: _newEmailController,
            validator: MultiValidator([
              RequiredValidator(errorText: 'Please enter a new email'),
              EmailValidator(errorText: 'Invalid email format'),
            ]),
            decoration: InputDecoration(
              labelText: 'New Email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newEmail = _newEmailController.text.trim();
                  _changeEmail(newEmail);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            validator: RequiredValidator(errorText: 'Please enter a new password'),
            decoration: InputDecoration(
              labelText: 'New Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newPassword = _newPasswordController.text.trim();
                  _changePassword(newPassword);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _changeEmail(String newEmail) {
    // Implement your logic to change the email here
    setState(() {
      _currentEmail = newEmail;
    });
    Fluttertoast.showToast(msg: "Email changed successfully");
  }

  void _changePassword(String newPassword) {
    // Implement your logic to change the password here
    setState(() {
      _currentPassword = newPassword;
    });
    Fluttertoast.showToast(msg: "Password changed successfully");
  }
}