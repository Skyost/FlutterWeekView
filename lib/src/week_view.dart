import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller.dart';
import 'package:flutter_week_view/src/day_view.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/headers.dart';
import 'package:flutter_week_view/src/hour_minute.dart';
import 'package:flutter_week_view/src/style.dart';
import 'package:flutter_week_view/src/utils.dart';

/// Builds a day view.
typedef DayViewStyleBuilder = DayViewStyle Function(DateTime date);

/// Creates a date according to the specified index.
typedef DateCreator = DateTime Function(int index);

/// A (scrollable) week view which is able to display events, zoom and un-zoom and more !
class WeekView extends ZoomableHeadersWidget<WeekViewStyle, WeekViewController> {
  /// The number of dates.
  final int dateCount;

  /// The date creator.
  final DateCreator dateCreator;

  /// The events.
  final List<FlutterWeekViewEvent> events;

  /// The day view style builder.
  final DayViewStyleBuilder dayViewStyleBuilder;

  /// Creates a new week view instance.
  WeekView({
    List<FlutterWeekViewEvent> events,
    @required List<DateTime> dates,
    this.dayViewStyleBuilder = DefaultBuilders.defaultDayViewStyleBuilder,
    WeekViewStyle style,
    WeekViewController controller,
    bool inScrollableWidget = true,
    HourMinute minimumTime = HourMinute.MIN,
    HourMinute maximumTime = HourMinute.MAX,
    HourMinute initialTime = HourMinute.MIN,
    bool scrollToCurrentTime = true,
    bool userZoomable = true,
    HoursColumnTappedDownCallback onHoursColumnTappedDown,
  })  : assert(dates != null && dates.isNotEmpty),
        assert(dayViewStyleBuilder != null),
        dateCount = dates?.length ?? 0,
        dateCreator = ((index) => DefaultBuilders.defaultDateCreator(dates, index)),
        events = events ?? [],
        super(
          style: style ?? const WeekViewStyle(),
          controller: controller ?? WeekViewController(dayViewsCount: dates.length),
          inScrollableWidget: inScrollableWidget,
          minimumTime: minimumTime,
          maximumTime: maximumTime,
          initialTime: initialTime,
          scrollToCurrentTime: scrollToCurrentTime,
          userZoomable: userZoomable,
          onHoursColumnTappedDown: onHoursColumnTappedDown,
        );

  /// Creates a new week view instance.
  WeekView.builder({
    List<FlutterWeekViewEvent> events,
    this.dateCount,
    @required this.dateCreator,
    this.dayViewStyleBuilder = DefaultBuilders.defaultDayViewStyleBuilder,
    WeekViewStyle style,
    WeekViewController controller,
    bool inScrollableWidget = true,
    HourMinute minimumTime = HourMinute.MIN,
    HourMinute maximumTime = HourMinute.MAX,
    HourMinute initialTime = HourMinute.MIN,
    bool scrollToCurrentTime = true,
    bool userZoomable = true,
    HoursColumnTappedDownCallback onHoursColumnTappedDown,
  })  : assert(dateCount == null || dateCount >= 0),
        assert(dateCreator != null),
        assert(dayViewStyleBuilder != null),
        events = events ?? [],
        super(
          style: style ?? const WeekViewStyle(),
          controller: controller ?? WeekViewController(dayViewsCount: dateCount),
          inScrollableWidget: inScrollableWidget,
          minimumTime: minimumTime,
          maximumTime: maximumTime,
          initialTime: initialTime,
          scrollToCurrentTime: scrollToCurrentTime,
          userZoomable: userZoomable,
          onHoursColumnTappedDown: onHoursColumnTappedDown,
        );

  @override
  State<StatefulWidget> createState() => _WeekViewState();
}

/// The week view state.
class _WeekViewState extends ZoomableHeadersWidgetState<WeekView> {
  /// A day view width.
  double dayViewWidth;

  @override
  void initState() {
    super.initState();

    dayViewWidth = widget.style.dayViewWidth;
    if (dayViewWidth != null) {
      scheduleScrolls();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double widgetWidth = (context.findRenderObject() as RenderBox).size.width;
      setState(() {
        dayViewWidth = widgetWidth - widget.style.hoursColumnWidth;
        scheduleScrolls();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dayViewWidth == null) {
      return const SizedBox.expand();
    }

    return createMainWidget();
  }

  /// Creates the main widget.
  Widget createMainWidget() {
    Widget weekViewStack = createWeekViewStack();
    if (widget.inScrollableWidget) {
      weekViewStack = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: widget.style.dayBarHeight),
          controller: widget.controller.verticalScrollController,
          child: weekViewStack,
        ),
      );
    }

    if (isZoomable) {
      weekViewStack = GestureDetector(
        onScaleStart: (_) => widget.controller.scaleStart(),
        onScaleUpdate: (details) => widget.controller.scaleUpdate(details),
        child: weekViewStack,
      );
    }

    return Stack(
      children: [
        weekViewStack,
        _AutoScrollDayBar(
          state: this,
        ),
        Container(
          height: widget.style.dayBarHeight,
          width: widget.style.hoursColumnWidth,
          color: widget.style.dayBarBackgroundColor ?? const Color(0xFFEBEBEB),
        ),
      ],
    );
  }

  /// Creates the week view stack.
  Widget createWeekViewStack() => Stack(
        children: [
          SizedBox(
            height: calculateHeight(),
            child: ListView.builder(
              padding: EdgeInsets.only(left: widget.style.hoursColumnWidth),
              controller: widget.controller.horizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: widget.inScrollableWidget ? MagnetScrollPhysics(itemSize: dayViewWidth) : const NeverScrollableScrollPhysics(),
              itemCount: widget.dateCount,
              itemBuilder: (context, index) => createDayView(index),
            ),
          ),
          HoursColumn.fromHeadersWidgetState(parent: this),
        ],
      );

  /// Creates the day view at the specified index.
  Widget createDayView(int index) {
    DateTime date = widget.dateCreator(index);
    return SizedBox(
      width: dayViewWidth,
      child: DayView(
        date: date,
        events: widget.events,
        style: widget.dayViewStyleBuilder(date).copyWith(
              dayBarHeight: 0,
              hoursColumnWidth: 0,
              hourRowHeight: widget.style.hourRowHeight,
            ),
        controller: widget.controller.dayViewControllers[index],
        minimumTime: widget.minimumTime,
        maximumTime: widget.maximumTime,
        inScrollableWidget: false,
        userZoomable: false,
        scrollToCurrentTime: false,
      ),
    );
  }

  @override
  bool get shouldScrollToCurrentTime {
    if (widget.dateCount == null) {
      return false;
    }

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    bool hasCurrentDay = false;
    if (widget.dateCount != null) {
      for (int i = 0; i < widget.dateCount; i++) {
        if (widget.dateCreator(i) == today) {
          hasCurrentDay = true;
          break;
        }
      }
    }

    return dayViewWidth != null && super.shouldScrollToCurrentTime && hasCurrentDay;
  }

  @override
  void scrollToCurrentTime() {
    super.scrollToCurrentTime();

    int index = 0;
    if (widget.dateCount != null) {
      for (; index < widget.dateCount; index++) {
        if (Utils.sameDay(widget.dateCreator(index))) {
          break;
        }
      }
    }

    double topOffset = calculateTopOffset(HourMinute.now());
    double leftOffset = dayViewWidth * index;

    widget.controller.verticalScrollController.jumpTo(math.min<double>(topOffset, widget.controller.verticalScrollController.position.maxScrollExtent));
    widget.controller.horizontalScrollController.jumpTo(math.min<double>(leftOffset, widget.controller.horizontalScrollController.position.maxScrollExtent));
  }
}

/// A day bar that scroll itself according to the current week view scroll position.
class _AutoScrollDayBar extends StatefulWidget {
  /// The week view.
  final WeekView weekView;

  /// A day view width.
  final double dayViewWidth;

  /// Creates a new positioned day bar instance.
  _AutoScrollDayBar({
    @required _WeekViewState state,
  })  : weekView = state.widget,
        dayViewWidth = state.dayViewWidth;

  @override
  State<StatefulWidget> createState() => _AutoScrollDayBarState();
}

/// The auto scroll day bar state.
class _AutoScrollDayBarState extends State<_AutoScrollDayBar> {
  /// The day bar scroll controller.
  ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = SilentScrollController();
    scrollController.addListener(onScrolledHorizontally);
    widget.weekView.controller.horizontalScrollController.addListener(updateScrollPosition);

    WidgetsBinding.instance.scheduleFrameCallback((_) => updateScrollPosition());
  }

  @override
  void didUpdateWidget(_AutoScrollDayBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.weekView.controller.horizontalScrollController.addListener(updateScrollPosition);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.weekView.style.dayBarHeight,
        child: ListView.builder(
          itemCount: widget.weekView.dateCount,
          itemBuilder: (context, position) => SizedBox(
            width: widget.dayViewWidth,
            child: DayBar.fromHeadersWidget(
              parent: widget.weekView,
              date: widget.weekView.dateCreator(position),
            ),
          ),
          physics: MagnetScrollPhysics(itemSize: widget.dayViewWidth),
          padding: EdgeInsets.only(left: widget.weekView.style.hoursColumnWidth),
          controller: scrollController,
          scrollDirection: Axis.horizontal,
        ),
      );

  @override
  void dispose() {
    scrollController.dispose();
    widget.weekView.controller.horizontalScrollController.removeListener(updateScrollPosition);
    super.dispose();
  }

  /// Triggered when this widget is scrolling horizontally.
  void onScrolledHorizontally() => updateScrollBasedOnAnother(scrollController, widget.weekView.controller.horizontalScrollController);

  /// Triggered when the week view is scrolling horizontally.
  void updateScrollPosition() => updateScrollBasedOnAnother(widget.weekView.controller.horizontalScrollController, scrollController);

  /// Updates a scroll controller position based on another scroll controller.
  void updateScrollBasedOnAnother(ScrollController base, SilentScrollController target) {
    if (!mounted) {
      return;
    }

    target.silentJumpTo(base.position.pixels);
  }
}
