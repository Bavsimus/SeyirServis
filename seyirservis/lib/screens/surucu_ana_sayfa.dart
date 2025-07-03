import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/surucu_sayfasi.dart';
import 'package:seyirservis/screens/surucu_profil_sayfasi.dart';
import 'package:seyirservis/styles/app_colors.dart';

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
            child: _buildCustomTabBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    final bool isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;
    final Color activeColor = AppColors.primary.resolveFrom(context);
    final Color inactiveColor = AppColors.secondaryText.resolveFrom(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.widgetBackground.resolveFrom(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(50.0),
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
            icon: CupertinoIcons.list_bullet,
            label: 'Rota Paneli',
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