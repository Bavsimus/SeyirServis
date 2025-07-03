import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
    // Sayfa artık bir tab içinde gösterildiği için, kendi Scaffold'u yerine
    // içeriği ve üst navigasyon barını bir Column içinde döndürüyoruz.
    return Column(
      children: [
        const CupertinoNavigationBar(
          middle: Text('Rota Paneli'),
        ),
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
              
              // ListView'ı tüm içeriği kapsayacak şekilde güncelliyoruz.
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  const SizedBox(height: 20),
                  // Başlık
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Text(
                      'BUGÜNÜN YOLCULARI (${passengers.length} KİŞİ)',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText.resolveFrom(context),
                      ),
                    ),
                  ),
                  // Yolcu listesi
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.widgetBackground.resolveFrom(context),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Column(
                        children: passengers.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final passengerName = data['displayName'] ?? 'İsimsiz Yolcu';
                          final attendanceStatus ='Gelecek';
                          
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
                    ),
                  ),
                  const SizedBox(height: 30), // Butonla liste arasına boşluk
                  // Rota oluşturma butonu artık ListView'ın içinde
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      child: const Text('Rotayı Oluştur ve Başlat'),
                      onPressed: () {
                        print('Rota oluşturma işlemi başlatıldı.');
                      },
                    ),
                  ),
                  // EN ÖNEMLİ KISIM: Alttaki navigasyon barı için boşluk
                  const SizedBox(height: 120),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}