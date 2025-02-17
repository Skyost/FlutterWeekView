import 'package:flutter_week_view/src/controller/zoom_controller.dart';

/// Allows to control some parameters of a day view.
class DayViewController extends ZoomController {
  /// Called when this controller has been disposed.
  final Function(DayViewController controller)? onDisposed;

  /// Creates a new day view controller instance.
  DayViewController({
    super.zoomCoefficient,
    super.minZoom,
    super.maxZoom,
    this.onDisposed,
  });

  @override
  void dispose() {
    super.dispose();
    if (onDisposed != null) {
      onDisposed!(this);
    }
  }
}
