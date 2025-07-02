import 'package:flutter/cupertino.dart';

class AppColors {
  AppColors._();

  // --- GELİŞMİŞ DİNAMİK RENK PALETİ ---
  // Bu renkler, telefonun moduna ve erişilebilirlik ayarlarına göre otomatik değişir.

  static const CupertinoDynamicColor primary = CupertinoDynamicColor.withBrightnessAndContrast(
    // Standart Açık Mod (Verdiğiniz renk)
    color: Color(0xFFEB5E28),
    // Standart Koyu Mod (Daha canlı bir ton)
    darkColor: Color(0xFFF07A4B),
    // Kontrastı Artırılmış Açık Mod (Daha koyu bir ton)
    highContrastColor: Color(0xFFC64A1A),
    // Kontrastı Artırılmış Koyu Mod (Daha parlak bir ton)
    darkHighContrastColor: Color(0xFFFF8A5E),
  );

  static const CupertinoDynamicColor secondary = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF5856D6),
    darkColor: Color(0xFF5E5CE6),
    highContrastColor: Color(0xFF3634C6),
    darkHighContrastColor: Color(0xFF7D7AFF),
  );

  // --- GÜNCELLENEN ARKA PLAN RENGİ ---
  static const CupertinoDynamicColor scaffoldBackground = CupertinoDynamicColor.withBrightnessAndContrast(
    // Açık mod için sıcak bir kırık beyaz tonu
    color: Color(0xFFFAF9F6),
    // Koyu mod için istediğiniz renk
    darkColor: Color(0xFF252422),
    // Yüksek kontrast açık mod
    highContrastColor: Color(0xFFFFFFFF),
    // Yüksek kontrast koyu mod
    darkHighContrastColor: Color(0xFF252422),
  );

    static const CupertinoDynamicColor widgetBackground = CupertinoDynamicColor.withBrightnessAndContrast(
    // Açık modda beyaz kalmaya devam ediyor
    color: Color(0xFFFFFFFF),
    // Koyu modda istediğiniz renk
    darkColor: Color(0xFF403D39),
    // Yüksek kontrast açık mod
    highContrastColor: Color(0xFFFFFFFF),
    // Yüksek kontrast koyu mod
    darkHighContrastColor: Color(0xFF403D39),
  );

  static const CupertinoDynamicColor primaryText = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF000000),
    darkColor: Color(0xFFFFFFFF),
    highContrastColor: Color(0xFF000000),
    darkHighContrastColor: Color(0xFFFFFFFF),
  );

  static const CupertinoDynamicColor secondaryText = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFF8A8A8E),
    darkColor: Color(0xFF8E8E93),
    highContrastColor: Color(0xFF6C6C70),
    darkHighContrastColor: Color(0xFF98989E),
  );
  
  static const CupertinoDynamicColor error = CupertinoDynamicColor.withBrightnessAndContrast(
    color: Color(0xFFFF3B30),
    darkColor: Color(0xFFFF453A),
    highContrastColor: Color(0xFFD90000),
    darkHighContrastColor: Color(0xFFFF6A60),
  );
}