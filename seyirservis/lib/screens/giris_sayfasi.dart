import 'package:flutter/cupertino.dart';
import '../screens/surucu_ana_sayfa.dart'; // SurucuAnaSayfa'yı import edin
import '../screens/yolcu_ana_sayfa.dart'; // YolcuAnaSayfa'yı import edin
import '../services/auth_service.dart';
import '../styles/app_colors.dart';

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
        // DEĞİŞİKLİK: Doğrudan SurucuAnaSayfa'ya yönlendirme yapılıyor
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const SurucuAnaSayfa()),
        );
      } else if (role == 'yolcu') {
        // DEĞİŞİKLİK: Doğrudan YolcuAnaSayfa'ya yönlendirme yapılıyor
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const YolcuAnaSayfa()),
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

  // YENİ EKLENEN KOD: Şifremi Unuttum Metodu
  void _sifremiUnuttum() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Şifre Sıfırlama'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Şifrenizi sıfırlamak için e-posta adresinizi girin.'),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: _emailController,
              placeholder: 'E-posta',
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              padding: const EdgeInsets.all(10.0),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            child: const Text('Gönder'),
            onPressed: () async {
              Navigator.of(context).pop();

              if (_emailController.text.isEmpty) {
                _showErrorDialog('Lütfen e-posta adresinizi girin.');
                return;
              }

              setState(() { _isLoading = true; });

              String? error = await _authService.sendPasswordResetEmail(_emailController.text.trim());

              setState(() { _isLoading = false; });

              if (error == null) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Başarılı'),
                    content: Text('${_emailController.text} adresine şifre sıfırlama bağlantısı gönderildi. Lütfen e-postanızı kontrol edin.'),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text('Tamam'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              } else {
                _showErrorDialog('Şifre sıfırlama hatası: $error');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration fieldDecoration = BoxDecoration(
      color: AppColors.widgetBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(8.0),
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SeyirServis Girişş'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                decoration: fieldDecoration,
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
                decoration: fieldDecoration,
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
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: _sifremiUnuttum,
                child: Text(
                  'Şifremi Unuttum?',
                  style: TextStyle(color: AppColors.secondaryText.resolveFrom(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
