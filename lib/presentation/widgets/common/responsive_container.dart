import 'package:flutter/material.dart';

/// Centers its child and constrains the maximum width for better web layouts.
///
/// Defaults: maxWidth adapts by breakpoint to avoid overly wide lines on
/// desktop. Use this to wrap page bodies/sections that should not stretch
/// edge-to-edge on large displays.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  double _defaultMaxWidth(double width) {
    // Simple responsive breakpoints
    if (width >= 1400) return 1100;
    if (width >= 1200) return 1000;
    if (width >= 1000) return 920;
    if (width >= 800) return 760;
    return width; // small screens use full width
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cap = maxWidth ?? _defaultMaxWidth(screenWidth);
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: content,
      ),
    );
  }
}
