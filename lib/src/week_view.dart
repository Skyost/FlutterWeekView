import 'dart:math' as Math;
import 'package:flutter_week_view/src/controller.dart';
import 'package:flutter_week_view/src/day_view.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/headers.dart';
import 'package:flutter_week_view/src/utils.dart';
import 'package:flutter/material.dart';

/// Builds a day view.
typedef DayView DayViewBuilder(BuildContext context, WeekView weekView, DateTime date, DayViewController dayViewController);

/// A (scrollable) week view which is able to display events, zoom and un-zoom and more !
class WeekView extends ZoomableHeadersWidget<WeekViewController> {
  /// The events.
  final List<FlutterWeekViewEvent> events;

  /// The dates.
  final List<DateTime> dates;

  /// The day view builder.
  final DayViewBuilder dayViewBuilder;

  /// A day view width.
  final double dayViewWidth;

  /// Creates a new week view instance.
  WeekView({
    List<FlutterWeekViewEvent> events,
    @required this.dates,
    this.dayViewBuilder = DefaultBuilders.defaultDayViewBuilder,
    this.dayViewWidth,
    DateFormatter dateFormatter,
    HourFormatter hourFormatter,
    WeekViewController controller,
    TextStyle dayBarTextStyle,
    double dayBarHeight,
    Color dayBarBackgroundColor,
    TextStyle hoursColumnTextStyle,
    double hoursColumnWidth,
    Color hoursColumnBackgroundColor,
    double hourRowHeight,
    bool inScrollableWidget = true,
    bool scrollToCurrentTime = true,
    bool userZoomable = true,
  })  : assert(dates != null && dates.isNotEmpty),
        assert(dayViewBuilder != null),
        this.events = events ?? [],
        super(
          controller: controller ?? WeekViewController(dayViewsCount: dates.length),
          dateFormatter: dateFormatter ?? DefaultBuilders.defaultDateFormatter,
          hourFormatter: hourFormatter ?? DefaultBuilders.defaultHourFormatter,
          dayBarTextStyle: dayBarTextStyle,
          dayBarHeight: dayBarHeight,
          dayBarBackgroundColor: dayBarBackgroundColor,
          hoursColumnTextStyle: hoursColumnTextStyle,
          hoursColumnWidth: hoursColumnWidth,
          hoursColumnBackgroundColor: hoursColumnBackgroundColor,
          hourRowHeight: hourRowHeight,
          inScrollableWidget: inScrollableWidget,
          scrollToCurrentTime: scrollToCurrentTime,
          userZoomable: userZoomable,
        );

  @override
  State<StatefulWidget> createState() => _WeekViewState(this);
}

/// The week view state.
class _WeekViewState extends ZoomableHeadersWidgetState<WeekView, WeekViewController> {
  /// A day view width.
  double dayViewWidth;

  /// Creates a new week view state instance.
  _WeekViewState(WeekView weekView) : super(weekView);

  @override
  void initState() {
    super.initState();

    if (dayViewWidth != null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double widgetWidth = (context.findRenderObject() as RenderBox).size.width;
      setState(() {
        dayViewWidth = widgetWidth - widget.hoursColumnWidth;
        scheduleScrollToCurrentTimeIfNeeded();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dayViewWidth == null) {
      return SizedBox.expand();
    }

    return createMainWidget();
  }

  /// Creates the main widget.
  Widget createMainWidget() {
    Widget weekViewStack = createWeekViewStack();
    if (widget.inScrollableWidget) {
      weekViewStack = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: widget.dayBarHeight),
          controller: controller.verticalScrollController,
          child: weekViewStack,
        ),
      );
    }

    if (isZoomable) {
      weekViewStack = GestureDetector(
        onScaleStart: (_) => controller.scaleStart(),
        onScaleUpdate: (details) => controller.scaleUpdate(details),
        child: weekViewStack,
      );
    }

    return Stack(
      children: [
        weekViewStack,
        _PositionedDayBar(
          state: this,
        ),
        Container(
          height: widget.dayBarHeight,
          width: widget.hoursColumnWidth,
          color: widget.dayBarBackgroundColor ?? Color(0xFFEBEBEB),
        ),
      ],
    );
  }

  /// Creates the week view stack.
  Widget createWeekViewStack() {
    Widget dayViewsList;
    if (widget.inScrollableWidget) {
      dayViewsList = SizedBox(
        height: calculateHeight(),
        child: ListView.builder(
          padding: EdgeInsets.only(left: widget.hoursColumnWidth),
          controller: controller.horizontalScrollController,
          scrollDirection: Axis.horizontal,
          physics: MagnetScrollPhysics(itemSize: dayViewWidth),
          shrinkWrap: true,
          itemCount: widget.dates.length,
          itemBuilder: (context, index) => createDayView(index),
        ),
      );
    } else {
      dayViewsList = Row(
        children: [for (int i = 0; i < widget.dates.length; i++) createDayView(i)],
      );
    }

    return Stack(
      children: [
        dayViewsList,
        HoursColumn.fromHeadersWidget(parent: widget),
      ],
    );
  }

  /// Creates the day view at the specified index.
  Widget createDayView(int index) => SizedBox(
        width: dayViewWidth,
        child: widget.dayViewBuilder(context, widget, widget.dates[index], controller.dayViewControllers[index]),
      );

  @override
  bool get shouldScrollToCurrentTime {
    DateTime now = DateTime.now();
    return dayViewWidth != null && super.shouldScrollToCurrentTime && widget.dates.contains(DateTime(now.year, now.month, now.day));
  }

  @override
  void scrollToCurrentTime() {
    super.scrollToCurrentTime();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    int index = widget.dates.indexOf(today);

    double topOffset = calculateTopOffset(now.hour, now.minute);
    double leftOffset = dayViewWidth * index;

    controller.verticalScrollController.jumpTo(Math.min(topOffset, controller.verticalScrollController.position.maxScrollExtent));
    controller.horizontalScrollController.jumpTo(Math.min(leftOffset, controller.horizontalScrollController.position.maxScrollExtent));
  }
}

/// A day bar that positions itself in a stack according to the current scroll position.
class _PositionedDayBar extends StatefulWidget {
  /// The week view.
  final WeekView weekView;

  /// A day view width.
  final double dayViewWidth;

  /// The week view controller.
  final WeekViewController weekViewController;

  /// Creates a new positioned day bar instance.
  _PositionedDayBar({
    @required _WeekViewState state,
  })  : weekView = state.widget,
        dayViewWidth = state.dayViewWidth,
        weekViewController = state.controller;

  @override
  State<StatefulWidget> createState() => _PositionedDayBarState();
}

/// The positioned day bar state.
class _PositionedDayBarState extends State<_PositionedDayBar> {
  /// The current left position.
  double left;

  @override
  void initState() {
    super.initState();
    left = widget.weekViewController.horizontalScrollController.position.pixels;
    widget.weekViewController.horizontalScrollController.addListener(onScrolledHorizontally);
  }

  @override
  Widget build(BuildContext context) => Positioned(
        top: 0,
        left: left,
        child: createDayBarsRow(),
      );

  @override
  void dispose() {
    widget.weekViewController.horizontalScrollController.removeListener(onScrolledHorizontally);
    super.dispose();
  }

  /// Creates the day bars row.
  Widget createDayBarsRow() => Row(
        children: widget.weekView.dates
            .map((date) => SizedBox(
                  width: widget.dayViewWidth,
                  child: DayBar.fromHeadersWidget(
                    parent: widget.weekView,
                    date: date,
                  ),
                ))
            .toList(),
      );

  /// Triggered when the week view is scrolling horizontally.
  void onScrolledHorizontally() {
    if (!mounted) {
      return;
    }

    setState(() {
      this.left = widget.weekView.hoursColumnWidth - widget.weekView.controller.horizontalScrollController.position.pixels;
    });
  }
}
