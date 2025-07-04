import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth importu eklendi
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance'ı eklendi
  final FirebaseAuth _auth = FirebaseAuth.instance; // Auth instance'ı eklendi

  // DEĞİŞİKLİK: Dinlenecek araç dokümanının stream'ini tutacak state değişkeni
  Stream<DocumentSnapshot>? _vehicleStream;
  String? _activeVehicleId; // Güncelleme işlemi için araç ID'sini saklayacağız

  @override
  void initState() {
    super.initState();
    // DEĞİŞİKLİK: Sayfa açıldığında stream'i başlatan metodu çağır
    _initializeVehicleStream();
  }

  // YENİ METOT: Sürücünün aktif aracını bulup stream'i başlatan metot
  Future<void> _initializeVehicleStream() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("Sürücü girişi yapılmamış.");
      return;
    }

    try {
      // 1. Sürücünün kendi dokümanını al
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        // 2. Sürücünün dokümanından 'activeVehicle' alanını oku
        final vehicleId = userDoc.data()!['activeVehicle'] as String?;

        if (vehicleId != null) {
          if (mounted) {
            setState(() {
              _activeVehicleId = vehicleId;
              // 3. Bulunan ID ile 'services' koleksiyonundaki aracı dinlemeye başla
              _vehicleStream = _firestore.collection('services').doc(vehicleId).snapshots();
              print("Dinlenen araç ID: $vehicleId");
            });
          }
        } else {
          print("Bu sürücüye atanmış aktif bir araç bulunamadı.");
        }
      }
    } catch (e) {
      print("Araç stream'i başlatılırken hata oluştu: $e");
    }
  }

  // YENİ METOT: Firestore'daki 'isActive' değerini güncelleyen metot
  Future<void> _updateVehicleStatus(bool newStatus) async {
    if (_activeVehicleId == null) {
      print("Güncellenecek araç ID'si bulunamadı.");
      return;
    }
    try {
      await _firestore.collection('services').doc(_activeVehicleId!).update({
        'isActive': newStatus,
        'last_updated': FieldValue.serverTimestamp(), // Son güncelleme zamanını da ekleyelim
      });
      print("Araç durumu başarıyla güncellendi: $newStatus");
    } catch (e) {
      print("Araç durumu güncellenirken bir hata oluştu: $e");
    }
  }


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
                      'SERVİS DURUMU',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText.resolveFrom(context),
                      ),
                    ),
                  ),
                  // DEĞİŞİKLİK: Switch bileşeni artık StreamBuilder ile sarmalandı
                  StreamBuilder<DocumentSnapshot>(
                    stream: _vehicleStream,
                    builder: (context, vehicleSnapshot) {
                      // Yükleniyor durumu
                      if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CupertinoActivityIndicator());
                      }
                      // Hata veya veri yok durumu
                      if (!vehicleSnapshot.hasData || !vehicleSnapshot.data!.exists) {
                         return Container(
                           decoration: BoxDecoration(
                             color: AppColors.widgetBackground.resolveFrom(context),
                             borderRadius: BorderRadius.circular(12.0),
                           ),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(12.0),
                             child: const CupertinoListTile(
                               title: Text('Araç durumu yüklenemedi'),
                               trailing: Icon(CupertinoIcons.exclamationmark_circle),
                             ),
                           ),
                         );
                      }
                      
                      // Veri başarıyla geldi, 'isActive' alanını oku
                      final vehicleData = vehicleSnapshot.data!.data() as Map<String, dynamic>;
                      final bool isActive = vehicleData['isActive'] ?? false; // Varsayılan değer false

                      return Container(
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
                              value: isActive, // Değer Firestore'dan geliyor
                              activeColor: CupertinoColors.activeGreen,
                              onChanged: (bool value) {
                                // Değişiklik olduğunda Firestore'u güncelle
                                _updateVehicleStatus(value);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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