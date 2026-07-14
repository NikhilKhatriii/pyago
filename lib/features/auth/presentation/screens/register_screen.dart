import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/shared/widgets/pyago_button.dart';
import '../../../../core/shared/widgets/pyago_text_field.dart';
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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create your account', style: context.textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(
                'A few details and you can start writing.',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 28),
              PyagoTextField(label: 'Display name', controller: _name, hint: 'How should we call you?', prefixIcon: Icons.badge_outlined),
              const SizedBox(height: 16),
              PyagoTextField(label: 'Email', controller: _email, hint: 'you@example.com', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.mail_outline_rounded),
              const SizedBox(height: 16),
              PyagoTextField(
                label: 'Password',
                controller: _password,
                hint: 'At least 8 characters',
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                helperText: 'Use 8+ characters with a letter and a number.',
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        children: [
                          Text('I agree to the ', style: context.textTheme.bodySmall),
                          GestureDetector(
                            onTap: () {},
                            child: Text('Terms', style: context.textTheme.bodySmall?.copyWith(color: context.colors.primary)),
                          ),
                          Text(' and ', style: context.textTheme.bodySmall),
                          GestureDetector(
                            onTap: () {},
                            child: Text('Privacy Policy', style: context.textTheme.bodySmall?.copyWith(color: context.colors.primary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!, style: context.textTheme.bodySmall?.copyWith(color: context.colors.error)),
              ],
              const SizedBox(height: 8),
              PyagoButton(label: 'Create account', isLoading: _submitting, onPressed: _submit),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Already have an account? Sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
