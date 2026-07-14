import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/biometric_service.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';

/// Sits above the router in the widget tree. When App Lock is enabled
/// (off by default — see Settings), shows an opaque lock screen on cold
/// start and whenever the app resumes from the background, until the
/// user authenticates.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  bool _locked = false;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock immediately on cold start if the setting is on.
    WidgetsBinding.instance.addPostFrameCallback((_) => _lockIfEnabled());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lockIfEnabled();
    }
  }

  void _lockIfEnabled() {
    final enabled = ref.read(settingsControllerProvider).appLockEnabled;
    if (enabled && !_locked) {
      setState(() => _locked = true);
      _promptUnlock();
    }
  }

  Future<void> _promptUnlock() async {
    if (_authenticating) return;
    _authenticating = true;
    final ok = await ref.read(biometricServiceProvider).authenticate();
    _authenticating = false;
    if (ok && mounted) {
      setState(() => _locked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked)
          _LockScreen(onUnlock: _promptUnlock),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 48, color: scheme.primary),
                const SizedBox(height: 16),
                Text(l10n.appLockScreenTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  l10n.appLockScreenBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onUnlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.actionUnlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
