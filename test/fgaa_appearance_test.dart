import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:chaldea/fgaa/appearance.dart';

void main() {
  test('host appearance controls actual theme colors without accepting invalid CSS', () {
    final appearance = HostAppearance.fromJson({
      'dark': true,
      'accent': '#10b981',
      'background': '#09090b',
      'surface': '#18181b',
    });
    final theme = appearance.apply(ThemeData.light());
    expect(theme.colorScheme.brightness, Brightness.dark);
    expect(theme.colorScheme.primary, const Color(0xff10b981));
    expect(theme.scaffoldBackgroundColor, const Color(0xff09090b));
    expect(() => HostAppearance.fromJson({'dark': 'true'}), throwsFormatException);
    expect(() => HostAppearance.fromJson({'dark': true, 'accent': 'url(x)'}), throwsFormatException);
  });
}
