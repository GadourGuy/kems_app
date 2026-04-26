import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/authentication/models/user_model.dart';
import '../../features/role_management/screens/admin_dashboard.dart';
import '../../features/profile_management/screens/profile_screen.dart';
import '../../core/constants/constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserModel? _userModel;
  
  User? get user => _user;
  UserModel? get userModel => _userModel;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData(user.uid);
      }
      notifyListeners();
    });
  }
  
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.collectionUsers).doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!, uid);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.collectionUsers).doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? AppConstants.roleVolunteer;
      }
      return AppConstants.roleVolunteer;
    } catch (e) {
      return AppConstants.roleVolunteer;
    }
  }
  
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user != null) {
        // Create user model
        final userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
          phone: phone,
          role: AppConstants.roleVolunteer,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          profileImageUrl: '',
        );
        
        // Save to Firestore
        await _firestore.collection(AppConstants.collectionUsers).doc(user.uid).set(userModel.toMap());
        
        await user.sendEmailVerification();
        _userModel = userModel;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with that email.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }
  
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      throw Exception(message);
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
  
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      if (_user == null) throw Exception('No user logged in');
      
      final updates = {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'updatedAt': DateTime.now(),
      };
      
      await _firestore.collection(AppConstants.collectionUsers).doc(_user!.uid).update(updates);
      
      if (_userModel != null) {
        _userModel = _userModel!.copyWith(
          name: name ?? _userModel!.name,
          phone: phone ?? _userModel!.phone,
          profileImageUrl: profileImageUrl ?? _userModel!.profileImageUrl,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
  
  Widget getInitialScreen(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return const AdminDashboard();
      case AppConstants.roleOrganizer:
        return const ProfileScreen();
      case AppConstants.roleVolunteer:
        return const ProfileScreen();
      default:
        return const ProfileScreen();
    }
  }
  
  bool get isEmailVerified => _user?.emailVerified ?? false;
}