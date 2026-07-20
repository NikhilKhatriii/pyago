import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/widgets/pyago_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _showAccessibilitySettings = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Serene misty background image
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
          ),
          // Deep dark gradient scrim for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(settings.highContrast ? 0.9 : 0.2),
                  Colors.black.withOpacity(settings.highContrast ? 0.95 : 0.6),
                  Colors.black.withOpacity(settings.highContrast ? 1.0 : 0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // 1. Accessibility Toggle Header
                  _buildAccessibilityTrigger(settings, settingsNotifier, scheme),
                  if (_showAccessibilitySettings)
                    _buildAccessibilityControlDeck(settings, settingsNotifier, scheme)
                        .animate()
                        .fade(duration: 250.ms)
                        .slideY(begin: -0.1, end: 0, duration: 250.ms),

                  const Spacer(),

                  if (settings.simpleMode) ...[
                    // --- SIMPLE LAYOUT MODE (Senior Friendly) ---
                    _buildSimpleModeView(context, scheme)
                  ] else ...[
                    // --- STANDARD PREMIUM EDITORIAL MODE ---
                    _buildStandardView(context, scheme)
                  ],

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityTrigger(
    SettingsState settings,
    SettingsController settingsNotifier,
    ColorScheme scheme,
  ) {
    return InkWell(
      onTap: () => setState(() => _showAccessibilitySettings = !_showAccessibilitySettings),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.accessibility_new_rounded,
                  color: Colors.white,
                  size: settings.simpleMode ? 26 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  settings.simpleMode
                      ? 'READABILITY & TEXT SIZE (TAP TO CLOSE/OPEN)'
                      : 'Text Size & Readability Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: settings.simpleMode ? 14 : 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  _showAccessibilitySettings
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibilityControlDeck(
    SettingsState settings,
    SettingsController settingsNotifier,
    ColorScheme scheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text size selector
          const Text(
            'Adjust Text Size:',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTextScaleButton(settingsNotifier, settings, 0.85, 'A-', 'Small'),
              _buildTextScaleButton(settingsNotifier, settings, 1.0, 'A', 'Normal'),
              _buildTextScaleButton(settingsNotifier, settings, 1.25, 'A+', 'Large'),
              _buildTextScaleButton(settingsNotifier, settings, 1.5, 'A++', 'Huge'),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          // Contrasts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'High Contrast Mode:',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Switch(
                value: settings.highContrast,
                activeColor: AppColors.brandAccent,
                onChanged: settingsNotifier.setHighContrast,
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          // Simple layout mode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simple Layout Mode:',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Larger controls & guided design for easy use',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.simpleMode,
                activeColor: AppColors.brandAccent,
                onChanged: (val) {
                  settingsNotifier.setSimpleMode(val);
                  // Make font size larger by default when turning simpleMode on.
                  if (val) {
                    settingsNotifier.setTextScale(1.25);
                  } else {
                    settingsNotifier.setTextScale(1.0);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextScaleButton(
    SettingsController settingsNotifier,
    SettingsState settings,
    double scale,
    String label,
    String description,
  ) {
    final isSelected = (settings.textScale - scale).abs() < 0.05;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.brandPrimary : Colors.white10,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? Colors.white : Colors.white12,
                width: 1.5,
              ),
            ),
          ),
          onPressed: () => settingsNotifier.setTextScale(scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 9, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardView(BuildContext context, ColorScheme scheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Premium logo representation
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Image.asset('assets/icons/app_icon.png'),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
        const SizedBox(height: 28),
        Text(
          'Say what matters.',
          textAlign: TextAlign.center,
          style: AppTypography.serifDisplay(
            color: Colors.white,
            fontSize: 40,
            letterSpacing: -1.0,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 12),
        Text(
          AppConstants.tagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.75),
                letterSpacing: 0.3,
              ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
        const SizedBox(height: 48),
        // Action buttons
        PyagoButton(
          label: 'Create an account',
          variant: PyagoButtonVariant.gradient,
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: () => context.push('/register'),
        ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(delay: 450.ms),
        const SizedBox(height: 14),
        PyagoButton(
          label: 'I already have an account',
          variant: PyagoButtonVariant.secondary,
          onPressed: () => context.push('/login'),
        ).animate().slideY(begin: 0.2, duration: 400.ms).fadeIn(delay: 550.ms),
      ],
    );
  }

  Widget _buildSimpleModeView(BuildContext context, ColorScheme scheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/icons/app_icon.png'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome to Pyago',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 34,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'A quiet, private space to write journals, poems, and stories by yourself or with your loved ones.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 36),
        // Simple step-by-step navigation for all generations
        const Text(
          'CHOOSE ONE OPTION BELOW:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.brandAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 4,
          ),
          onPressed: () => context.push('/register'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded, size: 28),
              SizedBox(width: 12),
              Text(
                '1. Create a New Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.1, duration: 300.ms).fadeIn(),
        const SizedBox(height: 18),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.5),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2.5),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          onPressed: () => context.push('/login'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login_rounded, size: 28),
              SizedBox(width: 12),
              Text(
                '2. Log In to My Account',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.1, duration: 300.ms).fadeIn(delay: 100.ms),
      ],
    );
  }
}
