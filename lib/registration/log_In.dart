import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './SignUp.dart';
import '../chatbot/chat_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _emailError = '';
  String _passwordError = '';

  Future<void> _login(String email, String password) async {
    try {
      // Sign in with email and password
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Navigate to the main screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatGPTScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _emailError = 'No user found for that email.';
          _passwordError = ''; // Clear password error if any
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _emailError = ''; // Clear email error if any
          _passwordError = 'Wrong password provided for that user.';
        });
      } else {
        setState(() {
          _emailError =
              'Login failed. Please try again.'; // Generic error message
          _passwordError = '';
        });
      }
    } catch (e) {
      setState(() {
        _emailError =
            'Login failed. Please try again.'; // Generic error message
        _passwordError = '';
      });
    }
  }

  bool _validateInputs(String email, String password) {
    bool isValid = true;

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email.';
      });
      isValid = false;
    } else {
      setState(() {
        _emailError = '';
      });
    }

    if (password.isEmpty || password.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters.';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = '';
      });
    }

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/paul-green-gohffgwydnm-unsplash-1-bg-7FF.png'),
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
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2633C5),
                        ),
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
                          border: OutlineInputBorder(
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
                          icon: Icon(Icons.lock, color: Color(0xFF2633C5)),
                          labelStyle: TextStyle(
                            color: Color(0xFF2633C5),
                            fontWeight: FontWeight.bold,
                          ),
                          errorText:
                              _passwordError.isNotEmpty ? _passwordError : null,
                          errorStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(
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
                          String email = _emailController.text;
                          String password = _passwordController.text;
                          if (_validateInputs(email, password)) {
                            _login(email, password);
                          }
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 12.0),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Create New Account',
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
