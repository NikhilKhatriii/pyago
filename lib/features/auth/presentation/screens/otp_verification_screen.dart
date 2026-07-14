import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/shared/widgets/pyago_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  late final List<TextEditingController> _controllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  late final List<FocusNode> _nodes = List.generate(AppConstants.otpLength, (_) => FocusNode());
  bool _submitting = false;
  String? _error;

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(_code);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      context.go('/complete-profile');
    } else {
      setState(() => _error = ref.read(authControllerProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authControllerProvider).user?.email ?? 'your email';
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code we sent to $email.',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(AppConstants.otpLength, (i) {
                  return SizedBox(
                    width: 44,
                    height: 54,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: context.textTheme.headlineSmall,
                      decoration: const InputDecoration(counterText: ''),
                      onChanged: (value) {
                        if (value.isNotEmpty && i < AppConstants.otpLength - 1) {
                          _nodes[i + 1].requestFocus();
                        } else if (value.isEmpty && i > 0) {
                          _nodes[i - 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: context.textTheme.bodySmall?.copyWith(color: context.colors.error)),
              ],
              const SizedBox(height: 28),
              PyagoButton(
                label: 'Verify',
                isLoading: _submitting,
                onPressed: _code.length == AppConstants.otpLength ? _submit : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(onPressed: () {}, child: const Text("Didn't get a code? Resend")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
