import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/profil_sayfasi.dart';
import 'package:seyirservis/screens/yolcu_sayfasi.dart';
import 'package:seyirservis/styles/app_colors.dart';

class YolcuAnaSayfa extends StatefulWidget {
  const YolcuAnaSayfa({super.key});

  @override
  State<YolcuAnaSayfa> createState() => _YolcuAnaSayfaState();
}

class _YolcuAnaSayfaState extends State<YolcuAnaSayfa> {
  int _selectedIndex = 0;

  // Farklı sekmeler için sayfaları bir listede tutuyoruz.
  final List<Widget> _pages = [
    const YolcuSayfasi(),
    const ProfilSayfasi(),
  ];

  @override
  Widget build(BuildContext context) {
    // CupertinoPageScaffold yerine Stack kullanıyoruz.
    // Bu, özel navigasyon barımızı sayfa içeriğinin üzerine koymamızı sağlar.
    return CupertinoPageScaffold(
      // Arka plan renginin tüm alana yayılmasını sağlıyoruz.
      backgroundColor: AppColors.scaffoldBackground.resolveFrom(context),
      child: Stack(
        children: [
          // Aktif sayfayı gösteren bölüm
          // IndexedStack, sekmeler arasında geçiş yaparken sayfaların durumunu korur.
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // Özel navigasyon barı
          Positioned(
            left: 20,
            right: 20,
            bottom: 25, // Alttan boşluk
            child: _buildCustomTabBar(context),
          ),
        ],
      ),
    );
  }

  // Özel, kavisli navigasyon barını oluşturan metot
  Widget _buildCustomTabBar(BuildContext context) {
    final bool isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;
    final Color activeColor = AppColors.primary.resolveFrom(context);
    final Color inactiveColor = AppColors.secondaryText.resolveFrom(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(36.0), // İşte istediğiniz kavis!
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? CupertinoColors.black.withOpacity(0.4) : CupertinoColors.systemGrey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTabItem(
            icon: CupertinoIcons.map_fill,
            label: 'Harita',
            index: 0,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildTabItem(
            icon: CupertinoIcons.person_fill,
            label: 'Profil',
            index: 1,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ],
      ),
    );
  }

  // Navigasyon barındaki her bir butonu oluşturan metot
  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      // Dokunma alanını genişletmek için
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}