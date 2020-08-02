import 'package:flutter_week_view/src/utils/utils.dart';

class StubNowDateTimeGetter implements NowDateTimeGetter {
  final DateTime _now;

  StubNowDateTimeGetter(this._now);

  @override
  DateTime now() => _now;
}
