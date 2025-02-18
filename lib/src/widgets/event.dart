import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/event.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/builders.dart';
import 'package:flutter_week_view/src/utils/utils.dart';

/// Allows to draw a week view event.
class FlutterWeekViewEventWidget<E extends FlutterWeekViewEventMixin> extends StatelessWidget {
  /// The flutter week view event.
  final E event;

  /// The time formatter.
  final TimeFormatter? timeFormatter;

  /// The event widget background color.
  final Color? backgroundColor;

  /// The event text widget text style.
  final TextStyle? textStyle;

  /// The event widget padding.
  final EdgeInsets? padding;

  /// The event widget margin.
  final EdgeInsets? margin;

  /// The event text builder.
  final EventTextBuilder<E>? textBuilder;

  /// The widget height.
  final double? height;

  /// The widget width.
  final double? width;

  /// Creates a new Flutter week view event widget instance.
  const FlutterWeekViewEventWidget({
    super.key,
    required this.event,
    this.timeFormatter,
    this.backgroundColor = const Color(0xCC2196F3),
    this.textStyle = const TextStyle(color: Colors.white),
    this.padding = const EdgeInsets.all(10),
    this.margin,
    this.textBuilder,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    double? height;
    if (this.height != null) {
      height = this.height! - (padding?.top ?? 0.0) - (padding?.bottom ?? 0.0);
    }
    double? width;
    if (this.height != null) {
      width = this.width! - (padding?.left ?? 0.0) - (padding?.right ?? 0.0);
    }

    TextStyle textStyle = this.textStyle ?? Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white);
    return DefaultTextStyle(
      style: textStyle,
      child: Container(
        height: math.max(0, height ?? 0),
        width: math.max(0, width ?? 0),
        color: backgroundColor,
        margin: margin,
        padding: padding,
        child: (textBuilder ?? defaultEventTextBuilder)(
          event,
          timeFormatter ?? DefaultBuilders.defaultTimeFormatter,
          textStyle,
          math.max(0.0, height ?? double.infinity),
          math.max(0.0, width ?? double.infinity),
        ),
      ),
    );
  }

  /// Builds an event text widget in order to put it in an event widget.
  static Widget defaultEventTextBuilder<E extends FlutterWeekViewEventMixin>(
    E event,
    TimeFormatter timeFormatter,
    TextStyle textStyle,
    double height,
    double width,
  ) {
    List<TextSpan> text = [
      TextSpan(
        text: event.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: ' ${timeFormatter(TimeOfDay.fromDateTime(event.start))} - ${timeFormatter(TimeOfDay.fromDateTime(event.end))}\n\n',
      ),
      TextSpan(
        text: event.description,
      ),
    ];

    bool? exceedHeight;
    while (exceedHeight ?? true) {
      exceedHeight = _exceedHeight(text, textStyle, height, width);
      if (exceedHeight == null || !exceedHeight) {
        if (exceedHeight == null) {
          text.clear();
        }
        break;
      }

      if (!_ellipsize(text)) {
        break;
      }
    }

    return RichText(
      text: TextSpan(
        children: text,
        style: textStyle,
      ),
    );
  }

  /// Returns whether this input exceeds the specified height.
  static bool? _exceedHeight(
    List<TextSpan> input,
    TextStyle? textStyle,
    double height,
    double width,
  ) {
    double fontSize = textStyle?.fontSize ?? 14;
    int maxLines = height ~/ ((textStyle?.height ?? 1.2) * fontSize);
    if (maxLines == 0) {
      return null;
    }

    TextPainter painter = TextPainter(
      text: TextSpan(
        children: input,
        style: textStyle,
      ),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    return painter.didExceedMaxLines;
  }

  /// Ellipsizes the input.
  static bool _ellipsize(List<TextSpan> input, [String ellipse = '…']) {
    if (input.isEmpty) {
      return false;
    }

    TextSpan last = input.last;
    String? text = last.text;
    if (text == null || text.isEmpty || text == ellipse) {
      input.removeLast();

      if (text == ellipse) {
        _ellipsize(input, ellipse);
      }
      return true;
    }

    String truncatedText;
    if (text.endsWith('\n')) {
      truncatedText = text.substring(0, text.length - 1) + ellipse;
    } else {
      truncatedText = Utils.removeLastWord(text);
      truncatedText = truncatedText.substring(0, math.max(0, truncatedText.length - 2)) + ellipse;
    }

    input[input.length - 1] = TextSpan(
      text: truncatedText,
      style: last.style,
    );

    return true;
  }
}
