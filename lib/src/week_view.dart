import 'dart:math' as Math;
import 'package:flutter/scheduler.dart';
import 'package:flutter_week_view/src/controller.dart';
import 'package:flutter_week_view/src/day_view.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/headers.dart';
import 'package:flutter_week_view/src/utils.dart';
import 'package:flutter/material.dart';

/// Builds a day view.
typedef DayView DayViewBuilder(BuildContext context, WeekView weekView, DateTime date, DayViewController dayViewController);

/// A (scrollable) week view which is able to display events, zoom and un-zoom and more !
class WeekView extends HeadersWidget {
  /// The events.
  final List<FlutterWeekViewEvent> events;

  /// The dates.
  final List<DateTime> dates;

  /// The day view builder.
  final DayViewBuilder dayViewBuilder;

  /// A day view width.
  final double dayViewWidth;

  /// Whether the widget should automatically be placed in a scrollable widget.
  final bool inScrollableWidget;

  /// Whether the widget should automatically scroll to the current time (hour and minute).
  final bool scrollToCurrentTime;

  /// Whether the user is able to pinch-to-zoom the widget.
  final bool userZoomable;

  /// The current day view controller.
  final WeekViewController controller;

  /// Creates a new week view instance.
  WeekView({
    List<FlutterWeekViewEvent> events,
    @required this.dates,
    this.dayViewBuilder = DefaultBuilders.defaultDayViewBuilder,
    this.dayViewWidth,
    this.inScrollableWidget = true,
    this.scrollToCurrentTime = true,
    this.userZoomable = true,
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
  })  : assert(dates != null && dates.isNotEmpty),
        assert(dayViewBuilder != null),
        assert(scrollToCurrentTime != null),
        assert(userZoomable != null),
        this.events = events ?? [],
        this.controller = controller ?? WeekViewController(dayViewsCount: dates.length),
        super(
          dateFormatter: dateFormatter ?? DefaultBuilders.defaultDateFormatter,
          hourFormatter: hourFormatter ?? DefaultBuilders.defaultHourFormatter,
          dayBarTextStyle: dayBarTextStyle,
          dayBarHeight: dayBarHeight,
          dayBarBackgroundColor: dayBarBackgroundColor,
          hoursColumnTextStyle: hoursColumnTextStyle,
          hoursColumnWidth: hoursColumnWidth,
          hoursColumnBackgroundColor: hoursColumnBackgroundColor,
          hourRowHeight: hourRowHeight,
        );

  @override
  State<StatefulWidget> createState() => _WeekViewState(this);
}

/// The week view state.
class _WeekViewState extends State<WeekView> with WeekViewControllerListener {
  /// The current controller.
  final WeekViewController controller;

  /// A day view width.
  double dayViewWidth;

  /// The hour row height.
  double hourRowHeight;

  /// Creates a new week view state instance.
  _WeekViewState(WeekView weekView)
      : controller = weekView.controller,
        dayViewWidth = weekView.dayViewWidth,
        hourRowHeight = weekView.hourRowHeight;

  @override
  void initState() {
    super.initState();
    controller.listeners.add(this);

    if (dayViewWidth == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        double widgetWidth = (context.findRenderObject() as RenderBox).size.width;
        setState(() => dayViewWidth = widgetWidth - widget.hoursColumnWidth);
        scheduleScrollToCurrentTimeIfNeeded();
      });
    } else {
      scheduleScrollToCurrentTimeIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dayViewWidth == null) {
      return SizedBox.expand();
    }

    return createMainWidget();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void onZoomFactorChanged(WeekViewController controller, ScaleUpdateDetails details) {
    if (!mounted) {
      return;
    }

    double hourRowHeight = widget.hourRowHeight * controller.zoomFactor;

    if (widget.inScrollableWidget) {
      double widgetHeight = (context.findRenderObject() as RenderBox).size.height;
      double maxPixels = (hourRowHeight * 24) - widgetHeight + widget.dayBarHeight;

      if (hourRowHeight < this.hourRowHeight && controller.verticalScrollController.position.pixels > maxPixels) {
        controller.verticalScrollController.jumpTo(maxPixels);
      } else {
        controller.verticalScrollController.jumpTo(Math.min(maxPixels, details.localFocalPoint.dy));
      }
    }

    this.hourRowHeight = hourRowHeight;
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

    if (widget.userZoomable && controller.dayViewControllers.first.zoomCoefficient > 0) {
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
        height: 24 * hourRowHeight,
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
        _AutoResizeHoursColumn(state: this),
      ],
    );
  }

  /// Creates the day view at the specified index.
  Widget createDayView(int index) => SizedBox(
        width: dayViewWidth,
        child: widget.dayViewBuilder(context, widget, widget.dates[index], controller.dayViewControllers[index]),
      );

  /// Schedules a post frame action that is going to scroll to the current day, hour and minute.
  void scheduleScrollToCurrentTimeIfNeeded() {
    if (!widget.scrollToCurrentTime) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      int index = 0;
      for (; index < widget.dates.length; index++) {
        if (Utils.overlapsDate(widget.dates[index])) {
          break;
        }
      }

      if (index == widget.dates.length) {
        return;
      }

      DateTime now = DateTime.now();
      double topOffset = (now.hour + (now.minute / 60)) * hourRowHeight;
      double leftOffset = dayViewWidth * index;

      controller.verticalScrollController.jumpTo(Math.min(topOffset, controller.verticalScrollController.position.maxScrollExtent));
      controller.horizontalScrollController.jumpTo(Math.min(leftOffset, controller.horizontalScrollController.position.maxScrollExtent));
    });
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

/// A hours column that resizes itself according to the week view zoom state.
class _AutoResizeHoursColumn extends StatefulWidget {
  /// The week view.
  final WeekView weekView;

  /// The week view controller.
  final WeekViewController weekViewController;

  /// Creates a new positioned hours column instance.
  _AutoResizeHoursColumn({
    @required _WeekViewState state,
  })  : weekView = state.widget,
        weekViewController = state.controller;

  @override
  State<StatefulWidget> createState() => _AutoResizeHoursColumnState();
}

/// The auto resize hours column state.
class _AutoResizeHoursColumnState extends State<_AutoResizeHoursColumn> with WeekViewControllerListener {
  /// The current zoom factor.
  double zoomFactor = 1;

  @override
  void initState() {
    super.initState();
    zoomFactor = widget.weekViewController.zoomFactor;
    widget.weekViewController.listeners.add(this);
  }

  @override
  Widget build(BuildContext context) => HoursColumn.fromHeadersWidget(
        parent: widget.weekView,
        zoomFactor: zoomFactor,
      );

  @override
  void dispose() {
    widget.weekViewController.listeners.remove(this);
    super.dispose();
  }

  @override
  void onZoomFactorChanged(WeekViewController controller, ScaleUpdateDetails details) {
    if (!mounted) {
      return;
    }

    setState(() {
      this.zoomFactor = controller.zoomFactor;
    });
  }
}
