import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart';
import 'package:seyirservis/services/auth_service.dart';

class SurucuProfilSayfasi extends StatefulWidget {
  const SurucuProfilSayfasi({super.key});

  @override
  State<SurucuProfilSayfasi> createState() => _SurucuProfilSayfasiState();
}

class _SurucuProfilSayfasiState extends State<SurucuProfilSayfasi> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sürücü Profili'),
        // Güvenli çıkış butonu buraya eklendi
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await _authService.signOut();
            // rootNavigator: true, tüm tab yapısını kapatıp giriş sayfasına döner
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const GirisSayfasi()),
              (route) => false,
            );
          },
          child: const Icon(CupertinoIcons.square_arrow_right),
        ),
      ),
      child: Center(
        child: Text('Hoş Geldin, ${_currentUser?.displayName ?? 'Sürücü'}!'),
      ),
    );
  }
}

