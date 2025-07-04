import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/giris_sayfasi.dart'; // Giriş sayfasına yönlendirme için
import 'package:seyirservis/services/auth_service.dart'; // Çıkış yapmak için
import 'package:seyirservis/styles/app_colors.dart'; // Uygulama renkleri için
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore'dan veri çekmek için

class SurucuProfilSayfasi extends StatefulWidget {
  const SurucuProfilSayfasi({super.key});

  @override
  State<SurucuProfilSayfasi> createState() => _SurucuProfilSayfasiState();
}

class _SurucuProfilSayfasiState extends State<SurucuProfilSayfasi> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  User? _currentUser; // Mevcut Firebase kullanıcısı
  String? _driverName; // Sürücünün adı

  // Sürücüye özel lokasyon bilgisi için yer tutucu (örneğin servis başlangıç noktası)
  // Firestore'da 'users' koleksiyonunda sürücü dokümanında 'driverBaseLocation' alanı olduğunu varsayarız.
  String _driverBaseLocationText = "Henüz ayarlanmadı";

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Mevcut kullanıcıyı al
    _loadDriverProfileData(); // Sürücüye özel profil verilerini yükle
  }

  // Sürücüye ait profil verilerini (ad ve başlangıç konumu) Firestore'dan çeker
  Future<void> _loadDriverProfileData() async {
    // Kullanıcı yoksa veya oturum açmamışsa işlem yapma
    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          _driverName = 'Kullanıcı Yok';
          _driverBaseLocationText = 'N/A';
        });
      }
      return;
    }

    try {
      // Kullanıcının Firestore'daki dokümanını çek
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();

      // Doküman varsa ve boş değilse verileri al
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Sürücü adını çek, yoksa varsayılan bir değer ata
        _driverName = userData['name'] as String? ?? 'İsimsiz Sürücü';

        // Sürücünün servis başlangıç/ana konumunu çek (varsa)
        // Varsayım: 'driverBaseLocation' alanında string bir adres tutuluyor
        _driverBaseLocationText = userData['driverBaseLocation'] as String? ?? "Henüz ayarlanmadı";

      } else {
        // Kullanıcı dokümanı yoksa veya boşsa varsayılan değerler ata
        _driverName = 'Kullanıcı Dokümanı Yok';
        _driverBaseLocationText = 'N/A';
      }
    } catch (e) {
      // Hata durumunda konsola hata mesajını yazdır ve varsayılan değerler ata
      print("Sürücü profil verisi alınırken hata: $e");
      _driverName = 'Hata Oluştu';
      _driverBaseLocationText = 'Hata Oluştu';
    } finally {
      // Veri çekme işlemi bittiğinde UI'ı güncelle
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // Sayfa arka planı tamamen beyaz yapıldı
      backgroundColor: CupertinoColors.white,
      // Navigasyon çubuğu
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white, // Navigasyon çubuğunun arka planı beyaz yapıldı
        middle: const Text('Sürücü Profil & Ayarları'), // Sayfa başlığı
        // Çıkış butonu
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await _authService.signOut(); // Firebase'den çıkış yap
            // Giriş sayfasına yönlendir ve tüm geçmişi temizle
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (context) => const GirisSayfasi()),
                  (route) => false,
            );
          },
          child: const Icon(CupertinoIcons.square_arrow_right), // Çıkış ikonu
        ),
      ),
      child: SafeArea( // Ekranın güvenli alanına içerik yerleştirme
        child: SingleChildScrollView( // İçeriğin kaydırılabilir olmasını sağla
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                // Kullanıcı Bilgileri Bölümü
                CupertinoListSection.insetGrouped(
                  // Başlık stilini ekran görüntüsüne uygun şekilde ayarlandı
                  header: const Text(
                    'SÜRÜCÜ BİLGİLERİ',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey, // Daha silik renk
                      fontWeight: FontWeight.normal, // Kalınlık normal
                      fontSize: 13.0, // Varsayılan boyut, isteğe bağlı ayar
                    ),
                  ),
                  children: <CupertinoListTile>[
                    CupertinoListTile(
                      title: const Text('Ad Soyad'),
                      additionalInfo: Text(_driverName ?? 'Yükleniyor...'), // Sürücü adı
                      leading: const Icon(CupertinoIcons.person_alt_circle_fill), // İkon
                    ),
                    CupertinoListTile(
                      title: const Text('E-posta'),
                      additionalInfo: Text(_currentUser?.email ?? 'E-posta Yok'), // Sürücü e-postası
                      leading: const Icon(CupertinoIcons.mail_solid), // İkon
                    ),
                  ],
                ),
                // Servis Ayarları Bölümü (Sürücüye özel)
                CupertinoListSection.insetGrouped(
                  // Başlık stilini ekran görüntüsüne uygun şekilde ayarlandı
                  header: const Text(
                    'SERVİS AYARLARI',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey, // Daha silik renk
                      fontWeight: FontWeight.normal, // Kalınlık normal
                      fontSize: 13.0, // Varsayılan boyut, isteğe bağlı ayar
                    ),
                  ),
                  children: <CupertinoListTile>[
                    CupertinoListTile.notched( // Çentikli stil
                      title: const Text('Servis Başlangıç Konumum'),
                      additionalInfo: Text(_driverBaseLocationText), // Başlangıç konumu
                      leading: Icon(
                        CupertinoIcons.location_solid, // Konum ikonu
                        color: AppColors.primary.resolveFrom(context), // Tema renginden ikon rengi
                      ),
                      trailing: const CupertinoListTileChevron(), // Sağdaki ok ikonu
                      onTap: () {
                        // TODO: Sürücünün başlangıç konumunu ayarlama sayfası buraya eklenecek
                        print('Sürücü başlangıç konumunu ayarlama sayfasına git');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}