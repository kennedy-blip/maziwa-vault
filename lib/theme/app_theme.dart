import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';

class VaultColors {
  static ColorScheme scheme(VaultTheme mode) {
    switch (mode) {
      case VaultTheme.daylight:
        return ColorScheme.fromSeed(seedColor: const Color(0xFF087F5B), brightness: Brightness.light, surface: const Color(0xFFF4F8F5));
      case VaultTheme.cooler:
        return ColorScheme.fromSeed(seedColor: const Color(0xFFFFC857), brightness: Brightness.dark, surface: const Color(0xFF101820));
      case VaultTheme.pasture:
        return ColorScheme.fromSeed(seedColor: const Color(0xFF20C997), brightness: Brightness.dark, surface: const Color(0xFF101B1A));
    }
  }
  static ThemeData theme(VaultTheme mode) {
    final scheme = VaultColors.scheme(mode);
    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: scheme.surfaceContainerHighest.withValues(alpha: .45),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: scheme.outlineVariant))),
      cardTheme: CardThemeData(color: scheme.surfaceContainerHighest.withValues(alpha: .48), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .55)))),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface.withValues(alpha: .96), indicatorColor: scheme.primary.withValues(alpha: .18)),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(borderRadius: BorderRadius.circular(22), child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(padding: padding, decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: .48),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: .55)),
      ), child: child),
    ));
  }
}
