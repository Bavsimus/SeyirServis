// Bu dosyayı lib/services/auth_service.dart yoluna oluşturun.
// Bu servis, tüm Firebase kimlik doğrulama ve veritabanı işlemlerini tek bir yerde toplar.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // E-posta ve şifre ile giriş yapma fonksiyonu
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Hataları yakalayıp null döndürüyoruz, bu sayede arayüzde
      // kullanıcıya temiz bir mesaj gösterebiliriz.
      print('Giriş Hatası: ${e.message}');
      return null;
    }
  }

  // Kullanıcının rolünü Firestore'dan çekme fonksiyonu
  // NOT: Firestore'da "users" adında bir koleksiyonunuz ve içinde her kullanıcı
  // için 'role' alanı olan dokümanlarınız olmalı. (Örn: { 'role': 'surucu' })
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        // 'role' alanını oku ve string olarak döndür.
        return (doc.data() as Map<String, dynamic>)['role'];
      }
      // Doküman yoksa veya boşsa null döndür.
      return null;
    } catch (e) {
      print('Rol Alınamadı: $e');
      return null;
    }
  }

  // TODO: Gelecekte buraya kayıt olma fonksiyonu eklenebilir.
  // Future<User?> signUpWithEmailAndPassword(String email, String password, String role) async { ... }

  // Firebase'den çıkış yapma fonksiyonu
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
