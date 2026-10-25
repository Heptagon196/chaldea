import 'package:material_ui/material_ui.dart';

class HostAppearance {
  final bool dark;
  final Color accent, background, surface;
  const HostAppearance(this.dark, this.accent, this.background, this.surface);
  factory HostAppearance.fromJson(Map<String, dynamic> value) {
    Color color(String key) {
      final text = value[key];
      if (text is! String || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(text)) throw const FormatException();
      return Color(0xff000000 | int.parse(text.substring(1), radix: 16));
    }

    if (value['dark'] is! bool) throw const FormatException();
    return HostAppearance(value['dark'], color('accent'), color('background'), color('surface'));
  }
  ThemeData apply(ThemeData base) => base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: accent,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
  );
}

final hostAppearance = ValueNotifier<HostAppearance?>(null);
