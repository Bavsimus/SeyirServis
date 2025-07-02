import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart';
import 'package:seyirservis/services/auth_service.dart';

class SurucuSayfasi extends StatelessWidget {
  const SurucuSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Sürücü Paneli'),
        // Navigasyon barının sağına çıkış butonu ekliyoruz
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            // AuthService üzerinden çıkış yap
            await authService.signOut();
            // Kullanıcıyı giriş sayfasına geri yönlendir ve geçmişi temizle
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const GirisSayfasi()),
              (Route<dynamic> route) => false,
            );
          },
          child: const Icon(CupertinoIcons.square_arrow_right),
        ),
      ),
      child: const Center(
        child: Text('Burası Sürücü Sayfası'),
      ),
    );
  }
}