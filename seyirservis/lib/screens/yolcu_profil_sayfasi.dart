import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../screens/giris_sayfasi.dart';
import '../services/auth_service.dart';
import '../styles/app_colors.dart';

class YolcuProfilSayfasi extends StatefulWidget {
  const YolcuProfilSayfasi({super.key});

  @override
  State<YolcuProfilSayfasi> createState() => _YolcuProfilSayfasiState();
}

class _YolcuProfilSayfasiState extends State<YolcuProfilSayfasi> {
  final AuthService _authService = AuthService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

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
          // Kullanıcı bilgilerini Firestore'dan çekmek için FutureBuilder kullanıyoruz
          child: FutureBuilder<DocumentSnapshot?>(
            future: _authService.getUserDetails(_currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("Kullanıcı bilgileri bulunamadı."));
              }
              
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final displayName = userData['displayName'] ?? 'İsim Yok';
              final email = _currentUser?.email ?? 'E-posta Yok';

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildCustomListSection(
                    context: context,
                    header: 'KULLANICI BİLGİLERİ',
                    children: <Widget>[
                      CupertinoListTile(
                        title: const Text('İsim Soyisim'),
                        additionalInfo: Text(displayName),
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
              );
            },
          ),
        ),
      ],
    );
  }
}