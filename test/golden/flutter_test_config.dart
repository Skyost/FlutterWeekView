import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

/// Golden tests for doing screenshot diffing tests. Run:
/// flutter test [--name=Golden]            to run the tests
/// flutter test --update-goldens           to update the golden imagens
///                                           (--name=<regexp> to update only one/some of them)
///
/// (--name=Golden filters all golden tests)
///
/// While support for Golden tests is available in Flutter out-of-the-box, there are some caveats:
///
/// 1) Font loading in tests is fairly limited. The default test is a font called Ahem which will
/// show black spaces for every character. golden_toolkit's [loadAppFonts] partially fixes it, but
/// fonts might still be wrong sometimes (for example, different font weights may not work).
///
/// 2) The default [FlutterWeekViewEvent.eventTextBuilder] uses RichText, which may have font
/// problems. This can be fixed by making sure to set 'fontFamily: Roboto' in
/// [FlutterWeekViewEvent.textStyle] in these tests.
///
/// 3) Different OSes/Flutter versions generate different files: https://github.com/flutter/flutter/issues/36667
/// Thus, if you're doing a PR, you may want to generate your own golden images before starting
/// editing, use them to check that everything's ok, but don't push them.
Future<void> main(List<String> arguments, FutureOr<void> Function() testMain) async {
  // Loading fonts as in (1) above
  await loadAppFonts();
  return testMain();
}
