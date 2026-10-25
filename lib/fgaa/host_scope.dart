import 'package:flutter/widgets.dart';

/// Explicit host ownership, independent of when appearance messages arrive.
class HostScope extends InheritedWidget {
  const HostScope({super.key, required this.embedded, required super.child});

  final bool embedded;

  static bool isEmbedded(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HostScope>()?.embedded ?? false;

  @override
  bool updateShouldNotify(HostScope oldWidget) => embedded != oldWidget.embedded;
}
