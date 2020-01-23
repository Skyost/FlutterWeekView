import 'dart:collection';
import 'dart:math' as math;

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
        eventsColumnBackgroundPainter = eventsColumnBackgroundPainter ?? EventsColumnBackgroundPainter(backgroundColor: Utils.overlapsDate(date) ? const Color(0xFFe3f5ff) : const Color(0xFFF2F2F2)),
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
  State<StatefulWidget> createState() => _DayViewState(this);
}

/// The day view state.
class _DayViewState extends ZoomableHeadersWidgetState<DayView, DayViewController> {
  /// Contains all events draw properties.
  final Map<FlutterWeekViewEvent, _EventDrawProperties> eventsDrawProperties = HashMap();

  /// The events column background painter.
  final EventsColumnBackgroundPainter eventsColumnBackgroundPainter;

  /// The flutter week view events.
  final List<FlutterWeekViewEvent> events;

  /// Creates a new day view state.
  _DayViewState(DayView dayView)
      : eventsColumnBackgroundPainter = dayView.eventsColumnBackgroundPainter,
        events = List.of(dayView.events),
        super(dayView);

  @override
  void initState() {
    super.initState();
    events.sort((a, b) => a.start.compareTo(b.start));
    eventsColumnBackgroundPainter.topOffsetCalculator = (hour) => calculateTopOffset(hour);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => createEventsDrawProperties());
    });
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
      onScaleStart: (_) => controller.scaleStart(),
      onScaleUpdate: (details) => controller.scaleUpdate(details),
      child: mainStack,
    );
  }

  @override
  void onZoomFactorChanged(ZoomController controller, ScaleUpdateDetails details) {
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

    DateTime now = DateTime.now();
    if (widget.currentTimeRuleColor != null && Utils.overlapsDate(widget.date)) {
      children.add(createPositionedHorizontalRule(calculateTopOffset(now.hour + 1, now.minute), widget.currentTimeRuleColor));
      if (widget.currentTimeCircleColor != null) {
        double radius = 15;
        children.add(
          Positioned(
            top: calculateTopOffset(now.hour + 1, now.minute) - (radius / 2),
            right: 0,
            child: Container(
              height: radius,
              width: radius,
              decoration: BoxDecoration(
                color: widget.currentTimeCircleColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
    }

    Widget mainWidget = SizedBox(
      height: calculateHeight(),
      child: Stack(children: children..insert(0, createBackground())),
    );

    if (widget.inScrollableWidget) {
      mainWidget = NoGlowBehavior.noGlow(
        child: SingleChildScrollView(
          controller: controller.verticalScrollController,
          child: mainWidget,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: widget.dayBarHeight),
      child: mainWidget,
    );
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

  /// Creates the background widgets that should be added to a stack.
  Widget createBackground() => Positioned.fill(
        child: CustomPaint(painter: eventsColumnBackgroundPainter),
      );

  /// Creates a positioned horizontal rule in the hours column.
  Widget createPositionedHorizontalRule(double top, Color color) => Positioned(
        top: top,
        left: widget.hoursColumnWidth,
        right: 0,
        child: Container(
          height: 1,
          color: color,
        ),
      );

  @override
  bool get shouldScrollToCurrentTime => super.shouldScrollToCurrentTime && Utils.overlapsDate(widget.date);
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
class _EventsGrid {
  /// The draw properties to handle.
  List<_EventDrawProperties> drawPropertiesList = [];

  /// A map containing all pairs (hour, hour draw properties).
  HashMap<int, List<_EventDrawProperties>> hourDrawProperties = HashMap();

  /// Columns count.
  int columnsCount = 1;

  /// Adds a flutter week view event draw properties.
  void add(_EventDrawProperties drawProperties) {
    drawPropertiesList.add(drawProperties);
    for (int hour in drawProperties.hours) {
      List<_EventDrawProperties> events = (hourDrawProperties[hour] ?? [])..add(drawProperties);
      hourDrawProperties[hour] = events;
      columnsCount = math.max(columnsCount, events.length);
    }
  }

  /// Returns whether there is enough space for the specified draw properties at the specified left offset.
  bool hasRoom(_EventDrawProperties drawProperties, double left) {
    for (int hour in drawProperties.hours) {
      for (_EventDrawProperties drawProperties in hourDrawProperties[hour]) {
        if (drawProperties.left == left) {
          return false;
        }
      }
    }
    return true;
  }

  /// Calculates the minimum left and width for the specified draw properties.
  void calculateMinLeftAndWidth(_EventDrawProperties drawProperties, double hoursColumnWidth, double eventsColumnWidth) {
    double eventWidth = eventsColumnWidth / columnsCount;
    for (int column = 0; column < columnsCount; column++) {
      drawProperties.width = eventWidth;
      double left = hoursColumnWidth + column * eventWidth;
      if (hasRoom(drawProperties, left)) {
        drawProperties.left = left;
        break;
      }
    }
  }

  /// Processes all display properties added to the grid.
  void processEvents(double hoursColumnWidth, double eventsColumnWidth) => drawPropertiesList.forEach((drawProperties) => calculateMinLeftAndWidth(drawProperties, hoursColumnWidth, eventsColumnWidth));
}

/// An utility class that allows to display the events in the events column.
class _EventDrawProperties {
  /// Hours covered by the event.
  List<int> hours;

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
    if (shouldDraw || (!Utils.overlapsDate(event.start, dayView.date) && !Utils.overlapsDate(event.end, dayView.date))) {
      return;
    }

    start = event.start;
    end = event.end;

    DateTime tomorrow = dayView.date.add(const Duration(days: 1));

    if (start.isBefore(dayView.date)) {
      start = dayView.date;
    }

    if (end.isAfter(tomorrow)) {
      end = tomorrow;
    }

    DateTime hour = start.subtract(Duration(minutes: start.minute));
    DateTime max = end.add(Duration(hours: end.minute == 0 ? 0 : 1)).subtract(Duration(minutes: end.minute));
    hours = [];
    while (hour.isBefore(max)) {
      hours.add(hour.hour);
      hour = hour.add(const Duration(hours: 1));
    }
  }

  /// Whether this event should be drawn.
  bool get shouldDraw => hours != null && hours.isNotEmpty;

  /// Calculates the top and the height of the event rectangle.
  void calculateTopAndHeight(_DayViewState state) {
    top = state.calculateTopOffset(start.hour, start.minute);
    height = state.calculateTopOffset(0, end.difference(start).inMinutes) + 1;
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
