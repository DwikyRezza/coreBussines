import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  static const _keyThemeMode = 'theme_mode';
  String _selected = 'system';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _selected = prefs.getString(_keyThemeMode) ?? 'system');
  }

  Future<void> _select(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, value);
    if (!mounted) return;
    setState(() => _selected = value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferensi tema disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tema Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          Text(
            'Pilih tampilan yang nyaman untuk Anda.',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            title: 'Terang',
            subtitle: 'Tampilan bersih untuk penggunaan harian',
            selected: _selected == 'light',
            onTap: () => _select('light'),
          ),
          const SizedBox(height: 12),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            title: 'Gelap',
            subtitle: 'Lebih nyaman di tempat minim cahaya',
            selected: _selected == 'dark',
            onTap: () => _select('dark'),
          ),
          const SizedBox(height: 12),
          _ThemeOption(
            icon: Icons.settings_suggest_rounded,
            title: 'Ikuti Sistem',
            subtitle: 'Menyesuaikan pengaturan perangkat',
            selected: _selected == 'system',
            onTap: () => _select('system'),
          ),
          const SizedBox(height: 16),
          Text(
            'Catatan: preferensi sudah tersimpan. Integrasi tema gelap penuh bisa diaktifkan saat theme dark tersedia di design system.',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryContainer : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
