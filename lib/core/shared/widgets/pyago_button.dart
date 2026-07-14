import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_radius.dart';

enum PyagoButtonVariant { primary, secondary, tertiary, destructive }
enum PyagoButtonSize { medium, large }

/// The single button component used across Pyago. Every visual variant
/// (primary/secondary/tertiary/destructive) and both sizes route through
/// this one widget so button behavior — loading, disabled, pressed
/// animation — stays consistent everywhere.
class PyagoButton extends StatefulWidget {
  const PyagoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PyagoButtonVariant.primary,
    this.size = PyagoButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final PyagoButtonVariant variant;
  final PyagoButtonSize size;
  final IconData? icon;
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
    final disabled = widget.onPressed == null || widget.isLoading;

    final Color background;
    final Color foreground;
    final BoxBorder? border;

    switch (widget.variant) {
      case PyagoButtonVariant.primary:
        background = disabled ? scheme.surfaceContainerHighest : scheme.primary;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onPrimary;
        border = null;
      case PyagoButtonVariant.secondary:
        background = scheme.surfaceContainerHighest;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onSurface;
        border = null;
      case PyagoButtonVariant.tertiary:
        background = Colors.transparent;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : scheme.primary;
        border = Border.all(color: scheme.outline);
      case PyagoButtonVariant.destructive:
        background = disabled ? scheme.surfaceContainerHighest : scheme.error;
        foreground = disabled ? scheme.onSurface.withValues(alpha: 0.4) : Colors.white;
        border = null;
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.radiusMd,
          border: border,
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
                ],
              ),
      ),
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTap: disabled ? null : widget.onPressed,
        child: MouseRegion(
          cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: child,
        ),
      ),
    );
  }
}
