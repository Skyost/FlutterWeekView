import 'dart:collection';

import 'package:flutter_week_view/src/controller.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/headers.dart';
import 'package:flutter_week_view/src/utils.dart';
import 'package:flutter/material.dart';

/// Returns a string from a specified date.
typedef DateFormatter = String Function(int year, int month, int day);

/// Returns a string from a specified hour.
typedef HourFormatter = String Function(int hour, int minute);

/// Builds an event text widget.
typedef EventTextBuilder = Widget Function(BuildContext context, DayView dayView, double height, double width);

/// Allows to calculate a top offset from a given hour.
typedef TopOffsetCalculator = double Function(int hour);

/// A (scrollable) day view which is able to display events, zoom and un-zoom and more !
class DayView extends ZoomableHeadersWidget<DayViewController> {
  /// The events.
  final List<FlutterWeekViewEvent> events;

  /// The day view date.
  final DateTime date;

  /// The events column background painter.
  final EventsColumnBackgroundPainter eventsColumnBackgroundPainter;

  /// The current time rule color.
  final Color currentTimeRuleColor;

  /// The current time circle color.
  final Color currentTimeCircleColor;

  /// Creates a new day view instance.
  DayView({
    List<FlutterWeekViewEvent> events,
    @required DateTime date,
    EventsColumnBackgroundPainter eventsColumnBackgroundPainter,
    this.currentTimeRuleColor = Colors.pink,
    this.currentTimeCircleColor,
    DayViewController controller,
    DateFormatter dateFormatter,
    HourFormatter hourFormatter,
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
  })  : assert(date != null),
        date = DateTime(date.year, date.month, date.day),
        eventsColumnBackgroundPainter = eventsColumnBackgroundPainter ?? EventsColumnBackgroundPainter(backgroundColor: Utils.sameDay(date) ? const Color(0xFFE3F5FF) : const Color(0xFFF2F2F2)),
        events = events ?? [],
        super(
          controller: controller ?? DayViewController(),
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
  State<StatefulWidget> createState() => _DayViewState();
}

/// The day view state.
class _DayViewState extends ZoomableHeadersWidgetState<DayView, DayViewController> {
  /// Contains all events draw properties.
  final Map<FlutterWeekViewEvent, _EventDrawProperties> eventsDrawProperties = HashMap();

  /// The flutter week view events.
  List<FlutterWeekViewEvent> events;

  @override
  void initState() {
    super.initState();

    reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => createEventsDrawProperties());
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
    Widget mainStack = Stack(
      children: [
        createMainWidget(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DayBar.fromHeadersWidget(
            parent: widget,
            date: widget.date,
          ),
        ),
      ],
    );

    if (!isZoomable) {
      return mainStack;
    }

    return GestureDetector(
      onScaleStart: (_) => widget.controller.scaleStart(),
      onScaleUpdate: (details) => widget.controller.scaleUpdate(details),
      child: mainStack,
    );
  }

  @override
  void onZoomFactorChanged(DayViewController controller, ScaleUpdateDetails details) {
    super.onZoomFactorChanged(controller, details);

    if (mounted) {
      setState(() => createEventsDrawProperties());
    }
  }

  /// Creates the main widget, with a hours column and an events column.
  Widget createMainWidget() {
    List<Widget> children = eventsDrawProperties.entries.map((entry) => entry.value.createWidget(context, widget, entry.key)).toList();
    if (widget.hoursColumnWidth > 0) {
      children.add(Positioned(
        top: 0,
        left: 0,
        child: HoursColumn.fromHeadersWidget(parent: widget),
      ));
    }

    if (widget.currentTimeRuleColor != null && Utils.sameDay(widget.date)) {
      children.add(createCurrentTimeRule());
      if (widget.currentTimeCircleColor != null) {
        children.add(createCurrentTimeCircle());
      }
    }

    Widget mainWidget = SizedBox(
      height: calculateHeight(),
      child: Stack(children: children..insert(0, createBackground())),
    );

    if (widget.inScrollableWidget) {
      mainWidget = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          controller: widget.controller.verticalScrollController,
          child: mainWidget,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: widget.dayBarHeight),
      child: mainWidget,
    );
  }

  /// Creates the background widgets that should be added to a stack.
  Widget createBackground() => Positioned.fill(
        child: CustomPaint(painter: widget.eventsColumnBackgroundPainter),
      );

  /// Creates a positioned horizontal rule in the hours column.
  Widget createCurrentTimeRule() {
    DateTime now = DateTime.now();
    return Positioned(
      top: calculateTopOffset(now.hour, now.minute),
      left: widget.hoursColumnWidth,
      right: 0,
      child: Container(
        height: 1,
        color: widget.currentTimeRuleColor,
      ),
    );
  }

  /// Creates a positioned horizontal rule in the hours column.
  Widget createCurrentTimeCircle([double radius = 15]) {
    DateTime now = DateTime.now();
    return Positioned(
      top: calculateTopOffset(now.hour, now.minute) - (radius / 2),
      right: 0,
      child: Container(
        height: radius,
        width: radius,
        decoration: BoxDecoration(
          color: widget.currentTimeCircleColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  bool get shouldScrollToCurrentTime => super.shouldScrollToCurrentTime && Utils.sameDay(widget.date);

  /// Resets the events positioning and background painter arguments.
  void reset() {
    eventsDrawProperties.clear();
    events = List.of(widget.events)..sort();
    widget.eventsColumnBackgroundPainter.topOffsetCalculator = calculateTopOffset;
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
      double eventsColumnWidth = (context.findRenderObject() as RenderBox).size.width - widget.hoursColumnWidth;
      eventsGrid.processEvents(widget.hoursColumnWidth, eventsColumnWidth);
    }
  }
}

/// The events column background painter.
class EventsColumnBackgroundPainter extends CustomPainter {
  /// The color.
  final Color backgroundColor;

  /// The rules color.
  final Color rulesColor;

  /// The top offset calculator.
  /// The day view state will give it its real value.
  TopOffsetCalculator topOffsetCalculator = defaultTopOffsetCalculator;

  /// Creates a new events column background painter.
  EventsColumnBackgroundPainter({
    this.backgroundColor,
    this.rulesColor = const Color(0x1A000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = backgroundColor);
    }

    if (rulesColor != null) {
      for (int hour = 1; hour < 24; hour++) {
        double topOffset = topOffsetCalculator(hour);
        canvas.drawLine(Offset(0, topOffset), Offset(size.width, topOffset), Paint()..color = rulesColor);
      }
    }
  }

  @override
  bool shouldRepaint(EventsColumnBackgroundPainter oldDayViewBackgroundPainter) {
    return backgroundColor != oldDayViewBackgroundPainter.backgroundColor || rulesColor != oldDayViewBackgroundPainter.rulesColor || topOffsetCalculator != oldDayViewBackgroundPainter.topOffsetCalculator;
  }

  /// The default top offset calculator.
  static double defaultTopOffsetCalculator(int hour) => hour * 60.0;
}

/// An utility class that allows to position events in a grid.
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
    if (shouldDraw || (!Utils.sameDay(event.start, dayView.date) && !Utils.sameDay(event.end, dayView.date))) {
      return;
    }

    start = event.start;
    end = event.end;

    if (start.isBefore(dayView.date)) {
      start = dayView.date;
    }

    DateTime tomorrow = dayView.date.add(const Duration(days: 1));
    if (end.isAfter(tomorrow)) {
      end = tomorrow;
    }
  }

  /// Whether this event should be drawn.
  bool get shouldDraw => start != null && end != null;

  /// Calculates the top and the height of the event rectangle.
  void calculateTopAndHeight(_DayViewState state) {
    top = state.calculateTopOffset(start.hour, start.minute);
    height = state.calculateTopOffset(0, end.difference(start).inMinutes) + 1;
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
