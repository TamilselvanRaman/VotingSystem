import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/crypto_utils.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;
  String? _sentOtp; // For testing purposes
  String? _voteKey; // For testing purposes

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get sentOtp => _sentOtp; // Expose for UI
  String? get voteKey => _voteKey; // Expose for UI
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data()!;
        data['id'] = doc.id;

        // Auto-heal: If profile is missing official details (like Father's Name), fetch from master list
        if (data['fatherName'] == null || data['fatherName'] == "" || data['gender'] == null) {
          final voterId = data['voterId'];
          final epicNum = data['epicNumber'] ?? voterId;
          
          final masterQuery = await _db.collection('realVoterList')
              .where('epicNumber', isEqualTo: epicNum.toString().toUpperCase().trim())
              .get();
              
          if (masterQuery.docs.isNotEmpty) {
            final official = masterQuery.docs.first.data();
            
            // Populate missing fields from official source
            data['fatherName'] = official['fatherName'] ?? '';
            data['gender'] = official['gender'] ?? '';
            data['epicNumber'] = official['epicNumber'] ?? voterId;
            data['age'] = official['age'] ?? 0;
            data['pollingStation'] = official['pollingStation'] ?? '';
            data['district'] = official['address'] is Map ? official['address']['district'] : (official['district'] ?? "");
            data['state'] = official['address'] is Map ? official['address']['state'] : (official['state'] ?? "");
            data['pincode'] = official['address'] is Map ? official['address']['pincode'] : (official['pincode'] ?? "");
            
            // Sync back to Firestore 'users' collection for performance next time
            await _db.collection('users').doc(uid).update({
              'fatherName': data['fatherName'],
              'gender': data['gender'],
              'epicNumber': data['epicNumber'],
              'age': data['age'],
              'pollingStation': data['pollingStation'],
              'state': data['state'],
              'pincode': data['pincode'],
              'district': data['district'],
            });
          }
        }

        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
    notifyListeners();
  }

  String _normalizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91$clean';
    }
    if (clean.startsWith('91') && clean.length == 12) {
      return '+$clean';
    }
    return phone.startsWith('+') ? phone : '+$clean';
  }

  bool _isMockMode = true; // SET TO FALSE TO USE REAL FIREBASE SMS
  String? _mockUid;
  String? _pendingPhone; 

  Future<void> login(String phone, {String? epicNumber}) async {
    String normalizedPhone = _normalizePhone(phone);
    _pendingPhone = phone;
    _isLoading = true;
    _error = null;
    notifyListeners();

    // ============================================================
    // [TEST CODE - ALPHANUMERIC MIX]
    // Generating alphanumeric OTP: C0 R0 C1 R1 C2 R2
    // ============================================================
    _isMockMode = true;
    
    if (epicNumber != null && epicNumber.length >= 5) {
      final epic = epicNumber.toUpperCase();
      final r = math.Random(); 
      final d0 = r.nextInt(10);
      final d1 = r.nextInt(10);
      final d2 = r.nextInt(10);
      
      // Mix: EPIC[0], Rand[0], EPIC[2], Rand[1], EPIC[4], Rand[2]
      _sentOtp = "${epic[0]}$d0${epic[2]}$d1${epic[4]}$d2";
    } else {
      // Fallback for non-epic or short epic
      _sentOtp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    }
    
    _verificationId = "mock_verification_id";
    
    // Simulate a slight delay so it feels real
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    debugPrint("TEST MODE: Use code $_sentOtp to login.");
    // ============================================================

    /* 
    // ============================================================
    // [PRODUCTION CODE - COMMENTED OUT]
    // Uncomment this block when you enable Billing/Blaze Plan
    // ============================================================
    try {
      _isMockMode = false;
      await _auth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _isLoading = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = "Firebase Error: ${e.message}";
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
    // ============================================================
    */
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isMockMode) {
        // Validation for the Test flow
        if (otp.toUpperCase() == _sentOtp?.toUpperCase() || otp == "123456") {
          String normalizedPhone = _normalizePhone(_pendingPhone ?? "");
          
          // Check if user already exists in Firestore
          final query = await _db.collection('users')
              .where('phone', isEqualTo: normalizedPhone)
              .get();

          if (query.docs.isNotEmpty) {
            // Existing User: Use their real UID
            _mockUid = query.docs.first.id;
          } else {
            // New User: Create a mock UID
            _mockUid = "mock_${normalizedPhone.replaceAll('+', '')}";
          }
          
          await _loadUserProfile(_mockUid!);
          return true;
        } else {
          _error = "Incorrect Test OTP";
          return false;
        }
      }

      // PRODUCTION Firebase logic
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      _error = "Invalid OTP";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String voterId,
    required String phone,
    required String dob,
    required Map<String, dynamic> officialData,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? uid = _auth.currentUser?.uid ?? _mockUid;
      if (uid == null) throw Exception("User not authenticated");

      final userData = {
        'voterId': voterId,
        'epicNumber': officialData['epicNumber'] ?? voterId,
        'name': officialData['name'] ?? 'Voter',
        'fatherName': officialData['fatherName'] ?? '',
        'gender': officialData['gender'] ?? '',
        'dob': dob,
        'age': officialData['age'] ?? 0,
        'phone': _normalizePhone(phone),
        'address': officialData['address'] is Map 
            ? "${officialData['address']['doorNo']}, ${officialData['address']['street']}, ${officialData['address']['village']}, ${officialData['address']['district']}"
            : (officialData['address'] ?? ""),
        'district': officialData['address'] is Map ? officialData['address']['district'] : (officialData['district'] ?? ""),
        'state': officialData['address'] is Map ? officialData['address']['state'] : (officialData['state'] ?? ""),
        'pincode': officialData['address'] is Map ? officialData['address']['pincode'] : (officialData['pincode'] ?? ""),
        'constituency': officialData['constituency'] ?? "",
        'pollingStation': officialData['pollingStation'] ?? "",
        'hasVoted': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(uid).set(userData);

      final fakeData = Map<String, dynamic>.from(userData);
      fakeData['id'] = uid;
      _user = UserModel.fromJson(fakeData);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Instantly updates the local UI state after a successful vote
  void markAsVotedLocally() {
    if (_user != null) {
      // Create a new updated user model to trigger clean UI updates
      final updatedData = Map<String, dynamic>.from(_user!.toJson());
      updatedData['hasVoted'] = true;
      _user = UserModel.fromJson(updatedData);
      notifyListeners();
      debugPrint("Local UI state synced: User has voted.");
    }
  }

  Future<bool> checkVoterInApp(String voterId) async {
    try {
      final query = await _db.collection('users')
          .where('voterId', isEqualTo: voterId)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPhoneRegistered(String phone) async {
    try {
      String normalized = _normalizePhone(phone);
      final query = await _db.collection('users')
          .where('phone', isEqualTo: normalized)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyVoterIdentity(String voterId, String dob, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = await _db.collection('realVoterList')
          .where('epicNumber', isEqualTo: voterId.toUpperCase().trim())
          .get();
      
      if (query.docs.isEmpty) {
        String docId = voterId.replaceAll('/', '_').toUpperCase().trim();
        final doc = await _db.collection('realVoterList').doc(docId).get();
        if (!doc.exists) {
          _error = "Voter ID not found.";
          return null;
        }
        return doc.data();
      }

      final data = query.docs.first.data();
      return data;
    } catch (e) {
      _error = "System Error. Please try again.";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getPhoneByEpic(String epicNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = await _db.collection('users')
          .where('epicNumber', isEqualTo: epicNumber.toUpperCase().trim())
          .get();
      
      if (query.docs.isEmpty) {
        // Try voterId as fallback
        final queryFallback = await _db.collection('users')
            .where('voterId', isEqualTo: epicNumber.toUpperCase().trim())
            .get();
        
        if (queryFallback.docs.isEmpty) {
          _error = "EPIC Number not registered.";
          return null;
        }
        return queryFallback.docs.first.data()['phone'];
      }

      return query.docs.first.data()['phone'];
    } catch (e) {
      _error = "Database error. Please try again.";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  // ============================================================
  // [SECURE VOTE KEY LOGIC]
  // ============================================================
  
  /// Generates the unique vote key and "sends" it (simulated)
  void generateAndSendVoteKey() {
    if (_user == null) return;
    
    // Import here or at top of file
    // Using the utility we created
    try {
      _voteKey = CryptoUtils.generateVoteKey(
        name: _user!.name,
        epic: _user!.epicNumber,
        dob: _user!.dob,
        phone: _user!.phone,
      );
      debugPrint("SECURE VOTE KEY GENERATED: $_voteKey");
      notifyListeners();
    } catch (e) {
      debugPrint("Error generating vote key: $e");
    }
  }

  /// Verifies if the entered key matches the generated one
  bool verifyVoteKey(String input) {
    if (_voteKey == null) return false;
    return input.toUpperCase().trim() == _voteKey;
  }
}
