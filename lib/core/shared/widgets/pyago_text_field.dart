import 'package:flutter/material.dart';

/// The single text-input component used across Pyago's forms.
class PyagoTextField extends StatefulWidget {
  const PyagoTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.maxLines = 1,
    this.textInputAction,
    this.autofocus = false,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<PyagoTextField> createState() => _PyagoTextFieldState();
}

class _PyagoTextFieldState extends State<PyagoTextField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20) : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
