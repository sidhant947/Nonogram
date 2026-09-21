import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../providers.dart';

class TangibleButton extends ConsumerStatefulWidget {
  const TangibleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.height = 54.0,
    this.fontSize = 16.0,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;
  final double height;
  final double fontSize;

  @override
  ConsumerState<TangibleButton> createState() => _TangibleButtonState();
}

class _TangibleButtonState extends ConsumerState<TangibleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    final Color bgColor = widget.isSecondary ? AppColors.surface : AppColors.buttonBg;
    final Color textColor = AppColors.buttonText;
    final Color shadowColor = widget.isSecondary ? Colors.black54 : Colors.black87;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled
          ? null
          : () {
              final hapticsEnabled = ref.read(progressRepositoryProvider).hapticsEnabled;
              if (hapticsEnabled) {
                HapticFeedback.lightImpact();
              }
              widget.onPressed!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        height: widget.height,
        width: double.infinity,
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: isDisabled ? bgColor.withValues(alpha: 0.4) : bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed || isDisabled
              ? []
              : [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  )
                ],
          border: Border.all(
            color: widget.isSecondary ? AppColors.border : Colors.transparent,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: textColor, size: widget.fontSize + 4),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text.toUpperCase(),
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
