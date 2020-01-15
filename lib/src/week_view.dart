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
          dayBarHeight: dayBarHeight ?? 40,
          dayBarBackgroundColor: dayBarBackgroundColor,
          hoursColumnTextStyle: hoursColumnTextStyle,
          hoursColumnWidth: hoursColumnWidth ?? 60,
          hoursColumnBackgroundColor: hoursColumnBackgroundColor,
          hourRowHeight: hourRowHeight ?? 60,
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

    return createMainWidget(context);
  }

  @override
  void dispose() {
    controller.dispose(false);
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
  Widget createMainWidget(BuildContext context) {
    Widget weekViewStack = createWeekViewStack(context);
    if (widget.inScrollableWidget) {
      weekViewStack = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: widget.hoursColumnWidth),
          controller: controller.horizontalScrollController,
          scrollDirection: Axis.horizontal,
          physics: MagnetScrollPhysics(itemSize: dayViewWidth),
          child: weekViewStack,
        ),
      );
    }

    if (widget.userZoomable) {
      weekViewStack = GestureDetector(
        onScaleStart: (_) => controller.scaleStart(),
        onScaleUpdate: (details) => controller.scaleUpdate(details),
        child: weekViewStack,
      );
    }

    return Stack(
      children: [
        weekViewStack,
        _PositionedHoursColumn(state: this),
        Positioned(
          top: 0,
          left: 0,
          height: widget.dayBarHeight,
          width: widget.hoursColumnWidth,
          child: Container(color: widget.dayBarBackgroundColor ?? Color(0xFFEBEBEB)),
        ),
      ],
    );
  }

  /// Creates the week view stack.
  Widget createWeekViewStack(BuildContext context) {
    Widget dayViewsRow = createDayViewsRow(context);
    if (widget.inScrollableWidget) {
      dayViewsRow = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: widget.dayBarHeight),
          controller: controller.verticalScrollController,
          child: dayViewsRow,
        ),
      );
    }

    return Stack(
      children: [
        dayViewsRow,
        Positioned(
          top: 0,
          left: 0,
          child: createDayBarsRow(context),
        ),
      ],
    );
  }

  /// Creates the day bars row.
  Widget createDayBarsRow(BuildContext context) => Row(
        children: widget.dates
            .map((date) => SizedBox(
                  width: dayViewWidth,
                  child: DayBar.fromHeadersWidget(
                    parent: widget,
                    date: date,
                  ),
                ))
            .toList(),
      );

  /// Creates the views rows.
  Widget createDayViewsRow(BuildContext context) => Row(
        children: [
          for (int i = 0; i < widget.dates.length; i++)
            SizedBox(
              width: dayViewWidth,
              child: widget.dayViewBuilder(context, widget, widget.dates[i], controller.dayViewControllers[i]),
            ),
        ],
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

/// A hours column that position itself in a stack according to the current scroll position.
class _PositionedHoursColumn extends StatefulWidget {
  /// The week view.
  final WeekView weekView;

  /// The week view controller.
  final WeekViewController weekViewController;

  /// Creates a new positioned hours column instance.
  _PositionedHoursColumn({
    _WeekViewState state,
  })  : weekView = state.widget,
        weekViewController = state.controller;

  @override
  State<StatefulWidget> createState() => _PositionedHoursColumnState(this);
}

/// The positioned hours column state.
class _PositionedHoursColumnState extends State<_PositionedHoursColumn> with WeekViewControllerListener {
  /// The current top position.
  double top = 0;

  /// The current zoom factor.
  double zoomFactor = 1;

  /// Creates a new positioned hours column state instance.
  _PositionedHoursColumnState(_PositionedHoursColumn positionedHoursColumn);

  @override
  void initState() {
    super.initState();
    widget.weekViewController.verticalScrollController.addListener(onScrolledVertically);
    widget.weekViewController.listeners.add(this);
  }

  @override
  Widget build(BuildContext context) {
    HoursColumn hoursColumn = HoursColumn.fromHeadersWidget(
      parent: widget.weekView,
      zoomFactor: zoomFactor,
    );
    return Positioned(
      top: widget.weekView.dayBarHeight + top,
      left: 0,
      child: hoursColumn.width == 0 ? SizedBox.shrink() : hoursColumn,
    );
  }

  @override
  void dispose() {
    widget.weekViewController.verticalScrollController.removeListener(onScrolledVertically);
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

  /// Triggered when the user has scrolled vertically.
  void onScrolledVertically() {
    /*
     * TODO: When the user is scrolling the hours column, the zoom factor changed method is getting triggered.
     * TODO: As a workaround, I've put the gesture listener outside of the hours column.
     * TODO: A good idea would be to solve this problem (yes' sir).
     */
    setState(() {
      top = (-1) * widget.weekViewController.verticalScrollController.position.pixels;
    });
  }
}
