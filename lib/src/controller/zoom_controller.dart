import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An abstract zoom controller.
abstract class ZoomController {
  /// The zoom coefficient (<= 0 to disable).
  final double zoomCoefficient;

  /// The minimum zoom factor.
  final double minZoom;

  /// The maximum zoom factor.
  final double maxZoom;

  /// All controller listeners.
  final Set<ZoomControllerListener> _listeners = HashSet();

  /// The previous zoom factor.
  @protected
  double previousZoomFactor = 1;

  /// The current zoom factor.
  double _zoomFactor = 1;

  /// For maintain the position of the pinch focal point position (vertical)
  double contentOffset = 0.0;

  /// Creates a zoom controller instance.
  ZoomController({
    double zoomCoefficient = 0.8,
    double? minZoom,
    double? maxZoom,
  })  : zoomCoefficient = math.max(0, zoomCoefficient),
        minZoom = math.max(0, minZoom ?? 0.4),
        maxZoom = math.max(0, maxZoom ?? 1.6) {
    assert(this.minZoom <= this.maxZoom);
  }

  /// Adds a listener.
  void addListener(ZoomControllerListener listener) => _listeners.add(listener);

  /// Removes a listener.
  void removeListener(ZoomControllerListener listener) =>
      _listeners.remove(listener);

  /// Calculates a zoom factor according to the specified scale.
  double calculateZoomFactor(double scale) {
    double zoomFactor = previousZoomFactor * scale * zoomCoefficient;
    if (zoomFactor < minZoom) {
      zoomFactor = minZoom;
    }

    if (zoomFactor > maxZoom) {
      zoomFactor = maxZoom;
    }

    return zoomFactor;
  }

  /// Should be called when the scale operation start.
  void scaleStart(ScaleStartDetails details) {
    previousZoomFactor = zoomFactor;

    for (ZoomControllerListener listener in _listeners) {
      listener.onZoomStart(this, details);
    }
  }

  /// Should be called when the scale operation has an update.
  void scaleUpdate(ScaleUpdateDetails details) =>
      changeZoomFactor(calculateZoomFactor(details.scale), details: details);

  /// Returns the current scale.
  double get scale => zoomFactor / (previousZoomFactor * zoomCoefficient);

  /// Returns the current zoom factor.
  double get zoomFactor => _zoomFactor;

  /// Changes the current zoom factor.
  @protected
  set zoomFactor(double zoomFactor) => _zoomFactor = zoomFactor;

  /// Changes the current zoom factor.
  void changeZoomFactor(double zoomFactor,
      {bool notify = true, ScaleUpdateDetails? details}) {
    bool hasChanged = this.zoomFactor != zoomFactor;
    if (hasChanged) {
      _zoomFactor = zoomFactor;
      if (notify) {
        details ??= ScaleUpdateDetails(scale: scale);
        for (ZoomControllerListener listener in _listeners) {
          listener.onZoomFactorChanged(this, details);
        }
      }
    }
  }

  /// Disposes this controller if enabled.
  /// You should not use it anymore after having called this method.
  void dispose() {
    _listeners.clear();
  }
}

/// A day view controller listener.
mixin ZoomControllerListener {
  /// Triggered when the day view zoom start
  void onZoomStart(
      covariant ZoomController controller, ScaleStartDetails details);

  /// Triggered when the day view zoom factor has changed.
  void onZoomFactorChanged(
      covariant ZoomController controller, ScaleUpdateDetails details);
}
