import 'package:flutter/cupertino.dart';
import 'package:seyirservis/styles/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seyirservis/widgets/auth_wrapper.dart'; // Yeni yönlendiriciyi import ediyoruz
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'SeyirServis',
      theme: const CupertinoThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        barBackgroundColor: AppColors.widgetBackground,
        
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            color: AppColors.primaryText,
            fontFamily: '.SF Pro Text',
          ),
          pickerTextStyle: TextStyle(
            color: AppColors.secondaryText,
          ),
        ),
      ),
      // Uygulama başlangıcını AuthWrapper'a devrediyoruz.
      home: const AuthWrapper(),
    );
  }
}
