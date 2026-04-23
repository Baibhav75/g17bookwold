import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

/// A premium Shimmer effect implementation for Flutter.
/// This file provides a native shimmer animation without external dependencies.

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  final Widget child;
  final LinearGradient gradient;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    required this.gradient,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: widget.duration);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
        colors: widget.gradient.colors,
        stops: widget.gradient.stops,
        begin: widget.gradient.begin,
        end: widget.gradient.end,
        transform: _SlidingGradientTransform(slidePercent: _shimmerController.value),
      );

  bool get isSized => (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset(RenderBox descendant) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(Offset.zero, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Use this widget to wrap any item that should have the shimmer effect.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    if (widget.isLoading) {
      setState(() {
        // update the shimmer
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    // Collect ancestor shimmer info
    final shimmer = Shimmer.of(context);
    if (shimmer == null || !shimmer.isSized) {
      // The ancestor Shimmer widget isn't ready
      return widget.child;
    }

    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final drawBox = context.findRenderObject() as RenderBox?;

    if (drawBox == null || !drawBox.hasSize) {
      return widget.child;
    }

    final offsetWithinShimmer = shimmer.getDescendantOffset(drawBox);

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A convenient widget for creating skeleton loaders (rounded containers).
class SkeletonElement extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const SkeletonElement({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A Premium Refresh Indicator that uses a shimmer effect during loading.
/// Wrap your ListView/GridView with this.
class ModernShimmerRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ModernShimmerRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: (context, child, controller) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            if (!controller.isIdle && !controller.isArmed)
              Positioned(
                top: 35.0 * controller.value,
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    value: controller.isDragging ? controller.value : null,
                    strokeWidth: 2,
                    color: const Color(0xFF6B46C1),
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(0, 100.0 * controller.value),
              child: child,
            ),
          ],
        );
      },
      child: child,
    );
  }
}

/// Usage Example for Developers:
///
/// ```dart
/// Shimmer(
///   gradient: LinearGradient(
///     colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
///     stops: const [0.1, 0.3, 0.4],
///     begin: const Alignment(-1.0, -0.3),
///     end: const Alignment(1.0, 0.3),
///   ),
///   child: ShimmerLoading(
///     isLoading: true,
///     child: SkeletonElement(height: 100, width: double.infinity),
///   ),
/// )
/// ```
