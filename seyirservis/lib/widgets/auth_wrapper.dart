// KOD 3: lib/widgets/auth_wrapper.dart dosyanızı güncelleyin.
// Yolcuyu artık doğrudan haritaya değil, navbar içeren ana sayfaya yönlendirecek.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart';
import 'package:seyirservis/screens/surucu_sayfasi.dart';
import 'package:seyirservis/screens/yolcu_ana_sayfa.dart'; // Güncellendi
import 'package:seyirservis/services/auth_service.dart';
import 'package:seyirservis/screens/surucu_ana_sayfa.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: authService.getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const CupertinoPageScaffold(
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }

              if (roleSnapshot.hasData) {
                final role = roleSnapshot.data;
                if (role == 'surucu') {
                  return const SurucuAnaSayfa();
                } else {
                  // Yolcuyu navbar içeren YolcuAnaSayfa'ya yönlendir
                  return const YolcuAnaSayfa(); 
                }
              }
              
              return const GirisSayfasi();
            },
          );
        }

        return const GirisSayfasi();
      },
    );
  }
}
