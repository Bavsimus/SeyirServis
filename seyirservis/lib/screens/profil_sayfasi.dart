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
    // Sayfa ilk açıldığında mevcut kullanıcıyı al
    _currentUser = FirebaseAuth.instance.currentUser;
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
        // Sayfanın geri kalan içeriği
        Expanded(
          // ListView'ı bir Container ile sararak arka plan rengini belirliyoruz.
          child: Container(
            child: ListView(
              children: [
                const SizedBox(height: 10),
                // Kullanıcı Bilgileri Bölümü
                CupertinoListSection.insetGrouped(
                  header: const Text('KULLANICI BİLGİLERİ'),
                  children: <CupertinoListTile>[
                    CupertinoListTile(
                      title: const Text('İsim Soyisim'),
                      additionalInfo: Text(_currentUser?.displayName ?? 'İsim Yok'),
                      leading: const Icon(CupertinoIcons.person_alt_circle_fill),
                    ),
                    CupertinoListTile(
                      title: const Text('E-posta'),
                      additionalInfo: Text(_currentUser?.email ?? 'E-posta Yok'),
                      leading: const Icon(CupertinoIcons.mail_solid),
                    ),
                  ],
                ),
                // Konum Ayarları Bölümü
                CupertinoListSection.insetGrouped(
                  header: const Text('SERVİS AYARLARI'),
                  children: <CupertinoListTile>[
                    CupertinoListTile.notched(
                      title: const Text('Servise Alınma Konumum'),
                      // TODO: Buraya Firestore'dan gelen adres yazılacak
                      additionalInfo: const Text('Henüz ayarlanmadı'),
                      leading: Icon(
                        CupertinoIcons.location_solid,
                        color: AppColors.primary.resolveFrom(context),
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        // TODO: Harita üzerinden konum seçme sayfası açılacak
                        print('Konum seçme sayfasına git');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
