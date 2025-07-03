import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:seyirservis/styles/app_colors.dart';

class YolcuSayfasi extends StatefulWidget {
  const YolcuSayfasi({super.key});

  @override
  State<YolcuSayfasi> createState() => _YolcuSayfasiState();
}

class _YolcuSayfasiState extends State<YolcuSayfasi> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LatLng? _userLocation;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
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
                  LatLng serviceLocation = LatLng(40.7700, 29.9200);
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
                      initialCenter: _userLocation ?? LatLng(40.7667, 29.9167),
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
              Positioned(
                bottom: 110.0,
                right: 20.0,
                child: Column(
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}