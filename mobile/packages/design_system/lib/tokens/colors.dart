import 'package:flutter/material.dart';

class TripThemePalette {
  final String name;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryLight;
  final Color accent;
  final Color accentLight;
  final Color surface;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> heroGradient;

  const TripThemePalette({
    required this.name,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.accent,
    required this.accentLight,
    required this.surface,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.heroGradient,
  });
}

class MaceioColors {
  // Oceano e Piscinas Naturais (Padrão Tropical)
  static const Color turquoisePrimary = Color(0xFF00A896);
  static const Color turquoiseDark = Color(0xFF028090);
  static const Color oceanDeep = Color(0xFF05668D);
  static const Color oceanLight = Color(0xFFE8F7F6);

  // Corais e Calor Alagoano
  static const Color coralAccent = Color(0xFFF46036);
  static const Color coralLight = Color(0xFFFDEEE9);

  // Areia, Sol e Natureza
  static const Color sandWarm = Color(0xFFF7F5EB);
  static const Color sunYellow = Color(0xFFF3C969);
  static const Color palmGreen = Color(0xFF2A9D8F);

  // Neutros e Superfícies
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFB);
  static const Color surfaceElevated = Color(0xFFF0F4F8);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  
  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Paleta Tropical (Praia / Litoral)
  static const TripThemePalette tropical = TripThemePalette(
    name: 'Tropical / Praia',
    primary: Color(0xFF00A896),
    primaryDark: Color(0xFF028090),
    secondary: Color(0xFF05668D),
    secondaryLight: Color(0xFFE8F7F6),
    accent: Color(0xFFF46036),
    accentLight: Color(0xFFFDEEE9),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF8FAFB),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    heroGradient: [Color(0xFF00A896), Color(0xFF05668D)],
  );

  // Paleta Serra / Montanha / Frio (ex: Gramado, Campos do Jordão)
  static const TripThemePalette mountain = TripThemePalette(
    name: 'Serra / Montanha',
    primary: Color(0xFF8B5A2B),
    primaryDark: Color(0xFF5C3A1E),
    secondary: Color(0xFF2D5A27),
    secondaryLight: Color(0xFFF5EFEB),
    accent: Color(0xFFD97706),
    accentLight: Color(0xFFFEF3C7),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFFDFBF7),
    textPrimary: Color(0xFF1C1917),
    textSecondary: Color(0xFF57534E),
    heroGradient: [Color(0xFF8B5A2B), Color(0xFF451A03)],
  );

  // Paleta Urbano / Metrópole (ex: São Paulo, Nova York)
  static const TripThemePalette urban = TripThemePalette(
    name: 'Urbano / Metrópole',
    primary: Color(0xFF4F46E5),
    primaryDark: Color(0xFF3730A3),
    secondary: Color(0xFF06B6D4),
    secondaryLight: Color(0xFFEEF2FF),
    accent: Color(0xFFEC4899),
    accentLight: Color(0xFFFCE7F3),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF8FAFC),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    heroGradient: [Color(0xFF4F46E5), Color(0xFF1E1B4B)],
  );

  // Paleta Ecológica / Natureza (ex: Bonito, Chapada, Amazônia)
  static const TripThemePalette eco = TripThemePalette(
    name: 'Natureza / Ecoturismo',
    primary: Color(0xFF059669),
    primaryDark: Color(0xFF047857),
    secondary: Color(0xFF0D9488),
    secondaryLight: Color(0xFFECFDF5),
    accent: Color(0xFFEAB308),
    accentLight: Color(0xFFFEF9C3),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF6FBF8),
    textPrimary: Color(0xFF064E3B),
    textSecondary: Color(0xFF374151),
    heroGradient: [Color(0xFF059669), Color(0xFF064E3B)],
  );

  static TripThemePalette getThemeForDestination(String destination, [String? state]) {
    final destLower = destination.toLowerCase();
    final stateLower = (state ?? '').toLowerCase();

    if (destLower.contains('gramado') ||
        destLower.contains('campos') ||
        destLower.contains('canela') ||
        destLower.contains('monte verde') ||
        destLower.contains('serra') ||
        stateLower.contains('rs') ||
        stateLower.contains('sc')) {
      return mountain;
    }

    if (destLower.contains('paulo') ||
        destLower.contains('york') ||
        destLower.contains('curitiba') ||
        destLower.contains('belo horizonte') ||
        destLower.contains('brasília') ||
        destLower.contains('rio de janeiro')) {
      return urban;
    }

    if (destLower.contains('bonito') ||
        destLower.contains('chapada') ||
        destLower.contains('pantanal') ||
        destLower.contains('manaus') ||
        destLower.contains('jalapão') ||
        destLower.contains('foz')) {
      return eco;
    }

    return tropical;
  }
}

