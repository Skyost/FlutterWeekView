import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller/week_view.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/styles/day_bar.dart';
import 'package:flutter_week_view/src/styles/day_view.dart';
import 'package:flutter_week_view/src/styles/hours_column.dart';
import 'package:flutter_week_view/src/styles/week_view.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';
import 'package:flutter_week_view/src/utils/scroll.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/day_bar.dart';
import 'package:flutter_week_view/src/widgets/hours_column.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

import 'day_view.dart';

/// Builds a day view style according to the specified date.
typedef DayViewStyleBuilder = DayViewStyle Function(DateTime date);

/// Builds a day bar style according to the specified date.
typedef DayBarStyleBuilder = DayBarStyle Function(DateTime date);

/// Creates a date according to the specified index.
typedef DateCreator = DateTime Function(int index);

/// A (scrollable) week view which is able to display events, zoom and un-zoom and more !
class WeekView
    extends ZoomableHeadersWidget<WeekViewStyle, WeekViewController> {
  /// The number of dates.
  final int dateCount;

  /// The date creator.
  final DateCreator dateCreator;

  /// The events.
  final List<FlutterWeekViewEvent> events;

  /// The day view style builder.
  final DayViewStyleBuilder dayViewStyleBuilder;

  /// The day bar style builder.
  final DayBarStyleBuilder dayBarStyleBuilder;

  /// Creates a new week view instance.
  WeekView({
    List<FlutterWeekViewEvent>? events,
    required List<DateTime> dates,
    DayViewStyleBuilder? dayViewStyleBuilder,
    DayBarStyleBuilder? dayBarStyleBuilder,
    WeekViewStyle? style,
    HoursColumnStyle? hoursColumnStyle,
    WeekViewController? controller,
    bool? inScrollableWidget,
    HourMinute? minimumTime,
    HourMinute? maximumTime,
    DateTime? initialTime,
    bool? scrollToCurrentTime,
    bool? userZoomable,
    CurrentTimeIndicatorBuilder? currentTimeIndicatorBuilder,
    HoursColumnTimeBuilder? hoursColumnTimeBuilder,
    HoursColumnTapCallback? onHoursColumnTappedDown,
    DayBarTapCallback? onDayBarTappedDown,
    bool? isRTL,
  }) : this.builder(
          events: events,
          dateCount: dates.length,
          dateCreator: ((index) =>
              DefaultBuilders.defaultDateCreator(dates, index)),
          dayViewStyleBuilder: dayViewStyleBuilder,
          dayBarStyleBuilder: dayBarStyleBuilder,
          style: style,
          hoursColumnStyle: hoursColumnStyle,
          controller: controller,
          inScrollableWidget: inScrollableWidget,
          isRTL: isRTL,
          minimumTime: minimumTime,
          maximumTime: maximumTime,
          initialTime: initialTime,
          userZoomable: userZoomable,
          currentTimeIndicatorBuilder: currentTimeIndicatorBuilder,
          hoursColumnTimeBuilder: hoursColumnTimeBuilder,
          onHoursColumnTappedDown: onHoursColumnTappedDown,
          onDayBarTappedDown: onDayBarTappedDown,
        );

  /// Creates a new week view instance.
  WeekView.builder({
    List<FlutterWeekViewEvent>? events,
    int? dateCount,
    required this.dateCreator,
    DayViewStyleBuilder? dayViewStyleBuilder,
    DayBarStyleBuilder? dayBarStyleBuilder,
    WeekViewStyle? style,
    HoursColumnStyle? hoursColumnStyle,
    WeekViewController? controller,
    bool? inScrollableWidget,
    bool? isRTL,
    HourMinute? minimumTime,
    HourMinute? maximumTime,
    DateTime? initialTime,
    bool? scrollToCurrentTime,
    bool? userZoomable,
    CurrentTimeIndicatorBuilder? currentTimeIndicatorBuilder,
    HoursColumnTimeBuilder? hoursColumnTimeBuilder,
    HoursColumnTapCallback? onHoursColumnTappedDown,
    DayBarTapCallback? onDayBarTappedDown,
  })  : events = events ?? [],
        dayViewStyleBuilder =
            dayViewStyleBuilder ?? DefaultBuilders.defaultDayViewStyleBuilder,
        dayBarStyleBuilder =
            dayBarStyleBuilder ?? DefaultBuilders.defaultDayBarStyleBuilder,
        dateCount = math.max(dateCount ?? 0, 0),
        super(
          style: style ?? const WeekViewStyle(),
          hoursColumnStyle: hoursColumnStyle ?? const HoursColumnStyle(),
          controller: controller ?? WeekViewController(),
          inScrollableWidget: inScrollableWidget ?? true,
          isRTL: isRTL ?? false,
          minimumTime: minimumTime ?? HourMinute.min,
          maximumTime: maximumTime ?? HourMinute.max,
          initialTime: initialTime ?? DateTime.now(),
          userZoomable: userZoomable ?? true,
          currentTimeIndicatorBuilder: currentTimeIndicatorBuilder ??
              DefaultBuilders.defaultCurrentTimeIndicatorBuilder,
          hoursColumnTimeBuilder: hoursColumnTimeBuilder ??
              DefaultBuilders.defaultHoursColumnTimeBuilder,
          onHoursColumnTappedDown: onHoursColumnTappedDown,
          onDayBarTappedDown: onDayBarTappedDown,
        );

  @override
  State<StatefulWidget> createState() => _WeekViewState();
}

/// The week view state.
class _WeekViewState extends ZoomableHeadersWidgetState<WeekView> {
  /// A day view width.
  double? dayViewWidth;

  /// The horizontal scroll controller.
  SilentScrollController? horizontalScrollController;

  @override
  void initState() {
    super.initState();

    if (widget.inScrollableWidget) {
      horizontalScrollController = SilentScrollController();
    }

    _calculateWidth(andScrollToCurrentTime: true);
  }

  @override
  void didUpdateWidget(WeekView oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool widthHasChanged =
        widget.style.dayViewWidth != oldWidget.style.dayViewWidth;
    bool scrollToCurrentTime = oldWidget.initialTime != widget.initialTime;
    if (widthHasChanged || scrollToCurrentTime) {
      _calculateWidth(
          setState: widthHasChanged,
          andScrollToCurrentTime: scrollToCurrentTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dayViewWidth == null) {
      return const SizedBox.expand();
    }

    return createMainWidget();
  }

  @override
  void dispose() {
    horizontalScrollController?.dispose();
    super.dispose();
  }

  @override
  bool get shouldScrollToInitialTime =>
      super.shouldScrollToInitialTime &&
      dayViewWidth != null &&
      initialTimeDateIndex != null;

  @override
  void scrollToInitialTime() {
    super.scrollToInitialTime();

    if (horizontalScrollController == null) {
      return;
    }

    double leftOffset = (initialTimeDateIndex ?? 0) *
        (dayViewWidth! + widget.style.dayViewSeparatorWidth);
    horizontalScrollController!.jumpTo(math.min<double>(
        leftOffset, horizontalScrollController!.position.maxScrollExtent));
  }

  @override
  DayViewStyle get currentDayViewStyle =>
      widget.dayViewStyleBuilder(leftMostDisplayedDate);

  DateTime get leftMostDisplayedDate {
    if (horizontalScrollController == null ||
        !horizontalScrollController!.hasClients) {
      return widget.dateCreator(0);
    }

    int index = (horizontalScrollController!.offset /
            (dayViewWidth! + widget.style.dayViewSeparatorWidth))
        .floor();
    return widget.dateCreator(index);
  }

  /// Creates the main widget.
  Widget createMainWidget() {
    Widget mainWidget = createWeekViewStack();
    if (verticalScrollController != null) {
      mainWidget = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          controller: verticalScrollController,
          child: mainWidget,
        ),
      );
    }

    if (isZoomable) {
      mainWidget = GestureDetector(
        onScaleStart: widget.controller.scaleStart,
        onScaleUpdate: widget.controller.scaleUpdate,
        child: mainWidget,
      );
    }

    return Stack(
      children: [
        mainWidget,
        Positioned(
          top: 0,
          left: widget.isRTL ? 0 : widget.hoursColumnStyle.width,
          right: widget.isRTL ? widget.hoursColumnStyle.width : 0,
          child: _AutoScrollDayBar(state: this),
        ),
        Container(
          height: widget.style.headerSize,
          width: widget.hoursColumnStyle.width,
          color: widget.dayBarStyleBuilder(widget.dateCreator(0)).color,
        ),
      ],
    );
  }

  /// Creates the week view stack.
  Widget createWeekViewStack() => Stack(
        children: [
          SizedBox(
            height: calculateHeight() + widget.style.headerSize,
            child: ListView.builder(
              padding: EdgeInsets.only(
                  left: widget.isRTL ? 0 : widget.hoursColumnStyle.width,
                  right: widget.isRTL ? widget.hoursColumnStyle.width : 0),
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: widget.inScrollableWidget
                  ? MagnetScrollPhysics(
                      itemSize:
                          dayViewWidth! + widget.style.dayViewSeparatorWidth)
                  : const NeverScrollableScrollPhysics(),
              itemCount: widget.dateCount,
              itemBuilder: (context, index) => createDayView(index),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: widget.style.headerSize),
            child: HoursColumn.fromHeadersWidgetState(parent: this),
          ),
        ],
      );

  /// Creates the day view at the specified index.
  Widget createDayView(int index) {
    DateTime date = widget.dateCreator(index);
    Widget dayView = Container(
      padding: EdgeInsets.only(top: widget.style.headerSize),
      width: dayViewWidth,
      child: DayView(
        isRTL: widget.isRTL,
        date: date,
        events: widget.events,
        style: widget.dayViewStyleBuilder(date).copyWith(headerSize: 0),
        hoursColumnStyle: const HoursColumnStyle(width: 0),
        controller: widget.controller.getDayViewController(date),
        minimumTime: widget.minimumTime,
        maximumTime: widget.maximumTime,
        currentTimeIndicatorBuilder: widget.currentTimeIndicatorBuilder,
        inScrollableWidget: false,
        userZoomable: false,
      ),
    );

    double dayViewSeparatorWidth = widget.style.dayViewSeparatorWidth;
    if (index + 1 == widget.dateCount) {
      return dayView;
    }

    return Row(
      children: [
        dayView,
        Container(
          height: calculateHeight(),
          width: dayViewSeparatorWidth,
          color: widget.style.dayViewSeparatorColor,
        ),
      ],
    );
  }

  /// Returns the current date index.
  int? get initialTimeDateIndex {
    int dateCount = widget.dateCount;
    for (int i = 0; i < dateCount; i++) {
      if (Utils.sameDay(widget.dateCreator(i), widget.initialTime)) {
        return i;
      }
    }
    return null;
  }

  /// Calculates the widget width and scroll to current time if needed.
  void _calculateWidth(
      {bool setState = false, bool andScrollToCurrentTime = false}) {
    if (setState) {
      this.setState(() => dayViewWidth = widget.style.dayViewWidth);
    } else {
      dayViewWidth = widget.style.dayViewWidth;
    }

    if (dayViewWidth != null) {
      if (andScrollToCurrentTime) {
        scheduleScrollToInitialTime();
      }
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double? widgetWidth =
          (context.findRenderObject() as RenderBox?)?.size.width;
      if (widgetWidth == null) {
        return;
      }
      this.setState(() {
        dayViewWidth = widgetWidth - widget.hoursColumnStyle.width;
        if (andScrollToCurrentTime) {
          scheduleScrollToInitialTime();
        }
      });
    });
  }
}

/// A day bar that scroll itself according to the current week view scroll position.
class _AutoScrollDayBar extends StatefulWidget {
  /// The week view.
  final WeekView weekView;

  /// A day view width.
  final double dayViewWidth;

  /// The state's scroll controller.
  final SilentScrollController stateScrollController;

  /// Builds a day bar style according to the current date.
  final DayBarStyleBuilder dayBarStyleBuilder;

  /// Creates a new positioned day bar instance.
  _AutoScrollDayBar({
    required _WeekViewState state,
  })  : weekView = state.widget,
        dayViewWidth = state.dayViewWidth!,
        stateScrollController = state.horizontalScrollController!,
        dayBarStyleBuilder = state.widget.dayBarStyleBuilder;

  @override
  State<StatefulWidget> createState() => _AutoScrollDayBarState();
}

/// The auto scroll day bar state.
class _AutoScrollDayBarState extends State<_AutoScrollDayBar> {
  /// The day bar scroll controller.
  late SilentScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = SilentScrollController();
    scrollController.addListener(onScrolledHorizontally);
    widget.stateScrollController.addListener(updateScrollPosition);

    WidgetsBinding.instance
        .scheduleFrameCallback((_) => updateScrollPosition());
  }

  @override
  void didUpdateWidget(_AutoScrollDayBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    oldWidget.stateScrollController.removeListener(updateScrollPosition);
    widget.stateScrollController.addListener(updateScrollPosition);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.weekView.style.headerSize,
        child: ListView.builder(
          itemCount: widget.weekView.dateCount,
          itemBuilder: (context, position) {
            DateTime date = widget.weekView.dateCreator(position);
            return DayBar.fromHeadersWidgetState(
              parent: widget.weekView,
              date: date,
              style: widget.dayBarStyleBuilder(date),
              width: calculateWidth(position),
            );
          },
          physics: MagnetScrollPhysics(itemSize: calculateWidth()),
          controller: scrollController,
          scrollDirection: Axis.horizontal,
        ),
      );

  @override
  void dispose() {
    scrollController.dispose();
    widget.stateScrollController.removeListener(updateScrollPosition);
    super.dispose();
  }

  /// Returns a widget width.
  double calculateWidth([int? position]) =>
      widget.dayViewWidth +
      (position == widget.weekView.dateCount
          ? 0
          : widget.weekView.style.dayViewSeparatorWidth);

  /// Triggered when this widget is scrolling horizontally.
  void onScrolledHorizontally() => updateScrollBasedOnAnother(
      scrollController, widget.stateScrollController);

  /// Triggered when the week view is scrolling horizontally.
  void updateScrollPosition() => updateScrollBasedOnAnother(
      widget.stateScrollController, scrollController);

  /// Updates a scroll controller position based on another scroll controller.
  void updateScrollBasedOnAnother(
      ScrollController base, SilentScrollController target) {
    if (!mounted) {
      return;
    }

    target.silentJumpTo(base.position.pixels);
  }
}
