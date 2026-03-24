import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인증 서비스 - 침신앱에서 검증된 구조 그대로 활용
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  /// 이메일 회원가입 + Firestore 사용자 프로필 생성
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String regionCode,
    required String regionName,
    required String userType, // 'seller' | 'buyer' | 'both'
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'regionCode': regionCode,
        'regionName': regionName,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // 지역 코드 로컬 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('regionCode', regionCode);
      await prefs.setString('regionName', regionName);
    }

    return credential.user;
  }

  /// 이메일 로그인
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // 마지막 로그인 시간 업데이트
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      // 사용자 프로필에서 지역 정보 로컬 저장
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (doc.exists) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'regionCode', doc.data()?['regionCode'] ?? '');
        await prefs.setString(
            'regionName', doc.data()?['regionName'] ?? '');
      }
    }

    return credential.user;
  }

  /// 사용자 프로필 가져오기
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  /// 저장된 지역 코드 가져오기
  Future<String?> getSavedRegionCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('regionCode');
  }

  /// 저장된 지역 이름 가져오기
  Future<String?> getSavedRegionName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('regionName');
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
