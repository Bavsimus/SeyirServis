import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart';
import 'package:seyirservis/services/auth_service.dart';
import 'package:seyirservis/styles/app_colors.dart';

class SurucuSayfasi extends StatefulWidget {
  const SurucuSayfasi({super.key});

  @override
  State<SurucuSayfasi> createState() => _SurucuSayfasiState();
}

class _SurucuSayfasiState extends State<SurucuSayfasi> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Rota Paneli'),
        // Güvenli çıkış butonu buraya da eklendi
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
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _authService.getPassengers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Yolcular yüklenemedi.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Sisteme kayıtlı yolcu bulunamadı.'));
                }

                final passengers = snapshot.data!;
                
                return ListView(
                  children: [
                    const SizedBox(height: 20),
                    CupertinoListSection.insetGrouped(
                      backgroundColor: AppColors.widgetBackground.resolveFrom(context),
                      header: Text(
                        'BUGÜNÜN YOLCULARI (${passengers.length} KİŞİ)',
                        style: TextStyle(color: AppColors.secondaryText.resolveFrom(context)),
                      ),
                      children: passengers.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final passengerName = data['displayName'] ?? 'İsimsiz Yolcu';
                        final attendanceStatus = 'Gelecek';
                        
                        return CupertinoListTile(
                          title: Text(
                            passengerName,
                            style: TextStyle(color: AppColors.primaryText.resolveFrom(context)),
                          ),
                          leading: Icon(
                            CupertinoIcons.person_alt,
                            color: AppColors.secondaryText.resolveFrom(context),
                          ),
                          trailing: Text(
                            attendanceStatus,
                            style: const TextStyle(color: CupertinoColors.activeGreen),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                child: const Text('Rotayı Oluştur ve Başlat'),
                onPressed: () {
                  print('Rota oluşturma işlemi başlatıldı.');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}