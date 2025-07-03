import 'package:flutter/cupertino.dart';
import '../screens/surucu_sayfasi.dart';
import '../screens/surucu_profil_sayfasi.dart';
import '../styles/app_colors.dart';
import '../widgets/custom_tab_bar.dart';

class SurucuAnaSayfa extends StatefulWidget {
  const SurucuAnaSayfa({super.key});

  @override
  State<SurucuAnaSayfa> createState() => _SurucuAnaSayfaState();
}

class _SurucuAnaSayfaState extends State<SurucuAnaSayfa> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SurucuSayfasi(),
    const SurucuProfilSayfasi(),
  ];

  final List<TabItem> _tabItems = [
    const TabItem(icon: CupertinoIcons.list_bullet, label: 'Rota Paneli'),
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