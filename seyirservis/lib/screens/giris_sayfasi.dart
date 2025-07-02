import 'package:flutter/cupertino.dart';
import 'package:seyirservis/screens/surucu_sayfasi.dart';
import 'package:seyirservis/screens/yolcu_sayfasi.dart';
import 'package:seyirservis/services/auth_service.dart';
import 'package:seyirservis/styles/app_colors.dart'; // Renkleri kullanmak için import edildi

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({super.key});

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Giriş Hatası'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Tamam'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _girisYap() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Lütfen e-posta ve şifre alanlarını doldurun.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = await _authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      final role = await _authService.getUserRole(user.uid);
      if (role == 'surucu') {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const SurucuSayfasi()),
        );
      } else if (role == 'yolcu') {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const YolcuSayfasi()),
        );
      } else {
        _showErrorDialog('Kullanıcı rolü bulunamadı veya geçersiz.');
        _authService.signOut();
      }
    } else {
      _showErrorDialog('E-posta veya şifre hatalı.');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tekrarlanan kodu önlemek için ortak bir stil tanımlıyoruz.
    final BoxDecoration fieldDecoration = BoxDecoration(
      // Dinamik rengi mevcut tema moduna göre çözümlüyoruz.
      color: AppColors.widgetBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(8.0),
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SeyirServis Giriş'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                decoration: fieldDecoration, // Stili burada uyguluyoruz
                controller: _emailController,
                placeholder: 'E-posta',
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(CupertinoIcons.mail),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                decoration: fieldDecoration, // Stili burada uyguluyoruz
                controller: _passwordController,
                placeholder: 'Şifre',
                obscureText: true,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(CupertinoIcons.lock),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : CupertinoButton.filled(
                      onPressed: _girisYap,
                      child: const Text('Giriş Yap'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}