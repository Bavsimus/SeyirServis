import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart';
import 'package:seyirservis/screens/surucu_sayfasi.dart';
import 'package:seyirservis/screens/yolcu_sayfasi.dart';
import 'package:seyirservis/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    // Firebase'in anlık kimlik doğrulama durumunu dinliyoruz.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Bağlantı kuruluyor...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        // Giriş yapmış bir kullanıcı var mı?
        if (snapshot.hasData) {
          // Evet, var. Şimdi rolünü alalım.
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: authService.getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              // Rol bilgisi bekleniyor...
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const CupertinoPageScaffold(
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }

              // Rol bilgisi geldi.
              if (roleSnapshot.hasData) {
                final role = roleSnapshot.data;
                if (role == 'surucu') {
                  return const SurucuSayfasi();
                } else {
                  // Varsayılan olarak veya rol 'yolcu' ise
                  return const YolcuSayfasi();
                }
              }
              
              // Rol alınamadıysa veya bir hata oluştuysa, giriş sayfasına yönlendir.
              return const GirisSayfasi();
            },
          );
        }

        // Giriş yapmış kullanıcı yok, giriş sayfasını göster.
        return const GirisSayfasi();
      },
    );
  }
}