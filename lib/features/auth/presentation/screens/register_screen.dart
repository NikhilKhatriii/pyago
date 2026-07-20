import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/shared/widgets/pyago_button.dart';
import '../../../../core/shared/widgets/pyago_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;
  bool _agreed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_agreed) {
      setState(() => _error = 'Please agree to the Terms and Privacy Policy to continue.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final ok = await ref
        .read(authControllerProvider.notifier)
        .register(_email.text.trim(), _password.text, _name.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      context.go('/otp-verification');
    } else {
      setState(() => _error = ref.read(authControllerProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Create account',
                style: AppTypography.serifDisplay(
                  color: scheme.onSurface,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A few details and you can start writing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 32),
              PyagoTextField(
                label: 'Display name',
                controller: _name,
                hint: 'How should we call you?',
                prefixIcon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              PyagoTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 20),
              PyagoTextField(
                label: 'Password',
                controller: _password,
                hint: 'At least 8 characters',
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                helperText: 'Use 8+ characters with a letter and a number.',
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    activeColor: scheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 4),
                      child: Wrap(
                        children: [
                          Text('I agree to the ', style: Theme.of(context).textTheme.bodySmall),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Terms',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Text(' and ', style: Theme.of(context).textTheme.bodySmall),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Privacy Policy',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              PyagoButton(
                label: 'Create Account',
                variant: PyagoButtonVariant.gradient,
                isLoading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/login'),
                  child: Text(
                    'Already have an account? Sign in',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
