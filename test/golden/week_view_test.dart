import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_utils.dart';

void main() {
  final textStyleForEvents = const TextStyle(fontFamily: 'Roboto');
  final date = DateTime(2020, 1, 1);
  final dates = [date.subtract(const Duration(days: 1)), date, date.add(const Duration(days: 1))];
  final now = DateTime(2020, 1, 1, 8, 0);
  injectDateTimeGetterForTest(StubNowDateTimeGetter(now));

  final events = [
    FlutterWeekViewEvent(
      title: 'An event 1',
      description: 'A description 1',
      start: date.subtract(const Duration(hours: 1)),
      end: date.add(const Duration(hours: 18, minutes: 30)),
      textStyle: textStyleForEvents,
    ),
    FlutterWeekViewEvent(
      title: 'An event 2',
      description: 'A description 2',
      start: date.add(const Duration(hours: 19)),
      end: date.add(const Duration(hours: 22)),
      textStyle: textStyleForEvents,
    ),
    FlutterWeekViewEvent(
      title: 'An event 3',
      description: 'A description 3',
      start: date.add(const Duration(hours: 23, minutes: 30)),
      end: date.add(const Duration(hours: 25, minutes: 30)),
      textStyle: textStyleForEvents,
    ),
    FlutterWeekViewEvent(
      title: 'An event 4',
      description: 'A description 4',
      start: date.add(const Duration(hours: 20)),
      end: date.add(const Duration(hours: 21)),
      textStyle: textStyleForEvents,
    ),
    FlutterWeekViewEvent(
      title: 'An event 5',
      description: 'A description 5',
      start: date.add(const Duration(hours: 20)),
      end: date.add(const Duration(hours: 21)),
      textStyle: textStyleForEvents,
    ),
  ];

  testGoldens('Week view shows events and starts at current day/time', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      WeekView(
        dates: dates,
        scrollToCurrentTime: true,
        events: events,
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'week_view_shows_events');
  });

  testGoldens('Week view starts at initialTime arg of the first date', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      WeekView(
        dates: dates,
        scrollToCurrentTime: false,
        initialTime: const HourMinute(hour: 6).atDate(DateTime.now()),
        events: events,
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'week_view_starts_at_initial_time');
  });

  testGoldens('Week view correctly shows events which span more than 1 day', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      WeekView(
        dates: dates,
        style: const WeekViewStyle(dayViewWidth: 90.0),
        dayViewStyleBuilder: (date) => const DayViewStyle(hourRowHeight: 30.0),
        events: [
          FlutterWeekViewEvent(
            title: 'An event 1',
            description: 'A description 1',
            start: date.subtract(const Duration(hours: 6)),
            end: date.add(const Duration(days: 1, hours: 6)),
            textStyle: textStyleForEvents,
          ),
          FlutterWeekViewEvent(
            title: 'An event 2',
            description: 'A description 2',
            start: date.add(const Duration(hours: 10)),
            end: date.add(const Duration(hours: 15)),
            textStyle: textStyleForEvents,
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'week_view_multi_day_event');
  });

  testGoldens('Week view styling options work', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      WeekView(
        dates: dates,
        scrollToCurrentTime: false,
        initialTime: const HourMinute(hour: 6).atDate(DateTime.now()),
        events: events,
        style: const WeekViewStyle(
          headerSize: 60.0,
          dayViewWidth: 80.0,
          dayViewSeparatorWidth: 5.0,
          dayViewSeparatorColor: Colors.yellow,
        ),
        dayBarStyleBuilder: (date) => DayBarStyle(
          dateFormatter: (year, month, day) => '$day/$month/$year',
          textStyle: const TextStyle(color: Colors.green),
          color: Colors.yellow,
        ),
        hoursColumnStyle: HoursColumnStyle(
          timeFormatter: (hourMinute) => '${hourMinute.hour}h${hourMinute.minute.toString().padLeft(2, '0')}',
          textStyle: const TextStyle(color: Colors.green),
          width: 80.0,
          color: Colors.orange[200],
        ),
        dayViewStyleBuilder: (date) => const DayViewStyle(
            hourRowHeight: 80.0
        ),
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'week_view_styling_options');
  });

  testGoldens('Week view minimum and maximum time are respected', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      WeekView(
        dates: dates,
        scrollToCurrentTime: true,
        minimumTime: const HourMinute(hour: 14),
        maximumTime: const HourMinute(hour: 20, minute: 30),
        events: events,
        style: const WeekViewStyle(
          dayViewWidth: 80.0,
        ),
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'week_view_minimum_maximum_time');

    assert(
        false,
        'This test should currently fail, see issue #44: '
        'https://github.com/Skyost/FlutterWeekView/issues/44');
    assert(false, "Also, what's up with that blue line on the top the 3rd day's calendar?");
  });
}
