import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/auth.dart';
import 'page_map_bag.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? loginErrorMessage = '';
  String? registerErrorMessage = '';
  bool isLogin = true;
  String? profileType;
  bool isLoginPage = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();

  Widget _title() {
    return const Text('Firebase Auth');
  }

  bool _showPassword = false;
  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: title == 'Password' ? !_showPassword : false,
      decoration: InputDecoration(
        labelText: title,
        suffixIcon: title == 'Password'
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  Future<void> signInWithEmailAndPassword() async {
    final String email = _controllerEmail.text.trim();
    final String password = _controllerPassword.text.trim();

    if (email.isEmpty && password.isEmpty) {
      setState(() {
        loginErrorMessage = "Email and password can't be empty";
      });
      return;
    } else if (email.isEmpty) {
      setState(() {
        loginErrorMessage = "Email can't be empty";
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        loginErrorMessage = "Password can't be empty";
      });
      return;
    }

    try {
      await Auth().signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password') {
          loginErrorMessage = "The password that you've entered is incorrect";
        } else if (e.code == 'user-not-found') {
          loginErrorMessage = "The email that you've entered is not found";
        } else if (e.code == 'invalid-email') {
          loginErrorMessage = "The email address is badly formatted";
        } else {
          loginErrorMessage = e.message;
        }
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    final String email = _controllerEmail.text.trim();
    final String password = _controllerPassword.text.trim();
    final String username = _controllerUsername.text.trim();

    if (email.isEmpty && password.isEmpty) {
      setState(() {
        registerErrorMessage = "Email and password can't be empty";
      });
      return;
    } else if (email.isEmpty) {
      setState(() {
        registerErrorMessage = "Email can't be empty";
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        registerErrorMessage = "Password can't be empty";
      });
      return;
    } else if (profileType == null) {
      setState(() {
        registerErrorMessage = "You need to choose a profile type";
      });
      return;
    } else if (username.isEmpty) {
      setState(() {
        registerErrorMessage = "Username can't be empty";
      });
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(
        email: email,
        password: password,
        profileType: profileType!,
        username: username, // Pass the username to the method
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          registerErrorMessage = "The password needs 6 characters or more";
        } else if (e.code == 'email-already-in-use') {
          registerErrorMessage = "The email address is already in use";
        } else if (e.code == 'invalid-email') {
          registerErrorMessage = "The email address format is wrong";
        } else {
          registerErrorMessage = e.message;
        }
      });
    }
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _errorMessage() {
    if (isLogin && isLoginPage) {
      return Text(loginErrorMessage == null ? '' : '$loginErrorMessage');
    } else if (!isLogin && !isLoginPage) {
      return Text(registerErrorMessage == null ? '' : '$registerErrorMessage');
    } else {
      return const SizedBox(); // Return an empty SizedBox if not on the current page
    }
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          if (!isLogin) {
            profileType = null;
            registerErrorMessage = null; // Clear the register error message
          } else {
            loginErrorMessage = null; // Clear the login error message
          }
          isLogin = !isLogin;
          isLoginPage = !isLoginPage;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }

  Widget _profileTypeDropdown() {
    if (isLogin) {
      return Container(); // Return an empty container when in login mode
    } else {
      return DropdownButton<String>(
        value: profileType,
        hint: const Text('Choose'), // Display 'Choose' as the initial selection
        onChanged: (String? newValue) {
          setState(() {
            profileType = newValue == 'choose' ? null : newValue;
          });
        },
        items: const <DropdownMenuItem<String>>[
          DropdownMenuItem<String>(
            value: 'petugas',
            child: Text('petugas'),
          ),
          DropdownMenuItem<String>(
            value: 'pengguna',
            child: Text('pengguna'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('Email', _controllerEmail),
            _entryField('Password', _controllerPassword),
            if (!isLogin) _entryField('Username', _controllerUsername),
            _profileTypeDropdown(),
            _errorMessage(),
            _submitButton(),
            _loginOrRegisterButton(),

            // Add the navigation button here
            const SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: () {
                // Navigate to the BagPane page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapBagPage()),
                );
              },
              child: const Text('Lacak Tas tanpa login'),
            ),
          ],
        ),
      ),
    );
  }
}
