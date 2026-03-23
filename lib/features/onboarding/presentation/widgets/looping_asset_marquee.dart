import 'package:flutter/material.dart';

class LoopingAssetMarquee extends StatefulWidget {
  const LoopingAssetMarquee({
    super.key,
    required this.assetPaths,
    required this.itemWidth,
    required this.itemHeight,
    required this.spacing,
    required this.duration,
    required this.semanticPrefix,
    this.reverse = false,
    this.initialProgress = 0,
  });

  final List<String> assetPaths;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final Duration duration;
  final String semanticPrefix;
  final bool reverse;
  final double initialProgress;

  @override
  State<LoopingAssetMarquee> createState() => _LoopingAssetMarqueeState();
}

class _LoopingAssetMarqueeState extends State<LoopingAssetMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  double get _rowWidth {
    return (widget.assetPaths.length * widget.itemWidth) +
        ((widget.assetPaths.length - 1) * widget.spacing);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value + widget.initialProgress) % 1;
        final shift = progress * _rowWidth;
        final firstOffset = widget.reverse ? shift - _rowWidth : -shift;
        final secondOffset = widget.reverse ? shift : _rowWidth - shift;

        return ClipRect(
          child: Stack(
            children: [
              Positioned(left: firstOffset, top: 0, child: child!),
              Positioned(
                left: secondOffset,
                top: 0,
                child: _MarqueeRow(
                  assetPaths: widget.assetPaths,
                  itemWidth: widget.itemWidth,
                  itemHeight: widget.itemHeight,
                  spacing: widget.spacing,
                  semanticPrefix: widget.semanticPrefix,
                ),
              ),
            ],
          ),
        );
      },
      child: _MarqueeRow(
        assetPaths: widget.assetPaths,
        itemWidth: widget.itemWidth,
        itemHeight: widget.itemHeight,
        spacing: widget.spacing,
        semanticPrefix: widget.semanticPrefix,
      ),
    );
  }
}

class _MarqueeRow extends StatelessWidget {
  const _MarqueeRow({
    required this.assetPaths,
    required this.itemWidth,
    required this.itemHeight,
    required this.spacing,
    required this.semanticPrefix,
  });

  final List<String> assetPaths;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < assetPaths.length; index++) ...[
          if (index > 0) SizedBox(width: spacing),
          Image.asset(
            assetPaths[index],
            width: itemWidth,
            height: itemHeight,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            semanticLabel: '$semanticPrefix ${index + 1}',
          ),
        ],
      ],
    );
  }
}
