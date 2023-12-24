import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './log_In.dart';
import '../chatbot/chat_screen.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _fullNameError = '';
  String _emailError = '';
  String _passwordError = '';

  bool _validateInputs() {
    bool isValid = true;

    if (_fullNameController.text.isEmpty) {
      setState(() {
        _fullNameError = 'Please enter your full name.';
      });
      isValid = false;
    } else {
      setState(() {
        _fullNameError = '';
      });
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address.';
      });
      isValid = false;
    } else if (!_emailController.text.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email address.';
      });
      isValid = false;
    } else {
      setState(() {
        _emailError = '';
      });
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Please enter a password.';
      });
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Password should be at least 6 characters long.';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = '';
      });
    }

    return isValid;
  }

  Future<void> _signUp(String fullName, String email, String password) async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _fullNameError = '';
      _emailError = '';
      _passwordError = '';
    });

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sign-up successful, navigate to the QuestionnairePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatGPTScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _fullNameError = '';
        _emailError = '';
        _passwordError = '';
      });

      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          setState(() {
            _passwordError = 'The password is too weak.';
          });
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            _emailError = 'The email is already in use.';
          });
        } else {
          setState(() {
            _emailError = 'Invalid email.';
          });
        }
      } else {
        setState(() {
          _emailError = 'An error occurred. Please try again later.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/paul-green-gohffgwydnm-unsplash-1-bg-7FF.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5.0,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 50.0),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          icon: Icon(
                            Icons.person,
                            color: Color(0xFF2633C5),
                          ),
                          labelStyle: TextStyle(
                            color: Color(0xFF2633C5),
                            fontWeight: FontWeight.bold,
                          ),
                          errorText:
                              _fullNameError.isNotEmpty ? _fullNameError : null,
                          errorStyle: TextStyle(color: Colors.red),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          icon: Icon(
                            Icons.email,
                            color: Color(0xFF2633C5),
                          ),
                          labelStyle: TextStyle(
                            color: Color(0xFF2633C5),
                            fontWeight: FontWeight.bold,
                          ),
                          errorText:
                              _emailError.isNotEmpty ? _emailError : null,
                          errorStyle: TextStyle(color: Colors.red),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          icon: Icon(
                            Icons.lock,
                            color: Color(0xFF2633C5),
                          ),
                          labelStyle: TextStyle(
                            color: Color(0xFF2633C5),
                            fontWeight: FontWeight.bold,
                          ),
                          errorText:
                              _passwordError.isNotEmpty ? _passwordError : null,
                          errorStyle: TextStyle(color: Colors.red),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                        obscureText: true,
                      ),
                      SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: () {
                          _signUp(
                            _fullNameController.text,
                            _emailController.text,
                            _passwordController.text,
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF2633C5),
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 2.0,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Already have an Account? Log In',
                          style: TextStyle(
                            color: Color(0xFF2633C5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
