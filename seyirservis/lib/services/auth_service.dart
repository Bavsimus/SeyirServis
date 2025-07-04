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
      print('Giriş Hatası: ${e.message}');
      return null;
    }
  }

  // Kullanıcının rolünü Firestore'dan çekme fonksiyonu
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['role'];
      }
      return null;
    } catch (e) {
      print('Rol Alınamadı: $e');
      return null;
    }
  }

  Future<DocumentSnapshot?> getUserDetails(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print("Kullanıcı detayı alınırken hata: $e");
      return null;
    }
  }


  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Başarılıysa null döndür
    } on FirebaseAuthException catch (e) {
      print('Şifre Sıfırlama Hatası: ${e.message}');
      return e.message; // Hata mesajını döndür
    }
  }

  Future<List<QueryDocumentSnapshot>> getPassengers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'yolcu')
          .get();
      return snapshot.docs;
    } catch (e) {
      print("Yolcu listesi alınamadı: $e");
      return []; // Hata durumunda boş liste döndür
    }
  }

  // Firebase'den çıkış yapma fonksiyonu
  Future<void> signOut() async {
    await _auth.signOut();
  }
}