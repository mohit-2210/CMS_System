import 'package:flutter/material.dart';
import 'package:cms/models/user_model.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:cms/user_role.dart';
import 'package:cms/admin_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@NowaGenerated()
class AuthService extends ChangeNotifier {
  AuthService() {
    _initializeService();
  }

  factory AuthService.of(BuildContext context) {
    return Provider.of<AuthService>(context, listen: false);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  List<UserModel> get allAdmins =>
      _allUsers.where((u) => u.role == UserRole.admin).toList();

  List<UserModel> get approvedAdmins => _allUsers
      .where((u) => u.role == UserRole.admin && u.status == AdminStatus.approved)
      .toList();

  List<UserModel> get pendingAdmins => _allUsers
      .where((u) => u.role == UserRole.admin && u.status == AdminStatus.pending)
      .toList();

  List<UserModel> get rejectedAdmins => _allUsers
      .where((u) => u.role == UserRole.admin && u.status == AdminStatus.rejected)
      .toList();

  Future<void> _initializeService() async {
    _isLoading = true;
    notifyListeners();

    // Listen to all users changes
    _firestore.collection('users').snapshots().listen((snapshot) {
      _allUsers = snapshot.docs
          .map((doc) => UserModel.fromJson({...doc.data(), 'phone': doc.id}))
          .toList();
      notifyListeners();
    });

    // Check for saved login in SharedPreferences
    await _checkSavedLogin();

    _isLoading = false;
    notifyListeners();
  }

  /// Check if there's a saved login session
  Future<void> _checkSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString('logged_in_phone');
      
      if (savedPhone != null && savedPhone.isNotEmpty) {
        await _loadCurrentUser(savedPhone);
      }
    } catch (e) {
      debugPrint('Error checking saved login: $e');
    }
  }

  /// Save login session to SharedPreferences
  Future<void> _saveLoginSession(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_phone', phone);
    } catch (e) {
      debugPrint('Error saving login session: $e');
    }
  }

  /// Clear login session from SharedPreferences
  Future<void> _clearLoginSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('logged_in_phone');
    } catch (e) {
      debugPrint('Error clearing login session: $e');
    }
  }

  Future<void> _loadCurrentUser(String phone) async {
    try {
      final doc = await _firestore.collection('users').doc(phone).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson({...doc.data()!, 'phone': phone});
        notifyListeners();
      } else {
        // User was deleted, clear session
        await _clearLoginSession();
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  Future<UserModel?> getUser(String phone) async {
    try {
      final doc = await _firestore.collection('users').doc(phone).get();
      if (doc.exists) {
        return UserModel.fromJson({...doc.data()!, 'phone': phone});
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> login(String phone) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await getUser(phone);

      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'action': 'register',
          'message': 'User not found. Please register.',
        };
      }

      _currentUser = user;
      
      // Save login session to SharedPreferences
      await _saveLoginSession(phone);
      
      notifyListeners();
      _isLoading = false;
      notifyListeners();

      if (user.role == UserRole.superAdmin) {
        return {'success': true, 'action': 'super_admin_dashboard', 'user': user};
      }

      if (user.status == AdminStatus.approved) {
        return {'success': true, 'action': 'admin_dashboard', 'user': user};
      }

      if (user.status == AdminStatus.rejected) {
        return {
          'success': false,
          'action': 'rejected',
          'message': 'Your access request has been rejected by Super Admin.',
          'user': user
        };
      }

      return {
        'success': false,
        'action': 'pending',
        'message': 'Your request is pending approval from Super Admin.'
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return {'success': false, 'action': 'error', 'message': 'Login failed: $e'};
    }
  }

  Future<bool> registerAdmin(String phone, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      final existingUser = await getUser(phone);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newAdmin = UserModel(
        phone: phone,
        name: name,
        role: UserRole.admin,
        status: AdminStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(phone).set({
        'name': name,
        'role': UserRole.admin.toString(),
        'status': AdminStatus.pending.toString(),
        'createdAt': newAdmin.createdAt.toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> approveAdmin(String phone) async {
    try {
      await _firestore.collection('users').doc(phone).update({
        'status': AdminStatus.approved.toString(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Approve error: $e');
      rethrow;
    }
  }

  Future<void> rejectAdmin(String phone) async {
    try {
      await _firestore.collection('users').doc(phone).update({
        'status': AdminStatus.rejected.toString(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Reject error: $e');
      rethrow;
    }
  }

  Future<void> removeAdmin(String phone) async {
    try {
      await _firestore.collection('users').doc(phone).delete();
      
      if (_currentUser?.phone == phone) {
        _currentUser = null;
        await _clearLoginSession();
        notifyListeners();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Remove error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearLoginSession();
    notifyListeners();
  }
}