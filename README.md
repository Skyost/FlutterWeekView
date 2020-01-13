# Flutter Week View

Displays a highly customizable week view (or day view) which is able to display events, to be scrolled, to be zoomed-in & out and a lot more !

Flutter Week View is highly inspired by [Android Week View](https://github.com/thellmund/Android-Week-View).

## Getting Started

Getting started with Flutter Week View is very straight forward.
You have the choice between two widgets : `FlutterDayView` and `FlutterWeekView`.
Use the first one to display a single day and use the second one to display
multiple days. 

## Example

If you want a <q>real project</q> example, you can check [this one](https://github.com/Skyost/FlutterWeekView/tree/master/example) on Github.

### Day View

Snippet :

```dart
// Let's get two dates :
DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);

// And here's our widget !
return DayView(
  date: now,
  events: [
    FlutterWeekViewEvent(
      title: 'An event 1',
      description: 'A description 1',
      start: date.subtract(Duration(hours: 1)),
      end: date.add(Duration(hours: 18, minutes: 30)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 2',
      description: 'A description 2',
      start: date.add(Duration(hours: 19)),
      end: date.add(Duration(hours: 22)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 3',
      description: 'A description 3',
      start: date.add(Duration(hours: 23, minutes: 30)),
      end: date.add(Duration(hours: 25, minutes: 30)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 4',
      description: 'A description 4',
      start: date.add(Duration(hours: 20)),
      end: date.add(Duration(hours: 21)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 5',
      description: 'A description 5',
      start: date.add(Duration(hours: 20)),
      end: date.add(Duration(hours: 21)),
    ),
  ],
  currentTimeCircleColor: Colors.pink,
);
```

Result :

<img src="https://github.com/Skyost/FlutterWeekView/raw/master/screenshots/day_view.png" height="500">

### Week view

Snippet :

```dart
// Let's get two dates :
DateTime now = DateTime.now();
DateTime date = DateTime(now.year, now.month, now.day);

// And here's our widget !
return WeekView(
  dates: [date.subtract(Duration(days: 1)), date, date.add(Duration(days: 1))],
  events: [
    FlutterWeekViewEvent(
      title: 'An event 1',
      description: 'A description 1',
      start: date.subtract(Duration(hours: 1)),
      end: date.add(Duration(hours: 18, minutes: 30)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 2',
      description: 'A description 2',
      start: date.add(Duration(hours: 19)),
      end: date.add(Duration(hours: 22)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 3',
      description: 'A description 3',
      start: date.add(Duration(hours: 23, minutes: 30)),
      end: date.add(Duration(hours: 25, minutes: 30)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 4',
      description: 'A description 4',
      start: date.add(Duration(hours: 20)),
      end: date.add(Duration(hours: 21)),
    ),
    FlutterWeekViewEvent(
      title: 'An event 5',
      description: 'A description 5',
      start: date.add(Duration(hours: 20)),
      end: date.add(Duration(hours: 21)),
    ),
  ],
);
```

Result :

<img src="https://github.com/Skyost/FlutterWeekView/raw/master/screenshots/week_view.gif" height="500">

## Options

### Common options

Here are the options that are available for both `FlutterDayView` and `FlutterWeekView` :

* `events` Events to display.
* `dateFormatter` The function that returns a formatted date as a String from a year, a month and a day.
* `hourFormatter` The function that returns a formatted hour as a String from a hour and a minute.
* `dayBarTextStyle` The day bar (top bar) text style.
* `dayBarHeight` The day bar height (≤ 0 to disable).
* `dayBarBackgroundColor` The day bar background color (`null` to remove).
* `hoursColumnTextStyle` The hours column (left column) text style.
* `hoursColumnWidth` The hours column width (≤ 0 to disable).
* `hoursColumnBackgroundColor` The hours column background color.
* `hourRowHeight` A hour row height (with a zoom factor of _1.0_).
* `inScrollableWidget` Whether to put the widget in a scrollable widget (disable if you want to manage the scroll by yourself).
* `scrollToCurrentTime` Whether the widget should automatically scroll to the current time (hour and minute with day if you are in a Week View).
* `userZoomable` Whether the user is able to (un)zoom the widget.

### Flutter day view

Here are the specific options of `FlutterDayView` :

* `date` The widget date.
* `eventsColumnBackgroundColor` The events column background color (`null` to remove).
* `eventsColumnBackgroundRulesColor` The events column background rules color (`null` to remove).
* `currentTimeRuleColor` The current time rule color (`null` to disable).
* `currentTimeCircleColor` The current time circle color (`null` or blank to disable).

### Flutter week view

Here are the specific options of `FlutterWeekView` :

* `dates` The widget dates.
* `dayViewBuilder` The function that allows to build a Day View widget.
* `dayViewWidth` A Day View width.

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/FlutterWeekView/fork) on Github.
* [Submit](https://github.com/Skyost/FlutterWeekView/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.
* [Watch a little ad](https://utip.io/skyost) on uTip.