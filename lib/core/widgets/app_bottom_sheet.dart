import 'package:flutter/material.dart';

import 'bottom_nav_bar.dart';

/// Bottom inset that keeps modal sheet content above [AppBottomNavBar]
/// while still respecting the on-screen keyboard.
EdgeInsets appBottomSheetInsets(
  BuildContext context, {
  bool accountForNavBar = true,
}) {
  final mq = MediaQuery.of(context);
  final navInset = accountForNavBar ? AppBottomNavBar.reservedHeight(context) : 0.0;
  return EdgeInsets.only(bottom: mq.viewInsets.bottom + navInset);
}

/// App-wide modal bottom sheet that avoids overlapping the floating nav bar.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool enableDrag = true,
  bool accountForNavBar = true,
  Color backgroundColor = Colors.transparent,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    enableDrag: enableDrag,
    builder: (context) => Padding(
      padding: appBottomSheetInsets(context, accountForNavBar: accountForNavBar),
      child: builder(context),
    ),
  );
}
