import 'package:flutter/cupertino.dart';
import 'package:seyirservis/styles/app_colors.dart';

// Her bir sekmenin verisini tutmak için basit bir sınıf
class TabItem {
  final IconData icon;
  final String label;

  const TabItem({required this.icon, required this.label});
}

// Yeniden kullanılabilir, kavisli navigasyon barı widget'ı
class CustomTabBar extends StatelessWidget {
  final List<TabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

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
        children: List.generate(items.length, (index) {
          final item = items[index];
          return _buildTabItem(
            context: context,
            item: item,
            isSelected: selectedIndex == index,
            onTap: () => onTap(index),
          );
        }),
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required TabItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color activeColor = AppColors.primary.resolveFrom(context);
    final Color inactiveColor = AppColors.secondaryText.resolveFrom(context);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
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