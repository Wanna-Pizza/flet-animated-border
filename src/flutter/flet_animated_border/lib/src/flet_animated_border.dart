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

  Color _prevFirstDualColor = Colors.blue;
  Color _prevSecondDualColor = Colors.red;
  Color _prevTrackDualColor = Colors.grey;

  late AnimationController _controller;
  late Animation<double> _borderWidthAnim;
  late Animation<double> _borderRadiusAnim;

  late Animation<Color?> _firstDualColorAnim;
  late Animation<Color?> _secondDualColorAnim;
  late Animation<Color?> _trackDualColorAnim;

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
      double targetWidth,
      double targetRadius,
      Color firstColor,
      Color secondColor,
      Color trackColor,
      Duration duration,
      Curve curve) {
    _borderWidthAnim = Tween<double>(
      begin: _prevBorderWidth,
      end: targetWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _borderRadiusAnim = Tween<double>(
      begin: _prevBorderRadius,
      end: targetRadius,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _firstDualColorAnim = ColorTween(
      begin: _prevFirstDualColor,
      end: firstColor,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _secondDualColorAnim = ColorTween(
      begin: _prevSecondDualColor,
      end: secondColor,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _trackDualColorAnim = ColorTween(
      begin: _prevTrackDualColor,
      end: trackColor,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _prevBorderWidth = targetWidth;
    _prevBorderRadius = targetRadius;
    _prevFirstDualColor = firstColor;
    _prevSecondDualColor = secondColor;
    _prevTrackDualColor = trackColor;

    _controller.reset();
    _controller.duration = duration;
    _controller.forward();
  }

  void _initializeAnimationsWithCurrentValues(
      double targetWidth,
      double targetRadius,
      Color firstColor,
      Color secondColor,
      Color trackColor) {
    _borderWidthAnim = AlwaysStoppedAnimation<double>(targetWidth);
    _borderRadiusAnim = AlwaysStoppedAnimation<double>(targetRadius);
    _firstDualColorAnim = AlwaysStoppedAnimation<Color?>(firstColor);
    _secondDualColorAnim = AlwaysStoppedAnimation<Color?>(secondColor);
    _trackDualColorAnim = AlwaysStoppedAnimation<Color?>(trackColor);
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

    final targetFirstDualColor =
        widget.control.attrColor("firstDualColor", context) ?? Colors.blue;
    final targetSecondDualColor =
        widget.control.attrColor("secondDualColor", context) ?? Colors.red;
    final targetTrackDualColor =
        widget.control.attrColor("trackDualColor", context) ?? Colors.grey;

    List<Color> gradientColors = [];

    final gradientColorsJson = widget.control.attrList("gradientColors");
    if (gradientColorsJson != null) {
      gradientColors = gradientColorsJson
          .map((colorStr) =>
              parseColor(Theme.of(context), colorStr.toString()) ??
              Colors.white)
          .toList();
    }

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
            _prevFirstDualColor != targetFirstDualColor ||
            _prevSecondDualColor != targetSecondDualColor ||
            _prevTrackDualColor != targetTrackDualColor ||
            true);

    if (_isFirstBuild || hasChanges) {
      // Update previous values regardless of animation state
      _prevBorderWidth = targetBorderWidth;
      _prevBorderRadius = targetBorderRadius;
      _prevFirstDualColor = targetFirstDualColor;
      _prevSecondDualColor = targetSecondDualColor;
      _prevTrackDualColor = targetTrackDualColor;

      if (_isFirstBuild) {
        _isFirstBuild = false;
        // Initialize animations with current values without transitions
        _initializeAnimationsWithCurrentValues(
            targetBorderWidth,
            targetBorderRadius,
            targetFirstDualColor,
            targetSecondDualColor,
            targetTrackDualColor);
      } else if (animation != null) {
        // Animate to new values
        debugPrint("Starting animation for properties and colors");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setupAndStartAnimations(
              targetBorderWidth,
              targetBorderRadius,
              targetFirstDualColor,
              targetSecondDualColor,
              targetTrackDualColor,
              animDuration,
              animCurve);
        });
      } else {
        // Update values without animation
        _initializeAnimationsWithCurrentValues(
            targetBorderWidth,
            targetBorderRadius,
            targetFirstDualColor,
            targetSecondDualColor,
            targetTrackDualColor);
      }
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
            child: child,
          );

          return constrainedControl(
              context, contentWidget, widget.parent, widget.control);
        }

        Widget baseWidget;

        if (borderType == "soft_gradient") {
          var smoothGradientColors = [...gradientColors];

          if (smoothGradientLoop && smoothGradientColors.length > 1) {
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
              child: child,
            ),
          );
        } else {
          baseWidget = ZoDualBorder(
            duration: Duration(seconds: durationSeconds),
            glowOpacity: glowOpacity,
            firstBorderColor: _firstDualColorAnim.value ?? Colors.blue,
            secondBorderColor: _secondDualColorAnim.value ?? Colors.red,
            trackBorderColor: _trackDualColorAnim.value ?? Colors.grey,
            borderWidth: currentWidth,
            borderRadius: borderRadiusObj,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: borderRadiusObj,
              ),
              child: child,
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
