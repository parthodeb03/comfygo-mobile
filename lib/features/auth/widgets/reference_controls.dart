// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Reference controls (input, pill button, chip, sheet) for the auth screens.
import 'package:flutter/material.dart';

import '../../../core/widgets/comfy_ui.dart';
import 'reference_theme.dart';

/// Text field matching the reference `.in` class: 56dp tall, 16dp radius,
/// 1px outline that becomes a 2px primary focus ring.
class CgRefField extends StatefulWidget {
  const CgRefField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.error = false,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool error;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<CgRefField> createState() => _CgRefFieldState();
}

class _CgRefFieldState extends State<CgRefField> {
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocus);
  bool _focused = false;

  void _onFocus() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    final borderColor = widget.error
        ? CgRefColors.danger
        : _focused
        ? c.primary
        : c.outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: const BoxConstraints(minHeight: 56),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(CgRefRadii.input),
        border: Border.all(
          color: borderColor,
          width: _focused || widget.error ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        cursorColor: c.primary,
        style: CgRefType.body.copyWith(color: c.text),
        decoration: InputDecoration.collapsed(
          hintText: widget.hint,
          hintStyle: CgRefType.body.copyWith(color: c.text2),
        ),
      ),
    );
  }
}

/// Gradient pill button matching the reference `.btn` class.
class CgRefButton extends StatelessWidget {
  const CgRefButton({
    super.key,
    required this.child,
    this.onTap,
    this.loading = false,
    this.expand = false,
    this.height = 52,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool loading;
  final bool expand;
  final double height;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    final Widget content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(c.onPrimary),
            ),
          )
        : DefaultTextStyle.merge(
            style: CgRefType.button.copyWith(color: c.onPrimary),
            textAlign: TextAlign.center,
            child: child,
          );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: CgPressable(
        onTap: loading ? null : onTap,
        child: Container(
          height: height,
          width: expand ? double.infinity : null,
          padding: padding,
          decoration: BoxDecoration(
            gradient: c.gMain,
            borderRadius: BorderRadius.circular(CgRefRadii.pill),
          ),
          // `widthFactor` keeps the pill at its intrinsic width when it sits
          // in a loose row/wrap; `expand` handles the full-width case.
          child: Center(
            widthFactor: expand ? null : 1,
            heightFactor: 1,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Filter/role chip matching the reference `.chip` / `.chip.on` classes.
class CgRefChip extends StatelessWidget {
  const CgRefChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: CgPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: selected ? c.gMain : null,
            color: selected ? null : c.surface,
            borderRadius: BorderRadius.circular(CgRefRadii.pill),
            border: Border.all(
              color: selected ? Colors.transparent : c.outline,
            ),
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CgRefType.chip.copyWith(
                color: selected ? c.onPrimary : c.text,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White form sheet with the reference 28dp top corners and `--sh2` shadow.
class CgRefSheet extends StatelessWidget {
  const CgRefSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 32),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(CgRefRadii.sheet),
        ),
        boxShadow: c.shadow2,
      ),
      child: child,
    );
  }
}

/// Small bold inline link used for the "New to ComfyGo?" style rows.
class CgRefLink extends StatelessWidget {
  const CgRefLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.minHeight = 32,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    return Semantics(
      button: true,
      label: label,
      child: CgPressable(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              label,
              style: CgRefType.bodyS.copyWith(
                fontWeight: FontWeight.w700,
                color: color ?? c.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline validation message, matching the app's error ink.
class CgRefError extends StatelessWidget {
  const CgRefError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: CgRefColors.danger,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: CgRefType.label.copyWith(
              color: CgRefColors.danger,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
