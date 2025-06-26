import 'package:flutter/material.dart';
import 'dart:math';

/// A widget that wraps its child with responsive scaling capabilities
/// based on the device's screen size and orientation.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double designWidth;
  final double designHeight;
  final bool allowFontScaling;
  final double maxTextScaleFactor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.designWidth = 360, // Default design width (mobile-first)
    this.designHeight = 640, // Default design height
    this.allowFontScaling = true,
    this.maxTextScaleFactor = 1.4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            // Get screen dimensions
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            // Calculate scaling factors
            final widthScale = screenWidth / designWidth;
            final heightScale = screenHeight / designHeight;
            final scaleFactor = min(widthScale, heightScale);

            // Calculate text scale factor
            final textScaleFactor = allowFontScaling
                ? min(scaleFactor, maxTextScaleFactor)
                : 1.0;

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScaleFactor),
              ),
              child: Builder(
                builder: (context) {
                  // Provide responsive values to descendants
                  return _ResponsiveValues(
                    scaleFactor: scaleFactor,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    orientation: orientation,
                    child: child,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Provides responsive values to widget tree
class _ResponsiveValues extends InheritedWidget {
  final double scaleFactor;
  final double screenWidth;
  final double screenHeight;
  final Orientation orientation;

  const _ResponsiveValues({
    required this.scaleFactor,
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ResponsiveValues oldWidget) {
    return scaleFactor != oldWidget.scaleFactor ||
        screenWidth != oldWidget.screenWidth ||
        screenHeight != oldWidget.screenHeight ||
        orientation != oldWidget.orientation;
  }

  static _ResponsiveValues? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ResponsiveValues>();
  }
}

/// Extension methods for easy access to responsive values
extension ResponsiveExtensions on BuildContext {
  /// Returns the scale factor based on design width
  double get scaleFactor => _ResponsiveValues.of(this)?.scaleFactor ?? 1.0;

  /// Returns the screen width
  double get screenWidth => _ResponsiveValues.of(this)?.screenWidth ?? 360;

  /// Returns the screen height
  double get screenHeight => _ResponsiveValues.of(this)?.screenHeight ?? 640;

  /// Returns the current orientation
  Orientation get orientation =>
      _ResponsiveValues.of(this)?.orientation ?? Orientation.portrait;

  /// Scales width according to design width
  double scaleWidth(double width) => width * scaleFactor;

  /// Scales height according to design height
  double scaleHeight(double height) => height * scaleFactor;

  /// Scales font size according to design width
  double scaleFont(double fontSize) => fontSize * scaleFactor;
}