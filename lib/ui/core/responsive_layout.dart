import 'package:flutter/widgets.dart';

/// Breakpoints shared by the app's content layouts.
abstract final class AppBreakpoints {
  static const double smallMobile = 360;
  static const double tablet = 600;
  static const double desktop = 768;
  static const double wideContent = 1180;

  static int gridColumns(double width) {
    if (width >= 900) return 3;
    if (width >= tablet) return 2;
    return 1;
  }

  static double pagePadding(double width) => width < smallMobile ? 12 : 20;
}

/// Keeps phone and tablet content readable on very wide displays.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.wideContent,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
