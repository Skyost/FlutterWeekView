# Flutter Week View

[![Likes](https://badges.bar/flutter_week_view/likes)](https://pub.dev/packages/flutter_week_view/score)
[![Popularity](https://badges.bar/flutter_week_view/popularity)](https://pub.dev/packages/flutter_week_view/score)
[![Pub points](https://badges.bar/flutter_week_view/pub%20points)](https://pub.dev/packages/flutter_week_view/score)

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
  style: const DayViewStyle.fromDate(
    date: now,
    currentTimeCircleColor: Colors.pink,
  ),
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
* `style` Allows you to style your widget. A lot of different styles are available so don't hesitate to try them out !
* `hoursColumnStyle` Same, it allows you to style the hours column on the left.
* `controller` Controllers allow you to manually change the zoom settings.
* `inScrollableWidget` Whether to put the widget in a scrollable widget (disable if you want to manage the scroll by yourself).
* `minimumTime` The minimum hour and minute to display in a day.
* `maximumTime` The maximum hour and minute to display in a day.
* `initialTime` The initial hour and minute to put the widget on.
* `userZoomable` Whether the user is able to (un)zoom the widget.
* `currentTimeIndicatorBuilder` Allows you to change the default current time indicator (rule and circle).
* `onHoursColumnTappedDown` Provides a tapped down callback for the hours column. Pretty useful if you want your users to add your own events at a specific time.
* `onDayBarTappedDown` Provides a tapped down callback for the day bar.

### Flutter day view

Here are the specific options of `FlutterDayView` :

* `date` The widget date.
* `dayBarStyle` The day bar style.

### Flutter week view

Here are the specific options of `FlutterWeekView` :

* `dates` The widget dates.
* `dayViewStyleBuilder` The function that allows to build a Day View style according to the provided date.
* `dayBarStyleBuilder` The function that allows to build a Day Bar style according to the provided date.

Please note that you can create a `FlutterWeekView` instance using a builder.
All previous options are still available but you don't need to provide the `dates` list.
However, you need to provide a `DateCreator` (and a date count if you can, if it's impossible for you to do it then `scrollToCurrentTime` will not scroll to the current date).

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/FlutterWeekView/fork) on Github.
* [Submit](https://github.com/Skyost/FlutterWeekView/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.
