import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_elevation.dart';
import '../../theme/app_radius.dart';

enum PyagoButtonVariant { primary, secondary, tertiary, destructive, gradient }
enum PyagoButtonSize { medium, large }

/// The single button component used across Pyago. Every visual variant
/// (primary/secondary/tertiary/destructive/gradient) and both sizes route
/// through this one widget so button behavior — loading, disabled, pressed
/// animation — stays consistent everywhere.
///
/// The [gradient] variant uses the brand gradient for premium CTAs.
class PyagoButton extends StatefulWidget {
  const PyagoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PyagoButtonVariant.primary,
    this.size = PyagoButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final PyagoButtonVariant variant;
  final PyagoButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expand;

  @override
  State<PyagoButton> createState() => _PyagoButtonState();
}

class _PyagoButtonState extends State<PyagoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final disabled = widget.onPressed == null || widget.isLoading;
    final isGradient = widget.variant == PyagoButtonVariant.gradient;

    final Color background;
    final Color foreground;
    final BoxBorder? border;
    final Gradient? gradient;

    switch (widget.variant) {
      case PyagoButtonVariant.primary:
        background = disabled ? scheme.surfaceContainerHighest : scheme.primary;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onPrimary;
        border = null;
        gradient = null;
      case PyagoButtonVariant.gradient:
        background = Colors.transparent;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : Colors.white;
        border = null;
        gradient = disabled
            ? null
            : const LinearGradient(
                colors: AppColors.brandGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              );
      case PyagoButtonVariant.secondary:
        background = scheme.surfaceContainerHighest;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onSurface;
        border = null;
        gradient = null;
      case PyagoButtonVariant.tertiary:
        background = Colors.transparent;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.primary;
        border = Border.all(color: scheme.outline);
        gradient = null;
      case PyagoButtonVariant.destructive:
        background = disabled ? scheme.surfaceContainerHighest : scheme.error;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : Colors.white;
        border = null;
        gradient = null;
    }

    final height = widget.size == PyagoButtonSize.large ? 52.0 : 44.0;

    final child = AnimatedScale(
      duration: AppDurations.instant,
      scale: _pressed ? 0.97 : 1.0,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        height: height,
        width: widget.expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: gradient != null ? null : background,
          gradient: gradient,
          borderRadius: AppRadius.radiusPill,
          border: border,
          boxShadow: isGradient && !disabled
              ? [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppElevation.cardResting(brightness),
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: foreground),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: foreground),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: foreground),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(widget.trailingIcon, size: 18, color: foreground),
                  ],
                ],
              ),
      ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) {
          HapticFeedback.lightImpact();
          setState(() => _pressed = true);
        },
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTap: disabled ? null : () {
          widget.onPressed?.call();
        },
        child: MouseRegion(
          cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: child,
        ),
      ),
    );
  }
}
