import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/surucu_sayfasi.dart';
import 'package:seyirservis/screens/surucu_profil_sayfasi.dart';

class SurucuAnaSayfa extends StatelessWidget {
  const SurucuAnaSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Rota Paneli',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Profil',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        // Hangi sekmeye tıklandıysa, o sekmeye ait tam bir sayfa oluşturulur.
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return const SurucuSayfasi();
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return const SurucuProfilSayfasi();
            });
          default:
            return CupertinoTabView(builder: (context) {
              return const SurucuSayfasi();
            });
        }
      },
    );
  }
}