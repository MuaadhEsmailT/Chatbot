import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppUser with ChangeNotifier {
  UserCredential? user;

  bool get isLoggedIn {
    return user != null;
  }
}
