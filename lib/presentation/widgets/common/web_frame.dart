import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// WebAppFrame constrains the entire app's width on web so the horizontal size
/// never exceeds the vertical size (max aspect ratio 1:1), yielding a
/// mobile-like experience across all screens.
///
/// Everything (app bars, bodies, bottom bars, dialogs, snackbars) is within
/// this frame because it's applied at MaterialApp.builder.
class WebAppFrame extends StatelessWidget {
  final Widget child;
  final double minWidth;

  const WebAppFrame({
    super.key,
    required this.child,
    this.minWidth = 360, // keep a readable minimum width
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    final size = MediaQuery.of(context).size;
    // Enforce width <= height (max 1:1). Also keep at least minWidth.
    final targetWidth = size.width < size.height ? size.width : size.height;
    final widthCap = targetWidth < minWidth ? minWidth : targetWidth;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widthCap),
        child: child,
      ),
    );
  }
}
