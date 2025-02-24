import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

/// First plugin test method.
void main() => runApp(_FlutterWeekViewDemoApp());

/// The demo material app.
class _FlutterWeekViewDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Week View Demo',
        initialRoute: '/',
        routes: {
          '/': (context) => inScaffold(body: _FlutterWeekViewDemoAppBody()),
          '/day-view': (context) => inScaffold(
                title: 'Demo day view',
                body: _DemoDayView(),
              ),
          '/week-view': (context) => inScaffold(
                title: 'Demo week view',
                body: _DemoWeekView(),
              ),
          '/dynamic-day-view': (context) => _DynamicDayView(),
        },
      );

  static Widget inScaffold({
    String title = 'Flutter Week View',
    required Widget body,
  }) =>
      Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: body,
      );
}

/// The demo app body widget.
class _FlutterWeekViewDemoAppBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String github = 'https://github.com/Skyost/FlutterWeekView';
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                'Flutter Week View demo',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              child: const Text('Demo day view'),
              onPressed: () => Navigator.pushNamed(context, '/day-view'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Demo week view'),
              onPressed: () => Navigator.pushNamed(context, '/week-view'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Demo dynamic day view'),
              onPressed: () => Navigator.pushNamed(context, '/dynamic-day-view'),
            ),
            const Expanded(
              child: SizedBox.expand(),
            ),
            GestureDetector(
              onTap: () async {
                Uri uri = Uri.parse(github);
                if (await launcher.canLaunchUrl(uri)) {
                  await launcher.launchUrl(uri);
                }
              },
              child: Text(
                github,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The demo day view widget.
class _DemoDayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    return DayView(
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      date: now,
      events: [
        FlutterWeekViewEvent(
          title: 'An event 1',
          description: 'A description 1',
          start: date.subtract(const Duration(hours: 1)),
          end: date.add(const Duration(hours: 18, minutes: 30)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 2',
          description: 'A description 2',
          start: date.add(const Duration(hours: 19)),
          end: date.add(const Duration(hours: 22)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 3',
          description: 'A description 3',
          start: date.add(const Duration(hours: 23, minutes: 30)),
          end: date.add(const Duration(hours: 25, minutes: 30)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 4',
          description: 'A description 4',
          start: date.add(const Duration(hours: 20)),
          end: date.add(const Duration(hours: 21)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 5',
          description: 'A description 5',
          start: date.add(const Duration(hours: 20)),
          end: date.add(const Duration(hours: 21)),
        ),
      ],
      style: DayViewStyle.fromDate(
        date: date,
        currentTimeCircleColor: Colors.pink,
      ),
    );
  }
}

/// The demo week view widget.
class _DemoWeekView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    return WeekView(
      initialTime: DateTime.now().copyWith(hour: 7, minute: 0),
      dates: [date.subtract(const Duration(days: 1)), date, date.add(const Duration(days: 1))],
      events: [
        FlutterWeekViewEvent(
          title: 'An event 1',
          description: 'A description 1',
          start: date.subtract(const Duration(hours: 1)),
          end: date.add(const Duration(hours: 18, minutes: 30)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 2',
          description: 'A description 2',
          start: date.add(const Duration(hours: 19)),
          end: date.add(const Duration(hours: 22)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 3',
          description: 'A description 3',
          start: date.add(const Duration(hours: 23, minutes: 30)),
          end: date.add(const Duration(hours: 25, minutes: 30)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 4',
          description: 'A description 4',
          start: date.add(const Duration(hours: 20)),
          end: date.add(const Duration(hours: 21)),
        ),
        FlutterWeekViewEvent(
          title: 'An event 5',
          description: 'A description 5',
          start: date.add(const Duration(hours: 20)),
          end: date.add(const Duration(hours: 21)),
        ),
      ],
    );
  }
}

/// A day view that displays dynamically added events.
class _DynamicDayView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DynamicDayViewState();
}

/// The dynamic day view state.
class _DynamicDayViewState extends State<_DynamicDayView> {
  /// The added events.
  List<FlutterWeekViewEvent> events = [];

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo dynamic day view'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                DateTime start = DateTime(now.year, now.month, now.day, Random().nextInt(24), Random().nextInt(60));
                events.add(FlutterWeekViewEvent(
                  title: 'Event ${events.length + 1}',
                  start: start,
                  end: start.add(const Duration(hours: 1)),
                  description: 'A description.',
                ));
              });
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: DayView(
        date: now,
        events: events,
        onBackgroundTappedDown: (DateTime dateTime) {
          dateTime = roundTimeToFitGrid(dateTime);
          setState(() {
            events.add(FlutterWeekViewEvent(
              title: 'New event',
              description: 'A new event',
              start: dateTime,
              end: dateTime.add(const Duration(hours: 1)),
            ));
          });
        },
        dragAndDropOptions: DragAndDropOptions(
          onEventDragged: (FlutterWeekViewEvent event, DateTime newStartTime) {
            DateTime roundedTime = roundTimeToFitGrid(newStartTime, gridGranularity: const Duration(minutes: 15));
            setState(() => updateEvent(event, event.shiftEventTo(roundedTime)));
          },
        ),
        resizeEventOptions: ResizeEventOptions(
          onEventResized: (FlutterWeekViewEvent event, DateTime newEndTime) {
            setState(() => updateEvent(event, event.copyWith(end: newEndTime)));
          },
        ),
      ),
    );
  }

  /// Updates [oldEvent] to [newEvent].
  void updateEvent(FlutterWeekViewEvent oldEvent, FlutterWeekViewEvent newEvent) {
    List<FlutterWeekViewEvent> events = List.of(this.events);
    int index = events.indexOf(oldEvent);
    if (index >= 0) {
      events[index] = newEvent;
    }
  }
}
