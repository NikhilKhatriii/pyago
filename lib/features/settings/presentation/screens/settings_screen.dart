import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

const _localeNames = {
  'en': 'English',
  'ne': 'नेपाली (Nepali)',
  'hi': 'हिन्दी (Hindi)',
  'ja': '日本語 (Japanese)',
  'de': 'Deutsch (German)',
  'fr': 'Français (French)',
  'ar': 'العربية (Arabic)',
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final themeMode = settings.themeMode;
    final themeText = switch (themeMode) {
      ThemeMode.system => 'Match system',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.md),
        children: [
          _SettingsGroup(
            title: l10n.settingsAppearance,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsTheme),
                subtitle: Text(themeText),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox.shrink(),
                  onChanged: (v) => v != null ? controller.setThemeMode(v) : null,
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsHighContrast),
                subtitle: const Text('Increase contrast for low-vision reading'),
                value: settings.highContrast,
                onChanged: controller.setHighContrast,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsTextSize),
                subtitle: Slider(
                  value: settings.textScale,
                  min: 0.85,
                  max: 1.6,
                  divisions: 15,
                  label: '${(settings.textScale * 100).round()}%',
                  onChanged: controller.setTextScale,
                ),
              ),
            ],
          ),
          _SettingsGroup(
            title: 'Language & Region',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsLanguage),
                subtitle: Text(_localeNames[settings.locale] ?? settings.locale),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLocalePicker(context, ref),
              ),
            ],
          ),
          _SettingsGroup(
            title: 'Account',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Privacy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showComingSoon(context, 'Privacy Settings'),
              ),
              Consumer(builder: (context, ref, _) {
                final biometric = ref.watch(biometricServiceProvider);
                return FutureBuilder<bool>(
                  future: biometric.isDeviceSupported,
                  builder: (context, snapshot) {
                    final supported = snapshot.data ?? false;
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsAppLock),
                      subtitle: Text(
                        supported
                            ? l10n.settingsAppLockSubtitleOn
                            : l10n.settingsAppLockSubtitleUnsupported,
                      ),
                      value: settings.appLockEnabled,
                      onChanged: !supported
                          ? null
                          : (value) async {
                              if (value) {
                                final ok = await biometric.authenticate(
                                  reason: 'Confirm to turn on App Lock',
                                );
                                if (!ok) return;
                              }
                              controller.setAppLockEnabled(value);
                            },
                    );
                  },
                );
              }),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/notifications'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Storage & downloads'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showComingSoon(context, 'Storage Management'),
              ),
            ],
          ),
          _SettingsGroup(
            title: 'Support',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Help center'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showComingSoon(context, 'Help Center'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Send feedback'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showComingSoon(context, 'Feedback'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('About Pyago'),
                subtitle: const Text('${AppConstants.appName} · v0.1.0'),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About Pyago'),
                    content: const Text(
                      'Nothing you write here is touched, suggested, or generated by AI. It\'s just you.\n\n'
                      'Pyago is a quiet place designed for slow, deliberate, and authentic human expression.'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/welcome');
            },
            child: Text(l10n.actionSignOut),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon!')),
    );
  }

  void _showLocalePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final entry in _localeNames.entries)
              ListTile(
                title: Text(entry.value),
                onTap: () {
                  ref.read(settingsControllerProvider.notifier).setLocale(entry.key);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              )),
          const SizedBox(height: AppSpacing.xs),
          ...children,
        ],
      ),
    );
  }
}
