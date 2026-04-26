import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
  
  static User? get currentUser => _auth.currentUser;
}