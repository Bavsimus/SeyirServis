import 'package:flutter/cupertino.dart';
import '../screens/yolcu_profil_sayfasi.dart';
import '../screens/yolcu_sayfasi.dart';
import '../styles/app_colors.dart';
import '../widgets/custom_tab_bar.dart'; // Ortak widget import edildi

class YolcuAnaSayfa extends StatefulWidget {
  const YolcuAnaSayfa({super.key});

  @override
  State<YolcuAnaSayfa> createState() => _YolcuAnaSayfaState();
}

class _YolcuAnaSayfaState extends State<YolcuAnaSayfa> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const YolcuSayfasi(),
    const YolcuProfilSayfasi(),
  ];

  final List<TabItem> _tabItems = [
    const TabItem(icon: CupertinoIcons.map_fill, label: 'Harita'),
    const TabItem(icon: CupertinoIcons.person_fill, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.scaffoldBackground.resolveFrom(context),
      child: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 25,
            child: CustomTabBar(
              items: _tabItems,
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}