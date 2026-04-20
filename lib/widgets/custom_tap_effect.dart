import 'package:flutter/material.dart';

class CustomTapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const CustomTapEffect({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<CustomTapEffect> createState() => _CustomTapEffectState();
}

class _CustomTapEffectState extends State<CustomTapEffect> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isTapped ? 0.98 : 1.0), // わずかに縮小
        decoration: BoxDecoration(
          borderRadius:
              widget.borderRadius ?? BorderRadius.circular(0), // デフォルトは角丸なし
        ),
        child: widget.child,
      ),
    );
  }
}
