import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:zo_animated_border/zo_animated_border.dart';

class FletAnimatedBorderControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final bool parentDisabled;
  final bool? parentAdaptive;
  final List<Control> children;
  final FletControlBackend backend;

  const FletAnimatedBorderControl({
    super.key,
    this.parent,
    required this.control,
    required this.children,
    required this.parentDisabled,
    required this.parentAdaptive,
    required this.backend,
  });
  @override
  State<FletAnimatedBorderControl> createState() =>
      _FletAnimatedBorderControlState();
}

class _FletAnimatedBorderControlState extends State<FletAnimatedBorderControl>
    with TickerProviderStateMixin {
  double _prevBorderWidth = 8.0;
  double _prevBorderRadius = 10.0;
  bool _isFirstBuild = true;

  late AnimationController _controller;
  late Animation<double> _borderWidthAnim;
  late Animation<double> _borderRadiusAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAndStartAnimations(
      double targetWidth, double targetRadius, Duration duration, Curve curve) {
    _borderWidthAnim = Tween<double>(
      begin: _prevBorderWidth,
      end: targetWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _borderRadiusAnim = Tween<double>(
      begin: _prevBorderRadius,
      end: targetRadius,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _prevBorderWidth = targetWidth;
    _prevBorderRadius = targetRadius;

    _controller.reset();
    _controller.duration = duration;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("AnimatedBorder build: ${widget.control.id}");

    bool disabled = widget.control.isDisabled || widget.parentDisabled;

    final targetBorderWidth = widget.control.attrDouble("borderWidth") ?? 8.0;
    final targetBorderRadius =
        widget.control.attrDouble("borderRadius") ?? 10.0;
    final glowOpacity = widget.control.attrDouble("glowOpacity") ?? 0.4;
    final durationSeconds = widget.control.attrInt("duration_seconds") ?? 3;
    final borderType = widget.control.attrString("borderType") ?? "dual";
    final smoothGradientLoop =
        widget.control.attrBool("smoothGradientLoop", true)!;

    // Extract gradient colors directly from the 'gradientColors' attribute
    List<Color> gradientColors = [];

    // Try to get gradient colors list directly
    final gradientColorsJson = widget.control.attrList("gradientColors");
    if (gradientColorsJson != null) {
      gradientColors = gradientColorsJson
          .map((colorStr) =>
              parseColor(Theme.of(context), colorStr.toString()) ??
              Colors.white)
          .toList();
    }

    // If no gradient colors provided, use dual colors as fallback

    var animation = parseAnimation(widget.control, "animate");
    final animDuration =
        animation?.duration ?? const Duration(milliseconds: 300);
    final animCurve = animation?.curve ?? Curves.easeInOut;

    debugPrint("AnimatedBorder params: borderRadius=$targetBorderRadius, "
        "borderWidth=$targetBorderWidth, glowOpacity=$glowOpacity, "
        "borderType=$borderType, gradientColors=${gradientColors.length} colors");

    if (animation != null) {
      debugPrint(
          "Animation: duration=${animDuration.inMilliseconds}ms, curve=$animCurve");
    }

    bool hasChanges = !_isFirstBuild &&
        (_prevBorderWidth != targetBorderWidth ||
            _prevBorderRadius != targetBorderRadius ||
            // Force rebuild when colors change to ensure they update properly
            true);

    if (_isFirstBuild) {
      _prevBorderWidth = targetBorderWidth;
      _prevBorderRadius = targetBorderRadius;
      _isFirstBuild = false;

      _borderWidthAnim = AlwaysStoppedAnimation<double>(targetBorderWidth);
      _borderRadiusAnim = AlwaysStoppedAnimation<double>(targetBorderRadius);
    } else if (hasChanges && animation != null) {
      debugPrint("Starting animation for borderWidth and borderRadius");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupAndStartAnimations(
            targetBorderWidth, targetBorderRadius, animDuration, animCurve);
      });
    } else if (hasChanges) {
      _prevBorderWidth = targetBorderWidth;
      _prevBorderRadius = targetBorderRadius;

      _borderWidthAnim = AlwaysStoppedAnimation<double>(targetBorderWidth);
      _borderRadiusAnim = AlwaysStoppedAnimation<double>(targetBorderRadius);
    }

    var contentCtrls =
        widget.children.where((c) => c.name == "content" && c.isVisible);

    Widget? child = contentCtrls.isNotEmpty
        ? createControl(widget.control, contentCtrls.first.id, disabled,
            parentAdaptive: false)
        : null;

    final onAnimationEnd = widget.control.attrBool("onAnimationEnd", false)!
        ? () {
            widget.backend.triggerControlEvent(
                widget.control.id, "animation_end", "animated_border");
          }
        : null;

    if (onAnimationEnd != null) {
      _controller.removeStatusListener(_handleAnimationStatus);
      _controller.addStatusListener(_handleAnimationStatus);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final currentWidth = _borderWidthAnim.value;
        final currentRadius = _borderRadiusAnim.value;

        final borderRadiusObj = BorderRadius.circular(currentRadius);

        final bool showBorder = currentWidth > 0;

        if (!showBorder) {
          Widget contentWidget = Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: borderRadiusObj,
            ),
            child: child ??
                const Text("Animated Border",
                    style: TextStyle(color: Colors.black)),
          );

          return constrainedControl(
              context, contentWidget, widget.parent, widget.control);
        }

        Widget baseWidget;

        // Choose border type based on borderType parameter
        if (borderType == "soft_gradient") {
          // Use ZoAnimatedGradientBorder
          var smoothGradientColors = [...gradientColors];

          // Fix for smooth gradient loop transition
          if (smoothGradientLoop && smoothGradientColors.length > 1) {
            // For a smooth loop, add the first color at the end
            // regardless of how many colors are in the list
            smoothGradientColors.add(smoothGradientColors[0]);
            debugPrint("Added first color to end for smooth gradient loop");
          }

          baseWidget = ZoAnimatedGradientBorder(
            borderRadius: currentRadius,
            borderThickness: currentWidth,
            gradientColor: smoothGradientColors,
            glowOpacity: glowOpacity,
            duration: Duration(seconds: durationSeconds),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: borderRadiusObj,
              ),
              child: child ??
                  const Text("Gradient Border",
                      style: TextStyle(color: Colors.black)),
            ),
          );
        } else {
          // Default to ZoDualBorder
          baseWidget = ZoDualBorder(
            duration: Duration(seconds: durationSeconds),
            glowOpacity: glowOpacity,
            firstBorderColor:
                widget.control.attrColor("firstDualColor", context) ??
                    Colors.blue,
            secondBorderColor:
                widget.control.attrColor("secondDualColor", context) ??
                    Colors.red,
            trackBorderColor:
                widget.control.attrColor("trackDualColor", context) ??
                    Colors.grey,
            borderWidth: currentWidth,
            borderRadius: borderRadiusObj,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: borderRadiusObj,
              ),
              child: child ??
                  const Text("Dual Border",
                      style: TextStyle(color: Colors.black)),
            ),
          );
        }

        return constrainedControl(
            context, baseWidget, widget.parent, widget.control);
      },
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.backend.triggerControlEvent(
          widget.control.id, "animation_end", "animated_border");
    }
  }
}
