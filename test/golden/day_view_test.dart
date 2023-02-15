import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../test_utils.dart';

void main() {
  final textStyleForEvents = const TextStyle(fontFamily: 'Roboto');
  final date = DateTime(2020, 1, 1);
  final now = DateTime(2020, 1, 1, 8, 0);
  injectDateTimeGetterForTest(StubNowDateTimeGetter(now));

  testGoldens('Day view shows events and starts at current time', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date,
        style: DayViewStyle.fromDate(
          date: date,
          currentTimeCircleColor: Colors.pink,
        ),
        events: [
          FlutterWeekViewEvent(
            title: 'An event 1',
            description: 'A description 1',
            start: date.add(const Duration(hours: 9)),
            end: date.add(const Duration(hours: 15, minutes: 30)),
            textStyle: textStyleForEvents,
          ),
          FlutterWeekViewEvent(
            title: 'An event 2',
            description: 'A description 2',
            start: date.add(const Duration(hours: 17)),
            end: date.add(const Duration(hours: 19)),
            textStyle: textStyleForEvents,
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'day_view_shows_events');
  });

  testGoldens('Day view shows concurrent events properly and starts at initialTime arg',
      (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date,
        initialTime: const HourMinute(hour: 10),
        events: [
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
          FlutterWeekViewEvent(
            title: 'An event 6',
            description: 'A description 6',
            start: date.add(const Duration(hours: 21, minutes: 30)),
            end: date.add(const Duration(hours: 22, minutes: 30)),
            textStyle: textStyleForEvents,
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'day_view_shows_concurrent_events');
  });

  testGoldens('Day view formats accordingly if date is not today and shows correct events',
      (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date.add(const Duration(days: 1)),
        events: [
          FlutterWeekViewEvent(
            title: 'Event on 01/01',
            description: 'A description 1',
            start: date.add(const Duration(hours: 8)),
            end: date.add(const Duration(hours: 10)),
            textStyle: textStyleForEvents,
          ),
          FlutterWeekViewEvent(
            title: 'Event on 01/02',
            description: 'A description 2',
            start: date.add(const Duration(days: 1, hours: 9)),
            end: date.add(const Duration(days: 1, hours: 11)),
            textStyle: textStyleForEvents,
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'day_view_not_today');
  });

  testGoldens('Day view ellipsizes small events descriptions', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date,
        events: [
          FlutterWeekViewEvent(
            title: 'A small event 1',
            description: 'A description 1',
            start: date.add(const Duration(hours: 9)),
            end: date.add(const Duration(hours: 10)),
            textStyle: textStyleForEvents,
          ),
          FlutterWeekViewEvent(
            title: 'A small event 2',
            description: 'A description 2',
            start: date.add(const Duration(hours: 12)),
            end: date.add(const Duration(hours: 12, minutes: 45)),
            textStyle: textStyleForEvents,
          ),
          FlutterWeekViewEvent(
            title: 'A small event 3',
            description: 'A description 3',
            start: date.add(const Duration(hours: 15)),
            end: date.add(const Duration(hours: 15, minutes: 30)),
            textStyle: textStyleForEvents,
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    // TODO: is this really correct? It seems to me that event 2's time could be displayed without ellipses
    await screenMatchesGolden(tester, 'day_view_ellipsizes');
  });

  testGoldens('Day view styling options work', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date,
        initialTime: const HourMinute(hour: 7),
        style: const DayViewStyle(
          headerSize: 60.0,
          hourRowHeight: 80.0,
          backgroundColor: Colors.black54,
          backgroundRulesColor: Colors.white,
          currentTimeRuleColor: Colors.red,
          currentTimeRuleHeight: 5,
          currentTimeCircleColor: Colors.yellow,
          currentTimeCircleRadius: 20,
          currentTimeCirclePosition: CurrentTimeCirclePosition.left,
        ),
        dayBarStyle: DayBarStyle(
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
        events: [
          FlutterWeekViewEvent(
            title: 'An event 1',
            description: 'A description 1',
            start: date.add(const Duration(hours: 9)),
            end: date.add(const Duration(hours: 15, minutes: 30)),
            textStyle: textStyleForEvents,
          ),
          FlutterWeekViewEvent(
            title: 'An event 2',
            description: 'A description 2',
            start: date.add(const Duration(hours: 17)),
            end: date.add(const Duration(hours: 19)),
            textStyle: textStyleForEvents,
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'day_view_styling_options');
  });

  testGoldens('FlutterWeekViewEvent styling options work', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date,
        initialTime: const HourMinute(hour: 7),
        events: [
          FlutterWeekViewEvent(
            title: 'An event 1',
            description: 'A description 1',
            start: date.add(const Duration(hours: 9)),
            end: date.add(const Duration(hours: 15, minutes: 30)),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
              color: Colors.green,
            ),
            textStyle: const TextStyle(fontFamily: 'Roboto', color: Colors.yellow),
            padding: const EdgeInsets.all(40.0),
            margin: const EdgeInsets.all(40.0),
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'event_styling_options');
  });

  testGoldens('FlutterWeekViewEvent eventTextBuilder work', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date,
        initialTime: const HourMinute(hour: 7),
        events: [
          FlutterWeekViewEvent(
              title: 'An event 1',
              description: 'A description 1',
              start: date.add(const Duration(hours: 9)),
              end: date.add(const Duration(hours: 15, minutes: 30)),
              eventTextBuilder: (event, context, dayView, height, width) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Text('Some custom text'),
                      Container(
                        width: 100.0,
                        height: 100.0,
                        color: Colors.white,
                        child: const FlutterLogo(),
                      ),
                    ],
                  )),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'event_text_builder_custom');
  });

  testGoldens('Day view minimum and maximum time are respected', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      DayView(
        date: date,
        minimumTime: const HourMinute(hour: 14),
        maximumTime: const HourMinute(hour: 19, minute: 30),
        style: DayViewStyle.fromDate(
          date: date,
          currentTimeCircleColor: Colors.pink,
        ),
        events: [
          FlutterWeekViewEvent(
            title: 'An event 1',
            description: 'A description 1',
            start: date.add(const Duration(hours: 9)),
            end: date.add(const Duration(hours: 15, minutes: 30)),
            textStyle: textStyleForEvents,
          ),
          FlutterWeekViewEvent(
            title: 'An event 2',
            description: 'A description 2',
            start: date.add(const Duration(hours: 17)),
            end: date.add(const Duration(hours: 19)),
            textStyle: textStyleForEvents,
          ),
        ],
      ),
      surfaceSize: Device.iphone11.size,
    );

    await screenMatchesGolden(tester, 'day_view_minimum_maximum_time');
  });
}
