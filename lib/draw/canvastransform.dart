import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:geo_draw/core/geometry_data/circle.dart';
import 'package:geo_draw/core/geometry_data/dot.dart';
import 'package:geo_draw/core/geometry_data/geometryset.dart';
import 'package:geo_draw/core/prop/point.dart';
import 'package:geo_draw/ui/constants.dart';

class CanvasTransform extends ChangeNotifier {
  double width = 0;
  double height = 0;
  double xmin = 0;
  double ymin = 0;
  double xmax = 0;
  double ymax = 0;

  double dx = 0;
  double dy = 0;
  double scale = 1.0;

  bool fitDone = false;
  void fit(GeometrySet set, Size canvasSize) {
    if (fitDone) {
      return;
    }

    xmin = double.infinity;
    xmax = double.negativeInfinity;
    ymin = double.infinity;
    ymax = double.negativeInfinity;

    for (var object in set.objects) {
      if (object is Dot) {
        xmin = min(object.point.x, xmin);
        xmax = max(object.point.x, xmax);
        ymin = min(-object.point.y, ymin);
        ymax = max(-object.point.y, ymax);
      }

      else if (object is Circle) {
        xmin = min(object.center.x - object.radius, xmin);
        xmax = max(object.center.x + object.radius, xmax);
        ymin = min(-object.center.y - object.radius, ymin);
        ymax = max(-object.center.y + object.radius, ymax);
      }
    }

    if (xmin == double.infinity) {
      xmin = 0;
      ymin = 0;
      xmax = 0;
      ymax = 0;

      dx = canvasSize.width / 2;
      dy = canvasSize.height / 2;
      scale = defaultScale(canvasSize);
    }
    else {
      width = xmax - xmin;
      height = ymax - ymin;

      double margin = UiConstants.canvasDefaultPadding;
      double canvasWidth = canvasSize.width * (1 - margin * 2);
      double canvasHeight = canvasSize.height * (1 - margin * 2);

      if (width == 0 && height == 0) {
        scale = defaultScale(canvasSize);
        dx = canvasWidth / 2;
        dy = canvasHeight / 2;
      }

      else if (height == 0) {
        scale = canvasWidth / width;
        dx = 0;
        dy = canvasHeight / 2;
      }

      else if (width == 0) {
        scale = canvasHeight / height;
        dx = canvasWidth / 2;
        dy = 0;
      }

      else {
        double ratio = width / height;
        double canvasRatio = canvasWidth / canvasHeight;
        if (ratio > canvasRatio) {
          scale = canvasWidth / width;
          dx = 0;
          dy = (canvasHeight - height * scale) / 2;
        } else {
          scale = canvasHeight / height;
          dx = (canvasWidth - width * scale) / 2;
          dy = 0;
        }
      }

      dx += canvasSize.width * margin;
      dy += canvasSize.height * margin;
    }

    fitDone = true;
  }

  void setScale(double scale) {
    dx += width * (this.scale - scale) / 2;
    dy += height * (this.scale - scale) / 2;
    this.scale = scale;
  }

  void requestFit() {
    fitDone = false;
  }

  Offset transform(Point point) {
    return Offset((point.x - xmin) * scale + dx, (-point.y - ymin) * scale + dy);
  }

  double transformDistance(double distance) {
    return distance * scale;
  }

  Point untransform(Offset offset) {
    return Point((offset.dx - dx) / scale + xmin, -(offset.dy - dy) / scale - ymin);
  }

  double untransformDistance(double distance) {
    return distance / scale;
  }

  double defaultScale(Size canvasSize) =>
    max(canvasSize.width, canvasSize.height) / 10;
}

class AnimatedCanvasTransform extends CanvasTransform {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  double _baseScale = 1.0;
  double _baseX = 0;
  double _baseY = 0;

  bool _shouldAnimateFit = false;

  AnimatedCanvasTransform(SingleTickerProviderStateMixin vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  VoidCallback? _activeListener;
  void animateZoomIn() {
    if (_activeListener != null) {
      _controller.forward(from: 1.0);
      _animation.removeListener(_activeListener!);
      _controller.reset();
    }

    _baseScale = scale;
    zoomInListener() {
      setScale(_baseScale * lerpDouble(1, 1.2, _animation.value)!);
      notifyListeners();
    }

    _animation.addListener(zoomInListener);
    _activeListener = zoomInListener;
    _controller.forward();
  }

  void animateZoomOut() {
    if (_activeListener != null) {
      _controller.forward(from: 1.0);
      _animation.removeListener(_activeListener!);
      _controller.reset();
    }

    _baseScale = scale;
    zoomOutListener() {
      setScale(_baseScale * lerpDouble(1, 0.8, _animation.value)!);
      notifyListeners();
    }

    _animation.addListener(zoomOutListener);
    _activeListener = zoomOutListener;
    _controller.forward();
  }

  @override
  void fit(GeometrySet set, Size canvasSize) {
    super.fit(set, canvasSize);

    if (_shouldAnimateFit) {
      _shouldAnimateFit = false;

      double newScale = scale;
      double newX = dx;
      double newY = dy;

      scale = _baseScale;
      dx = _baseX;
      dy = _baseY;

      if (_activeListener != null) {
        _animation.removeListener(_activeListener!);
        _controller.reset();
      }

      fitListener() {
        dx = lerpDouble(_baseX, newX, _animation.value)!;
        dy = lerpDouble(_baseY, newY, _animation.value)!;
        scale = lerpDouble(_baseScale, newScale, _animation.value)!;
        notifyListeners();
      }

      _animation.addListener(fitListener);
      _activeListener = fitListener;
      _controller.forward();
    }
  }

  void animateFit() {
    _baseScale = scale;
    _baseX = dx;
    _baseY = dy;

    _shouldAnimateFit = true;

    requestFit();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}