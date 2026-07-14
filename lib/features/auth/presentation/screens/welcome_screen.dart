import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/shared/widgets/pyago_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(18)),
                alignment: Alignment.center,
                child: Text('P', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 24),
              Text(
                'Say what matters.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.tagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
              const Spacer(),
              PyagoButton(
                label: 'Create an account',
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 12),
              PyagoButton(
                label: 'I already have an account',
                variant: PyagoButtonVariant.secondary,
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
