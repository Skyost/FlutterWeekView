import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/controller.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/headers.dart';
import 'package:flutter_week_view/src/hour_minute.dart';
import 'package:flutter_week_view/src/style.dart';
import 'package:flutter_week_view/src/utils.dart';

/// A (scrollable) day view which is able to display events, zoom and un-zoom and more !
class DayView extends ZoomableHeadersWidget<DayViewStyle, DayViewController> {
  /// The events.
  final List<FlutterWeekViewEvent> events;

  /// The day view date.
  final DateTime date;

  /// The day bar style.
  final DayBarStyle dayBarStyle;

  /// Creates a new day view instance.
  DayView({
    List<FlutterWeekViewEvent> events,
    @required DateTime date,
    DayViewStyle style,
    HoursColumnStyle hoursColumnStyle,
    DayBarStyle dayBarStyle,
    DayViewController controller,
    bool inScrollableWidget,
    HourMinute minimumTime,
    HourMinute maximumTime,
    HourMinute initialTime,
    bool scrollToCurrentTime,
    bool userZoomable,
    HoursColumnTapCallback onHoursColumnTappedDown,
    DayBarTapCallback onDayBarTappedDown,
  })  : assert(date != null),
        date = date.yearMonthDay,
        events = events ?? [],
        dayBarStyle = dayBarStyle ?? DayBarStyle.fromDate(date: date),
        super(
          style: style ?? DayViewStyle.fromDate(date: date),
          hoursColumnStyle: hoursColumnStyle ?? const HoursColumnStyle(),
          controller: controller ?? DayViewController(),
          inScrollableWidget: inScrollableWidget ?? true,
          minimumTime: minimumTime ?? HourMinute.MIN,
          maximumTime: maximumTime ?? HourMinute.MAX,
          initialTime: initialTime ?? HourMinute.MIN,
          scrollToCurrentTime: scrollToCurrentTime ?? true,
          userZoomable: userZoomable ?? true,
          onHoursColumnTappedDown: onHoursColumnTappedDown,
          onDayBarTappedDown: onDayBarTappedDown,
        );

  @override
  State<StatefulWidget> createState() => _DayViewState();
}

/// The day view state.
class _DayViewState extends ZoomableHeadersWidgetState<DayView> {
  /// Contains all events draw properties.
  final Map<FlutterWeekViewEvent, _EventDrawProperties> eventsDrawProperties = HashMap();

  /// The flutter week view events.
  List<FlutterWeekViewEvent> events;

  @override
  void initState() {
    super.initState();
    scheduleScrolls();
    reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(createEventsDrawProperties);
      }
    });
  }

  @override
  void didUpdateWidget(DayView oldWidget) {
    super.didUpdateWidget(oldWidget);

    reset();
    createEventsDrawProperties();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget = createMainWidget();
    if (widget.style.headerSize > 0 || widget.hoursColumnStyle.width > 0) {
      mainWidget = Stack(
        children: [
          mainWidget,
          Positioned(
            top: 0,
            left: widget.hoursColumnStyle.width,
            right: 0,
            child: DayBar.fromHeadersWidgetState(
              parent: widget,
              date: widget.date,
              style: widget.dayBarStyle,
              width: double.infinity,
            ),
          ),
          Container(
            height: widget.style.headerSize,
            width: widget.hoursColumnStyle.width,
            color: widget.dayBarStyle.color,
          ),
        ],
      );
    }

    if (!isZoomable) {
      return mainWidget;
    }

    return GestureDetector(
      onScaleStart: (_) => widget.controller.scaleStart(),
      onScaleUpdate: widget.controller.scaleUpdate,
      child: mainWidget,
    );
  }

  @override
  void onZoomFactorChanged(DayViewController controller, ScaleUpdateDetails details) {
    super.onZoomFactorChanged(controller, details);

    if (mounted) {
      setState(createEventsDrawProperties);
    }
  }

  @override
  DayViewStyle get currentDayViewStyle => widget.style;

  @override
  bool get shouldScrollToCurrentTime => super.shouldScrollToCurrentTime && Utils.sameDay(widget.date);

  /// Creates the main widget, with a hours column and an events column.
  Widget createMainWidget() {
    List<Widget> children = eventsDrawProperties.entries.map((entry) => entry.value.createWidget(context, widget, entry.key)).toList();
    if (widget.hoursColumnStyle.width > 0) {
      children.add(Positioned(
        top: 0,
        left: 0,
        child: HoursColumn.fromHeadersWidgetState(parent: this),
      ));
    }

    if (Utils.sameDay(widget.date) && widget.minimumTime.atDate(widget.date).isBefore(DateTime.now()) && widget.maximumTime.atDate(widget.date).isAfter(DateTime.now())) {
      if (widget.style.currentTimeRuleColor != null && widget.style.currentTimeRuleHeight > 0) {
        children.add(createCurrentTimeRule());
      }

      if (widget.style.currentTimeCircleColor != null && widget.style.currentTimeCircleRadius > 0) {
        children.add(createCurrentTimeCircle());
      }
    }

    Widget mainWidget = SizedBox(
      height: calculateHeight(),
      child: Stack(children: children..insert(0, createBackground())),
    );

    if (verticalScrollController != null) {
      mainWidget = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          controller: verticalScrollController,
          child: mainWidget,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: widget.style.headerSize),
      child: mainWidget,
    );
  }

  /// Creates the background widgets that should be added to a stack.
  Widget createBackground() => Positioned.fill(
        child: CustomPaint(
          painter: widget.style.createBackgroundPainter(
            dayView: widget,
            topOffsetCalculator: calculateTopOffset,
          ),
        ),
      );

  /// Creates the horizontal rule in the day view column, positioned at the current time of the day.
  Widget createCurrentTimeRule() => Positioned(
        top: calculateTopOffset(HourMinute.now()),
        left: widget.hoursColumnStyle.width,
        right: 0,
        child: Container(
          height: widget.style.currentTimeRuleHeight,
          color: widget.style.currentTimeRuleColor,
        ),
      );

  /// Creates the current time circle, shown along with the horizontal rule in the day view column.
  Widget createCurrentTimeCircle() => Positioned(
        top: calculateTopOffset(HourMinute.now()) - widget.style.currentTimeCircleRadius,
        right: widget.style.currentTimeCirclePosition == CurrentTimeCirclePosition.right ? 0 : null,
        left: widget.style.currentTimeCirclePosition == CurrentTimeCirclePosition.left ? widget.hoursColumnStyle.width : null,
        child: Container(
          height: widget.style.currentTimeCircleRadius * 2,
          width: widget.style.currentTimeCircleRadius * 2,
          decoration: BoxDecoration(
            color: widget.style.currentTimeCircleColor,
            shape: BoxShape.circle,
          ),
        ),
      );

  /// Resets the events positioning.
  void reset() {
    eventsDrawProperties.clear();
    events = List.of(widget.events)..sort();
  }

  /// Creates the events draw properties and add them to the current list.
  void createEventsDrawProperties() {
    _EventsGrid eventsGrid = _EventsGrid();
    for (FlutterWeekViewEvent event in List.of(events)) {
      _EventDrawProperties drawProperties = eventsDrawProperties[event] ?? _EventDrawProperties(widget, event);
      if (!drawProperties.shouldDraw) {
        events.remove(event);
        continue;
      }

      drawProperties.calculateTopAndHeight(this);
      if (drawProperties.left == null || drawProperties.width == null) {
        eventsGrid.add(drawProperties);
      }

      eventsDrawProperties[event] = drawProperties;
    }

    if (eventsGrid.drawPropertiesList.isNotEmpty) {
      double eventsColumnWidth = (context.findRenderObject() as RenderBox).size.width - widget.hoursColumnStyle.width;
      eventsGrid.processEvents(widget.hoursColumnStyle.width, eventsColumnWidth);
    }
  }
}

/// An useful class that allows to position events in a grid.
/// Thanks to https://stackoverflow.com/a/11323909/3608831.
class _EventsGrid {
  /// Events draw properties added to the grid.
  List<_EventDrawProperties> drawPropertiesList = [];

  /// Adds a flutter week view event draw properties.
  void add(_EventDrawProperties drawProperties) => drawPropertiesList.add(drawProperties);

  /// Processes all display properties added to the grid.
  void processEvents(double hoursColumnWidth, double eventsColumnWidth) {
    List<List<_EventDrawProperties>> columns = [];
    DateTime lastEventEnding;
    for (_EventDrawProperties drawProperties in drawPropertiesList) {
      if (lastEventEnding != null && drawProperties.start.isAfter(lastEventEnding)) {
        packEvents(columns, hoursColumnWidth, eventsColumnWidth);
        columns.clear();
        lastEventEnding = null;
      }

      bool placed = false;
      for (List<_EventDrawProperties> column in columns) {
        if (!column.last.collidesWith(drawProperties)) {
          column.add(drawProperties);
          placed = true;
          break;
        }
      }

      if (!placed) {
        columns.add([drawProperties]);
      }

      if (lastEventEnding == null || drawProperties.end.compareTo(lastEventEnding) > 0) {
        lastEventEnding = drawProperties.end;
      }
    }

    if (columns.isNotEmpty) {
      packEvents(columns, hoursColumnWidth, eventsColumnWidth);
    }
  }

  /// Sets the left and right positions for each event in the connected group.
  void packEvents(List<List<_EventDrawProperties>> columns, double hoursColumnWidth, double eventsColumnWidth) {
    for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      List<_EventDrawProperties> column = columns[columnIndex];
      for (_EventDrawProperties drawProperties in column) {
        drawProperties.left = hoursColumnWidth + (columnIndex / columns.length) * eventsColumnWidth;
        int colSpan = calculateColSpan(columns, drawProperties, columnIndex);
        drawProperties.width = (eventsColumnWidth * colSpan) / (columns.length);
      }
    }
  }

  /// Checks how many columns the event can expand into, without colliding with other events.
  int calculateColSpan(List<List<_EventDrawProperties>> columns, _EventDrawProperties drawProperties, int column) {
    int colSpan = 1;
    for (int columnIndex = column + 1; columnIndex < columns.length; columnIndex++) {
      List<_EventDrawProperties> column = columns[columnIndex];
      for (_EventDrawProperties other in column) {
        if (drawProperties.collidesWith(other)) {
          return colSpan;
        }
      }
      colSpan++;
    }

    return colSpan;
  }
}

/// An utility class that allows to display the events in the events column.
class _EventDrawProperties {
  /// The top position.
  double top;

  /// The event rectangle height.
  double height;

  /// The left position.
  double left;

  /// The event rectangle width.
  double width;

  /// The start time.
  DateTime start;

  /// The end time.
  DateTime end;

  /// Creates a new flutter week view event draw properties from the specified day view and the specified day view event.
  _EventDrawProperties(DayView dayView, FlutterWeekViewEvent event) {
    DateTime minimum = dayView.minimumTime.atDate(dayView.date);
    DateTime maximum = dayView.maximumTime.atDate(dayView.date);

    if (shouldDraw || (event.start.isBefore(minimum) && event.end.isBefore(minimum)) || (event.start.isAfter(maximum) && event.end.isAfter(maximum))) {
      return;
    }

    start = event.start;
    end = event.end;

    if (start.isBefore(minimum)) {
      start = minimum;
    }

    if (end.isAfter(maximum)) {
      end = maximum;
    }
  }

  /// Whether this event should be drawn.
  bool get shouldDraw => start != null && end != null;

  /// Calculates the top and the height of the event rectangle.
  void calculateTopAndHeight(_DayViewState state) {
    top = state.calculateTopOffset(HourMinute.fromDateTime(dateTime: start));
    height = state.calculateTopOffset(HourMinute.fromDuration(duration: end.difference(start)), minimumTime: HourMinute.MIN) + 1;
  }

  /// Returns whether this draw properties overlaps another.
  bool collidesWith(_EventDrawProperties other) {
    if (!shouldDraw || !other.shouldDraw) {
      return false;
    }

    return end.isAfter(other.start) && start.isBefore(other.end);
  }

  /// Creates the event widget.
  Widget createWidget(BuildContext context, DayView dayView, FlutterWeekViewEvent event) => Positioned(
        top: top,
        height: height,
        left: left,
        width: width,
        child: event.build(context, dayView, height, width),
      );
}
