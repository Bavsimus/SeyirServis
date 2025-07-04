import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:seyirservis/styles/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Gerekli import

class YolcuSayfasi extends StatefulWidget {
  const YolcuSayfasi({super.key});

  @override
  State<YolcuSayfasi> createState() => _YolcuSayfasiState();
}

class _YolcuSayfasiState extends State<YolcuSayfasi> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LatLng? _userLocation;
  bool _isFetchingLocation = false;
  bool _isLoading = false;
  String _attendanceStatusText = 'Yükleniyor...'; // Servis katılım durumu için metin

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _fetchAttendanceStatus(); // Katılım durumunu çekmek için güncellendi
  }

  // YENİ FONKSİYON: Araç işaretleyicisini oluşturan widget. Kod tekrarını önler.
  Widget _buildVehicleMarker(String plate, Color iconColor, Color borderColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            plate,
            style: TextStyle(
              color: AppColors.primaryText.resolveFrom(context),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        Icon(
          CupertinoIcons.bus,
          color: iconColor,
          size: 35,
        ),
      ],
    );
  }

  Future<void> _fetchUserLocation() async {
    if (_isFetchingLocation) return;
    setState(() { _isFetchingLocation = true; });

    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }
      permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }
      final locationData = await _location.getLocation();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
        });
        _mapController.move(_userLocation!, 14.0);
      }
    } finally {
      if (mounted) {
        setState(() { _isFetchingLocation = false; });
      }
    }
  }

  Future<void> _fetchAttendanceStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _attendanceStatusText = 'Giriş yapılmamış';
        });
      }
      return;
    }

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        final bool? isAttending = data['isAttending'];
        if (mounted) {
          setState(() {
            if (isAttending == true) {
              _attendanceStatusText = 'Bugün Servise Geleceğim';
            } else if (isAttending == false) {
              _attendanceStatusText = 'Bugün Servise Gelmeyeceğim';
            } else {
              _attendanceStatusText = 'Katılım Durumu Bilinmiyor';
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _attendanceStatusText = 'Doküman Bulunamadı (Varsayılan: Bilinmiyor)';
          });
        }
      }
    } catch (e) {
      print('Katılım durumu alınamadı: $e');
      if (mounted) {
        setState(() {
          _attendanceStatusText = 'Durum Hatası';
        });
      }
    }
  }

  Future<void> _toggleAttendance(bool willAttend) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showAlertDialog('Hata', 'Kullanıcı bulunamadı, lütfen tekrar giriş yapın.');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {'isAttending': willAttend},
        SetOptions(merge: true),
      );
      if (mounted) {
        setState(() {
          _attendanceStatusText = willAttend ? 'Bugün Servise Geleceğim' : 'Bugün Servise Gelmeyeceğim';
        });
      }
      _showAlertDialog(
        'Başarılı',
        willAttend
            ? 'Katılım durumunuz "Geleceğim" olarak güncellendi.'
            : 'Katılım durumunuz "Gelmeyeceğim" olarak güncellendi.',
      );
    } catch (e) {
      _showAlertDialog('Hata', 'Katılım durumu güncellenirken bir sorun oluştu: $e');
      print('Katılım durumu güncelleme hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAlertDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // DEĞİŞİKLİK: StreamBuilder artık tek bir dökümanı değil, koleksiyonun tamamını dinliyor.
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .snapshots(),
                builder: (context, snapshot) {
                  final List<Marker> markers = [];

                  if (snapshot.hasData) {
                    // Gelen tüm dökümanlar (araçlar) için bir döngü oluştur.
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final geoPoint = data['location'] as GeoPoint?;
                      
                      if (geoPoint != null) {
                        final serviceLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
                        final servicePlate = data['plate'] as String? ?? "Plaka Yok";

                        markers.add(
                          Marker(
                            point: serviceLocation,
                            width: 80,
                            height: 80,
                            child: _buildVehicleMarker(
                              servicePlate,
                              AppColors.primary.resolveFrom(context), // Ana renk
                              AppColors.primaryText.resolveFrom(context)
                            ),
                          ),
                        );
                      }
                    }
                  }

                  // Kullanıcının kendi konumunu eklemeye devam et
                  if (_userLocation != null) {
                    markers.add(
                      Marker(
                        point: _userLocation!,
                        child: const Icon(
                          CupertinoIcons.person_solid,
                          color: CupertinoColors.activeBlue,
                          size: 30,
                        ),
                      ),
                    );
                  }

                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _userLocation ?? const LatLng(40.7667, 29.9167),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.seyirservis',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  );
                },
              ),
              if (_isLoading)
                const Center(
                  child: CupertinoActivityIndicator(radius: 20.0),
                ),
              Positioned(
              bottom: 90.0,
              right: 20.0,
              left: 20.0,
              child: SafeArea(
                child: Row(
                  // Grupları dikey olarak en alta hizala.
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // --- SOL GRUP: Durum Bilgisi ve Katılım Butonları ---
                    // Bu grup, artık bir Column içeriyor ve kalan tüm boşluğu kaplıyor.
                    Expanded(
                      child: Column(
                        // Bu Column'un içindeki widget'ların genişliğini doldurmasını sağla.
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min, // Dikeyde gereksiz yer kaplamasını önle
                        children: [
                          // BİLGİ KUTUSU BURAYA TAŞINDI VE DÜZELTİLDİ
                          Container(
                            // Padding düzeltildi: Sadece dikey boşluk veriyoruz.
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primaryText.resolveFrom(context), width: 1),
                            ),
                            child: Text(
                              'Durum: $_attendanceStatusText',
                              textAlign: TextAlign.center, // Metni ortala
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryText.resolveFrom(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Bilgi kutusu ile butonlar arasına boşluk
                          const SizedBox(height: 10),

                          // Katılım Butonları Satırı
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  borderRadius: BorderRadius.circular(10),
                                  onPressed: _isLoading ? null : () => _toggleAttendance(false),
                                  child: Text(
                                    'Gelmeyeceğim',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary.resolveFrom(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CupertinoButton(
                                  color: AppColors.primary.resolveFrom(context).withOpacity(0.8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  borderRadius: BorderRadius.circular(10),
                                  onPressed: _isLoading ? null : () => _toggleAttendance(true),
                                  child: const Text(
                                    'Geleceğim',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // İki ana grup arasında boşluk bırak
                    const SizedBox(width: 16),

                    // --- SAĞ GRUP: Harita Kontrol Butonları ---
                    // Bu grup değişmeden kalıyor.
                    Column(
                      children: <Widget>[
                        CupertinoButton(
                          color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(50.0),
                          child: _isFetchingLocation
                              ? const CupertinoActivityIndicator()
                              : Icon(
                            CupertinoIcons.location_fill,
                            color: AppColors.primary.resolveFrom(context),
                          ),
                          onPressed: _fetchUserLocation,
                        ),
                        const SizedBox(height: 10),
                        CupertinoButton(
                          color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(50.0),
                          child: Icon(CupertinoIcons.add, color: AppColors.primary.resolveFrom(context)),
                          onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                        ),
                        const SizedBox(height: 10),
                        CupertinoButton(
                          color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(50.0),
                          child: Icon(CupertinoIcons.minus, color: AppColors.primary.resolveFrom(context)),
                          onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ],
    );
  }
}