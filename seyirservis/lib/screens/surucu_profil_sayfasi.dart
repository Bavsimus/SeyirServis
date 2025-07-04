import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart';
import 'package:seyirservis/services/auth_service.dart';
import 'package:seyirservis/styles/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurucuProfilSayfasi extends StatefulWidget {
  const SurucuProfilSayfasi({super.key});

  @override
  State<SurucuProfilSayfasi> createState() => _SurucuProfilSayfasiState();
}

class _SurucuProfilSayfasiState extends State<SurucuProfilSayfasi> {
  final AuthService _authService = AuthService();
  // DEĞİŞİKLİK: Sadece mevcut kullanıcıyı tutmak yeterli.
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // KALDIRILDI: Bu state değişkenlerine artık gerek yok. Veriler FutureBuilder'dan gelecek.
  // String? _driverName;
  // String _driverBaseLocationText = "Henüz ayarlanmadı";

  // KALDIRILDI: _loadDriverProfileData metodu artık kullanılmıyor.
  // Future<void> _loadDriverProfileData() async { ... }
  
  // YENİ: yolcu_profil_sayfasi.dart'dan alınan özelleştirilmiş liste bölümü metodu.
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
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // DEĞİŞİKLİK: Sayfa yapısı Column ve Expanded ile yeniden düzenlendi.
    return Column(
      children: [
        CupertinoNavigationBar(
          middle: const Text('Sürücü Profil & Ayarları'),
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
          // DEĞİŞİKLİK: Tüm içerik artık FutureBuilder ile yönetiliyor.
          child: FutureBuilder<DocumentSnapshot?>(
            future: _currentUser != null ? _authService.getUserDetails(_currentUser!.uid) : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Hata: ${snapshot.error}"));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("Sürücü bilgileri bulunamadı."));
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final driverName = userData['name'] as String? ?? 'İsimsiz Sürücü';
              final driverBaseLocationText = userData['driverBaseLocation'] as String? ?? "Henüz ayarlanmadı";
              final email = _currentUser?.email ?? 'E-posta Yok';
              
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  // DEĞİŞİKLİK: Standart liste yerine özelleştirilmiş liste kullanılıyor.
                  _buildCustomListSection(
                    context: context,
                    header: 'SÜRÜCÜ BİLGİLERİ',
                    children: <Widget>[
                      CupertinoListTile(
                        title: const Text('Ad Soyad'),
                        additionalInfo: Text(driverName),
                        leading: const Icon(CupertinoIcons.person_alt_circle_fill),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 58.0),
                        child: Container(height: 0.5, color: CupertinoColors.separator.resolveFrom(context)),
                      ),
                      CupertinoListTile(
                        title: const Text('E-posta'),
                        additionalInfo: Text(email),
                        leading: const Icon(CupertinoIcons.mail_solid),
                      ),
                    ],
                  ),
                   _buildCustomListSection(
                    context: context,
                    header: 'SERVİS AYARLARI',
                    children: <Widget>[
                      CupertinoListTile(
                        title: const Text('Servis Başlangıç Konumum'),
                        additionalInfo: Text(driverBaseLocationText),
                        leading: Icon(
                          CupertinoIcons.location_solid,
                          color: AppColors.primary.resolveFrom(context),
                        ),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          print('Sürücü başlangıç konumunu ayarlama sayfasına git');
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}