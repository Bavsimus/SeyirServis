import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart';
import 'package:seyirservis/services/auth_service.dart';
import 'package:seyirservis/styles/app_colors.dart';

class ProfilSayfasi extends StatefulWidget {
  const ProfilSayfasi({super.key});

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // Özel liste bölümünü oluşturan yardımcı metot
  Widget _buildCustomListSection({
    required BuildContext context,
    required String header,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text(
              header.toUpperCase(),
              // HATA DÜZELTİLDİ: 'footnote' yerine geçerli bir stil kullanıldı.
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText.resolveFrom(context),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              color: AppColors.widgetBackground.resolveFrom(context),
              child: Column(
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoNavigationBar(
          middle: const Text('Profil & Ayarlar'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => const GirisSayfasi()),
                (route) => false,
              );
            },
            child: const Icon(CupertinoIcons.square_arrow_right),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _buildCustomListSection(
                context: context,
                header: 'KULLANICI BİLGİLERİ',
                children: <Widget>[
                  CupertinoListTile(
                    title: const Text('İsim Soyisim'),
                    additionalInfo: Text(_currentUser?.displayName ?? 'İsim Yok'),
                    leading: const Icon(CupertinoIcons.person_alt_circle_fill),
                  ),
                  // HATA DÜZELTİLDİ: Material 'Divider' yerine 'Container' ile ayırıcı yapıldı.
                  Padding(
                    padding: const EdgeInsets.only(left: 58.0),
                    child: Container(
                      height: 0.5,
                      color: CupertinoColors.separator.resolveFrom(context),
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text('E-posta'),
                    additionalInfo: Text(_currentUser?.email ?? 'E-posta Yok'),
                    leading: const Icon(CupertinoIcons.mail_solid),
                  ),
                ],
              ),
              _buildCustomListSection(
                context: context,
                header: 'SERVİS AYARLARI',
                children: <Widget>[
                  CupertinoListTile(
                    title: const Text('Servise Alınma Konumum'),
                    additionalInfo: const Text('Henüz ayarlanmadı'),
                    leading: Icon(
                      CupertinoIcons.location_solid,
                      color: AppColors.primary.resolveFrom(context),
                    ),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      print('Konum seçme sayfasına git');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
