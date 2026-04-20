import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class AnimatedGradientAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight; // Add toolbarHeight property

  const AnimatedGradientAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.toolbarHeight = kToolbarHeight, // Default to kToolbarHeight
  });

  @override
  State<AnimatedGradientAppBar> createState() => _AnimatedGradientAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight +
      (bottom?.preferredSize.height ?? 0.0)); // Use toolbarHeight
}

class _AnimatedGradientAppBarState extends State<AnimatedGradientAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // アニメーションの周期を少し短く
    )..repeat(reverse: true); // 往復させる
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final mainColor = themeProvider.mainColor;
        final subColor =
            themeProvider.subColor ?? mainColor; // サブカラーがなければメインカラーを使う

        final color1 =
            ColorTween(begin: mainColor, end: subColor).animate(_controller);
        final color2 =
            ColorTween(begin: subColor, end: mainColor).animate(_controller);

        return AppBar(
          title: widget.title,
          actions: widget.actions,
          bottom: widget.bottom,
          toolbarHeight: widget.toolbarHeight, // Pass toolbarHeight to AppBar
          flexibleSpace: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color1.value!, color2.value!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
