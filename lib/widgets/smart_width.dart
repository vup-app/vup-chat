import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// This widget is a universal way to limit the width of a widget based on
/// constraints and different platforms
class SmartWidth extends StatelessWidget {
  final Widget child;
  const SmartWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // If the width is below the breakpoint of the splitview, minimize the
    // margin to just enough to not hit the sides. This makes mobile views
    // look better
    double width = MediaQuery.sizeOf(context).width;
    if (width < 730) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: child,
      );
      // this is for when it's split
    } else {
      double width;
      if (400.h < 200.w) {
        width = 400.h;
      } else {
        width = 200.w;
      }
      return SizedBox(
        width: width,
        child: child,
      );
    }
  }
}
