import 'package:flutter/material.dart';

class DraggableFAB extends StatefulWidget {
  const DraggableFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
    this.initialOffset,
    this.size = 56,
    this.minLeft = 8,
    this.minTop = 8,
    this.minRight = 8,
    this.minBottom = 8,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Object? heroTag;
  final Offset? initialOffset;
  final double size;
  final double minLeft;
  final double minTop;
  final double minRight;
  final double minBottom;

  @override
  State<DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB> {
  Offset? _offset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize default position bottom-right if not set
    if (_offset == null) {
      final size = MediaQuery.of(context).size;
      final dx = size.width - widget.size - widget.minRight;
      final dy = size.height - widget.size - widget.minBottom;
      _offset = widget.initialOffset ?? Offset(dx, dy);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to clamp within available body area
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxX = (constraints.maxWidth - widget.size - widget.minRight).clamp(0.0, double.infinity);
        final maxY = (constraints.maxHeight - widget.size - widget.minBottom).clamp(0.0, double.infinity);
        final minX = widget.minLeft;
        final minY = widget.minTop;

        final clamped = Offset(
          _offset!.dx.clamp(minX, maxX),
          _offset!.dy.clamp(minY, maxY),
        );

        return Stack(
          children: [
            Positioned(
              left: clamped.dx,
              top: clamped.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _offset = Offset(_offset!.dx + details.delta.dx, _offset!.dy + details.delta.dy);
                  });
                },
                child: FloatingActionButton(
                  heroTag: widget.heroTag,
                  onPressed: widget.onPressed,
                  backgroundColor: widget.backgroundColor,
                  foregroundColor: widget.foregroundColor,
                  tooltip: widget.tooltip,
                  child: Icon(widget.icon),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
