import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/shared/widgets/pyago_button.dart';
import '../../../../core/shared/widgets/pyago_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final ok = await ref.read(authControllerProvider.notifier).login(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      context.go('/home');
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
              const SizedBox(height: 8),
              Text('Welcome back', style: context.textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(
                'Sign in to keep writing where you left off.',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 32),
              PyagoTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              PyagoTextField(
                label: 'Password',
                controller: _password,
                hint: 'Enter your password',
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('Forgot password?'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!, style: context.textTheme.bodySmall?.copyWith(color: context.colors.error)),
              ],
              const SizedBox(height: 16),
              PyagoButton(label: 'Sign in', isLoading: _submitting, onPressed: _submit),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
