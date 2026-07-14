import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                'P',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 6),
            Text(
              AppConstants.tagline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
