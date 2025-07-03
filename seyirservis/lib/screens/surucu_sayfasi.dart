import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import '../styles/app_colors.dart';

class SurucuSayfasi extends StatefulWidget {
  const SurucuSayfasi({super.key});

  @override
  State<SurucuSayfasi> createState() => _SurucuSayfasiState();
}

class _SurucuSayfasiState extends State<SurucuSayfasi> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
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
              
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  const SizedBox(height: 20),
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
                          
                          // --- DEĞİŞİKLİK BURADA ---
                          // Firestore'dan 'isAttending' bool değerini oku
                          final bool isAttending = data['isAttending'] as bool? ?? false; // Varsayılan: gelmiyor
                          
                          final String attendanceStatus = isAttending ? 'Gelecek' : 'Gelmeyecek';
                          final Color statusColor = isAttending ? CupertinoColors.activeGreen : CupertinoColors.systemRed;

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
                              style: TextStyle(color: statusColor),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      child: const Text('Rotayı Oluştur ve Başlat'),
                      onPressed: () {
                        print('Rota oluşturma işlemi başlatıldı.');
                      },
                    ),
                  ),
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