import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pod/core/theme/app_colors.dart';

/// A reusable button component that handles loading states and prevents double taps.
///
/// If [onPressed] returns a Future, the button will automatically show a loading
/// indicator until the future completes.
///
/// Alternatively, you can control the loading state externally using [isLoading].
class AppButton extends StatefulWidget {
  final String text;
  final Future<void> Function()? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.textStyle,
    this.width,
    this.height,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _internalLoading = false;

  bool get _isLoading => widget.isLoading || _internalLoading;

  Future<void> _handlePress() async {
    if (_isLoading || !widget.isEnabled || widget.onPressed == null) return;

    setState(() {
      _internalLoading = true;
    });

    try {
      await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() {
          _internalLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 56.h,
      child: ElevatedButton(
        onPressed: (_isLoading || !widget.isEnabled) ? null : _handlePress,
        style: widget.style ??
            ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // Reset padding for custom height
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              disabledForegroundColor: AppColors.white,
            ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                widget.text,
                style: widget.textStyle ??
                    TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
              ),
      ),
    );
  }
}
