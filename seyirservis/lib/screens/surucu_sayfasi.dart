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
  // YENİ: Switch'in durumunu tutacak state değişkeni
  bool _isServiceActive = true; 

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

                  // --- YENİ EKLENEN BÖLÜM BAŞLANGICI ---
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Text(
                      'SERVİS DURUMU',
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
                      child: CupertinoListTile(
                        title: Text(
                          'Servis Aktif',
                           style: TextStyle(color: AppColors.primaryText.resolveFrom(context)),
                        ),
                        trailing: CupertinoSwitch(
                          value: _isServiceActive,
                          activeColor: CupertinoColors.activeGreen,
                          onChanged: (bool value) {
                            setState(() {
                              _isServiceActive = value;
                              // Konsola durumu yazdırma (opsiyonel)
                              print('Servis durumu şimdi: ${_isServiceActive ? "Aktif" : "Pasif"}');
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // --- YENİ EKLENEN BÖLÜM SONU ---


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

                          final bool isAttending = data['isAttending'] as bool? ?? false; 

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
                      // Switch'in durumuna göre butonu aktif/pasif yapabilirsiniz
                      // onPressed: _isServiceActive ? () { ... } : null,
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