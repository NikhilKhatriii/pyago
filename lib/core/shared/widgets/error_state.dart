import 'package:flutter/material.dart';
import 'pyago_button.dart';

class PyagoErrorState extends StatelessWidget {
  const PyagoErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: scheme.error),
            const SizedBox(height: 14),
            Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              PyagoButton(
                label: 'Try again',
                onPressed: onRetry,
                variant: PyagoButtonVariant.secondary,
                size: PyagoButtonSize.medium,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PyagoSuccessBanner extends StatelessWidget {
  const PyagoSuccessBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2FA76A).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF2FA76A), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
