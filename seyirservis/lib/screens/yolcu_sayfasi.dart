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

  // Yolcunun servis katılım durumunu Firestore'dan çeker (isAttending kullanıldı)
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
        // 'isAttending' alanını kullan
        final bool? isAttending = data['isAttending'];
        if (mounted) {
          setState(() {
            if (isAttending == true) {
              _attendanceStatusText = 'Bugün Servise Katılacağım';
            } else if (isAttending == false) {
              _attendanceStatusText = 'Bugün Servise Katılmayacağım';
            } else {
              // Alan yoksa veya null ise varsayılan durum
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

  // Servis katılım durumunu değiştiren metot (isAttending kullanıldı)
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
        {'isAttending': willAttend}, // 'isAttending' alanını güncelliyoruz
        SetOptions(merge: true),
      );
      if (mounted) {
        setState(() {
          _attendanceStatusText = willAttend ? 'Bugün Servise Katılacağım' : 'Bugün Servise Katılmayacağım';
        });
      }
      _showAlertDialog(
        'Başarılı',
        willAttend
            ? 'Katılım durumunuz "Katılacağım" olarak güncellendi.'
            : 'Katılım durumunuz "Katılmayacağım" olarak güncellendi.',
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

  // Uyarı diyaloğu gösterme metodu
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
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .doc('service_vehicle_1')
                    .snapshots(),
                builder: (context, snapshot) {
                  LatLng serviceLocation = const LatLng(40.7700, 29.9200); // Varsayılan Kocaeli
                  String servicePlate = "Yükleniyor...";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final geoPoint = data['location'] as GeoPoint?;
                    if (geoPoint != null) {
                      serviceLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
                    }
                    servicePlate = data['plate'] as String? ?? "Plaka Yok";
                  }

                  final List<Marker> markers = [];
                  markers.add(
                    Marker(
                      point: serviceLocation,
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primaryText.resolveFrom(context), width: 1),
                            ),
                            child: Text(
                              servicePlate,
                              style: TextStyle(
                                color: AppColors.primaryText.resolveFrom(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.bus,
                            color: AppColors.primary.resolveFrom(context),
                            size: 35,
                          ),
                        ],
                      ),
                    ),
                  );

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
              // Yükleme göstergesi
              if (_isLoading)
                const Center(
                  child: CupertinoActivityIndicator(radius: 20.0),
                ),
              // Harita kontrol butonları ve katılım durumu butonlarını içeren tek Positioned widget'ı
              Positioned(
                bottom: 70.0, // Alt navigasyon barının hemen üzerinde
                right: 20.0,
                left: 20.0, // Her iki taraftan boşluk bırakarak ortalamak için
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end, // Sağ tarafa yaslamak için
                    children: [
                      // Mevcut Durum metni
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryText.resolveFrom(context), width: 1),
                        ),
                        child: Text(
                          'Durum: $_attendanceStatusText',
                          style: TextStyle(
                            fontSize: 12, // Metin boyutunu küçült
                            color: AppColors.primaryText.resolveFrom(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Metin ile butonlar arasına boşluk

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, // Sağ tarafa yaslamak için
                        children: [
                          // "Bugün Servise Katılmayacağım" butonu
                          Expanded( // Genişliği dinamik olarak ayarla
                            child: CupertinoButton(
                              color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Paddingi küçült
                              borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlak yap
                              onPressed: _isLoading ? null : () => _toggleAttendance(false),
                              child: Text(
                                'Katılmayacağım', // Metni kısalt
                                style: TextStyle(
                                  fontSize: 12, // Yazı boyutunu küçült
                                  color: AppColors.primary.resolveFrom(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Butonlar arasına boşluk
                          // "Bugün Servise Katılacağım" butonu
                          Expanded( // Genişliği dinamik olarak ayarla
                            child: CupertinoButton(
                              color: AppColors.primary.resolveFrom(context).withOpacity(0.8), // Renk değiştirebilirsiniz
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Paddingi küçült
                              borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlak yap
                              onPressed: _isLoading ? null : () => _toggleAttendance(true),
                              child: const Text(
                                'Katılacağım', // Metni kısalt
                                style: TextStyle(
                                  fontSize: 12, // Yazı boyutunu küçült
                                  color: CupertinoColors.white, // Beyaz metin
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // Katılım butonları ile harita kontrol butonları arasına boşluk
                          // Harita kontrol butonları
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