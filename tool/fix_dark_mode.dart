// Script to batch-replace hardcoded colors in all page/widget files
// Run with: dart run tool/fix_dark_mode.dart

import 'dart:io';

void main() {
  final projectRoot = r'd:\Rezza\Self Project\corebussiness';
  final libDir = Directory('$projectRoot/lib/features');
  final coreDir = Directory('$projectRoot/lib/core');

  // Collect all .dart files
  final files = <File>[
    ...libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')),
    ...coreDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')),
  ];

  // Skip files that are already theme-aware patterns (theme files themselves, error mapper, etc.)
  final skipPatterns = [
    'app_theme.dart',
    'app_colors.dart',
    'theme_controller.dart',
    'theme.dart',
    'error_mapper.dart',
    'responsive_helper.dart',
    'pdf_report_service.dart',
  ];

  int totalChanges = 0;
  int filesChanged = 0;

  for (final file in files) {
    final basename = file.uri.pathSegments.last;
    if (skipPatterns.any((p) => basename == p)) continue;

    var content = file.readAsStringSync();
    final original = content;

    // ─── Replace hardcoded Color literals ───────────────────

    // Background colors
    content = content.replaceAll("const Color(0xFFF8FAFC)", "Theme.of(context).scaffoldBackgroundColor");
    content = content.replaceAll("Color(0xFFF8FAFC)", "Theme.of(context).scaffoldBackgroundColor");

    // Heading dark
    content = content.replaceAll("const Color(0xFF1A202C)", "Theme.of(context).colorScheme.onSurface");
    content = content.replaceAll("Color(0xFF1A202C)", "Theme.of(context).colorScheme.onSurface");

    // Subtitle / body text
    content = content.replaceAll("const Color(0xFF4A5568)", "Theme.of(context).colorScheme.onSurfaceVariant");
    content = content.replaceAll("Color(0xFF4A5568)", "Theme.of(context).colorScheme.onSurfaceVariant");

    // Hint / muted text
    content = content.replaceAll("const Color(0xFF718096)", "Theme.of(context).colorScheme.outline");
    content = content.replaceAll("Color(0xFF718096)", "Theme.of(context).colorScheme.outline");
    content = content.replaceAll("const Color(0xFFA0AEC0)", "Theme.of(context).colorScheme.outline");
    content = content.replaceAll("Color(0xFFA0AEC0)", "Theme.of(context).colorScheme.outline");

    // Border / divider
    content = content.replaceAll("const Color(0xFFE2E8F0)", "Theme.of(context).colorScheme.outlineVariant");
    content = content.replaceAll("Color(0xFFE2E8F0)", "Theme.of(context).colorScheme.outlineVariant");
    content = content.replaceAll("const Color(0xFFCBD5E0)", "Theme.of(context).colorScheme.outlineVariant");
    content = content.replaceAll("Color(0xFFCBD5E0)", "Theme.of(context).colorScheme.outlineVariant");

    // Container bg (light)
    content = content.replaceAll("const Color(0xFFEDF2F7)", "Theme.of(context).colorScheme.surfaceContainerHighest");
    content = content.replaceAll("Color(0xFFEDF2F7)", "Theme.of(context).colorScheme.surfaceContainerHighest");
    content = content.replaceAll("const Color(0xFFF0F4FF)", "Theme.of(context).colorScheme.surfaceContainerHighest");
    content = content.replaceAll("Color(0xFFF0F4FF)", "Theme.of(context).colorScheme.surfaceContainerHighest");
    content = content.replaceAll("const Color(0xFFF7FAFC)", "Theme.of(context).colorScheme.surfaceContainerHighest");
    content = content.replaceAll("Color(0xFFF7FAFC)", "Theme.of(context).colorScheme.surfaceContainerHighest");

    // Deep blue → primary
    content = content.replaceAll("const Color(0xFF0D47A1)", "Theme.of(context).colorScheme.primary");
    content = content.replaceAll("Color(0xFF0D47A1)", "Theme.of(context).colorScheme.primary");
    content = content.replaceAll("const Color(0xFF2962FF)", "Theme.of(context).colorScheme.primary");
    content = content.replaceAll("Color(0xFF2962FF)", "Theme.of(context).colorScheme.primary");
    content = content.replaceAll("const Color(0xFF1A237E)", "Theme.of(context).colorScheme.primary");
    content = content.replaceAll("Color(0xFF1A237E)", "Theme.of(context).colorScheme.primary");

    // Card backgrounds (Colors.white → colorScheme.surface)
    // Only replace where it's clearly a card/container bg
    // This needs to be careful — Colors.white in text should stay or use onPrimary

    // AppColors.* → Theme references
    // These are trickier because they don't have context. We'll handle them
    // only when used in widget build methods.

    // ─── Replace AppColors.background usage in Scaffold ─────
    content = content.replaceAll(
      "backgroundColor: AppColors.background,",
      "backgroundColor: Theme.of(context).scaffoldBackgroundColor,",
    );

    // ─── Replace other AppColors references ─────────────────
    // AppColors.surface in containers
    content = content.replaceAll("AppColors.surface", "Theme.of(context).colorScheme.surface");
    content = content.replaceAll("AppColors.primary,", "Theme.of(context).colorScheme.primary,");
    content = content.replaceAll("AppColors.primary)", "Theme.of(context).colorScheme.primary)");
    content = content.replaceAll("AppColors.onPrimary", "Theme.of(context).colorScheme.onPrimary");
    content = content.replaceAll("AppColors.primaryContainer", "Theme.of(context).colorScheme.primaryContainer");
    content = content.replaceAll("AppColors.onPrimaryContainer", "Theme.of(context).colorScheme.onPrimaryContainer");
    content = content.replaceAll("AppColors.onBackground", "Theme.of(context).colorScheme.onSurface");
    content = content.replaceAll("AppColors.onSurface,", "Theme.of(context).colorScheme.onSurface,");
    content = content.replaceAll("AppColors.onSurface)", "Theme.of(context).colorScheme.onSurface)");
    content = content.replaceAll("AppColors.onSurfaceVariant", "Theme.of(context).colorScheme.onSurfaceVariant");
    content = content.replaceAll("AppColors.surfaceVariant", "Theme.of(context).colorScheme.surfaceContainerHighest");
    content = content.replaceAll("AppColors.surfaceContainer", "Theme.of(context).colorScheme.surfaceContainerHigh");
    content = content.replaceAll("AppColors.outline,", "Theme.of(context).colorScheme.outline,");
    content = content.replaceAll("AppColors.outline)", "Theme.of(context).colorScheme.outline)");
    content = content.replaceAll("AppColors.outlineVariant", "Theme.of(context).colorScheme.outlineVariant");
    content = content.replaceAll("AppColors.shadow", "Theme.of(context).colorScheme.shadow");
    content = content.replaceAll("AppColors.expense", "Theme.of(context).colorScheme.error");
    content = content.replaceAll("AppColors.income", "Theme.of(context).colorScheme.primary");
    content = content.replaceAll("AppColors.incomeLight", "Theme.of(context).colorScheme.primaryContainer");
    content = content.replaceAll("AppColors.expenseLight", "Theme.of(context).colorScheme.errorContainer");

    // Clean up any remaining AppColors imports that might no longer be needed
    // (we keep the import since some semantic colors like chartColors still use it)

    if (content != original) {
      file.writeAsStringSync(content);
      filesChanged++;
      final changes = _countDifferences(original, content);
      totalChanges += changes;
      print('✓ ${file.path.split('corebussiness/').last} — $changes replacements');
    }
  }

  print('\n══════════════════════════════════════════');
  print('Done! $filesChanged files changed, $totalChanges total replacements');
  print('══════════════════════════════════════════');
}

int _countDifferences(String a, String b) {
  final linesA = a.split('\n');
  final linesB = b.split('\n');
  int count = 0;
  final maxLen = linesA.length > linesB.length ? linesA.length : linesB.length;
  for (int i = 0; i < maxLen; i++) {
    final la = i < linesA.length ? linesA[i] : '';
    final lb = i < linesB.length ? linesB[i] : '';
    if (la != lb) count++;
  }
  return count;
}
