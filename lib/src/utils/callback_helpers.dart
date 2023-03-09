/// Takes a [dateTime] and rounds it to the closest time in an imaginary grid. The granularity of
/// this grid is defined by [gridGranularity], which defaults to 30 minutes (that is, times will be
/// rounded to 16:00, or 16:30, or 17:00, and so on).
///
/// For example, if the method receives 16:32 as input, it will return 16:30 as the rounded time.
DateTime roundTimeToFitGrid(DateTime dateTime, {Duration gridGranularity = const Duration(minutes: 30)}) {
  int microseconds = (dateTime.microsecondsSinceEpoch / gridGranularity.inMicroseconds).round() * gridGranularity.inMicroseconds;
  return DateTime.fromMicrosecondsSinceEpoch(microseconds);
}
