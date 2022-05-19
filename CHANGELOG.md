## [1.2.2] - 2022-05-19

* Fixed various warnings and errors.

## [1.2.1+1] - 2021-10-27

* Fixed a compilation error.

## [1.2.1] - 2021-10-27

* Now keeps pinch focal point when zoom-in/out (thanks [BiliBalaaaaaa](https://github.com/BiliBalaaaaaa)).
* `maxZoom` value is now assigned in contructor (thanks [BiliBalaaaaaa](https://github.com/BiliBalaaaaaa)).

## [1.2.0] - 2021-08-15

* Added RTL support (thanks [nirbar89](https://github.com/nirbar89)).
* Fixed various bugs (thanks [jayjah](https://github.com/jayjah)).

## [1.1.0] - 2021-03-05

* Migrated to null safety.

## [1.0.0+2] - 2021-01-14

* Fixed a subtraction logic error (thanks [Yoropiata](https://github.com/Yoropiata)).
* Fixed various state errors.

## [1.0.0+1] - 2020-08-19

* Fixed a bug when updating the Week View.

## [1.0.0] - 2020-08-05

* Added `currentTimeIndicatorBuilder`, `onDayBarTappedDown` and `dayBarStyleBuilder` parameters.
* Removed `scrollToCurrentTime` in favor of `initialTime`.
* Various internal changes.
* Fixed a lot of bugs.

## [0.3.1] - 2020-06-25

* Rewritten the `WeekViewController` class.
* Fixed a bug when `inScrollableWidget` was set to `false` in the Week View.
* Improved documentation (thanks [luistrivelatto](https://github.com/luistrivelatto)).
* Added a separator between day views on the Week View (thanks [luistrivelatto](https://github.com/luistrivelatto)).
* Added some customisation options for current time rule and circle (thanks [AnkitPanchal10](https://github.com/AnkitPanchal10)).

## [0.3.0+2] - 2020-05-22

* Fixed an issue with controllers.

## [0.3.0+1] - 2020-05-18

* Fixed an issue with `hourRowHeight`.

## [0.3.0] - 2020-05-17

* Added a `Style` class for `DayView` and `WeekView`.
* Replaced the `dayViewBuilder` by a `dayViewStyleBuilder` in `WeekView`.
* Added a tap down list for hours column.
* Added the ability to restrict the current visible time.
* Removed the background canvas painter. It was maybe a bit too complicated to use.
* Various fixes and improvements.

## [0.2.1+7] - 2020-03-18

* Fixed a bug with custom event text builders.

## [0.2.1+6] - 2020-03-12

* Fixed a bug with initial scrolling.

## [0.2.1+5] - 2020-03-10

* Fixed a bug with events positioning.
* Added the ability to change the initial hour / minute.
* Fixed day bar positioning in `DayView`.
* Enabled the possibility to decorate the events (thanks [kuemme01](https://github.com/kuemme01)).

## [0.2.1+4] - 2020-02-18

* Fixed a bug with `ZoomController` in stateful context.

## [0.2.1+3] - 2020-02-17

* Fixed a bug that disallowed to put the widget in a stateful context.

## [0.2.1+2] - 2020-02-17

* Fixed a problem with the current time rule circle.

## [0.2.1+1] - 2020-02-13

* Fixed a problem with the current time rule.

## [0.2.1] - 2020-02-02

* Added the ability to create a `WeekView` widget with a builder.
* Fixed a problem with controllers that were not usable.

## [0.2.0+2] - 2020-01-27

* A little bug fixed.

## [0.2.0+1] - 2020-01-23

* Performance improvement (see [#8](https://github.com/Skyost/FlutterWeekView/issues/8)).

## [0.2.0] - 2020-01-21

* Added the ability to completely change the background.
* Performance improvement (see [#7](https://github.com/Skyost/FlutterWeekView/issues/7)).

## [0.1.0+1] - 2020-01-15

* Fixed a bug where events that weren't overlapping the current date were not displayed.

## [0.1.0] - 2020-01-13

* First public Beta.
