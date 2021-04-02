import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

final _pixelRatio = window.devicePixelRatio;

class CropController extends GetxController with SingleGetTickerProviderMixin {
  final Size viewSize;
  final double aspectRatio;
  final Tuple2<ImageProvider, Size> image;

  CropController({required this.viewSize, required this.image, this.aspectRatio = 1});

  late final Rect rect;
  late final Rect imgRect;
  late final double scale;

  late final AnimationController _animCtrl;
  late final TransformationController viewCtrl;

  Animation? _animation;

  final _lockRx = true.obs;
  final _holdRx = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _animCtrl = AnimationController(
      vsync: this,
      duration: kThemeChangeDuration,
    );

    final padding = 16.0;

    final width = viewSize.width - (padding * 2);
    final height = width / (16 / 9);

    rect = Alignment.center.inscribe(
      Size(width, height),
      Offset.zero & viewSize,
    );

    imgRect = Offset.zero & (image.item2 / _pixelRatio);

    if (imgRect.width / width > imgRect.height / height) {
      scale = rect.height / imgRect.height;

      viewCtrl = TransformationController(
        Matrix4.identity()
          ..scale(scale)
          ..leftTranslate((viewSize.width - imgRect.width * scale) / 2, rect.top),
      );
    } else {
      scale = rect.width / imgRect.width;

      viewCtrl = TransformationController(
        Matrix4.identity()
          ..scale(scale)
          ..leftTranslate(rect.left, (viewSize.height - imgRect.height * scale) / 2),
      );
    }

    debounce(
      _holdRx,
      (_) {
        if (_lockRx.isFalse) return;

        final old = viewCtrl.value;

        final _scale = old.storage[0];
        final _position = old.getTranslation();

        final _imgRect = Offset(_position.x, _position.y) & (imgRect.size * _scale);

        final top = _imgRect.top - rect.top;
        final left = _imgRect.left - rect.left;
        final right = _imgRect.right - rect.right;
        final bottom = _imgRect.bottom - rect.bottom;

        double? x, y;

        if (left > 0) {
          x = left;
        } else if (right < 0) {
          x = right;
        }

        if (top > 0) {
          y = top;
        } else if (bottom < 0) {
          y = bottom;
        }

        if (x == null && y == null) return;

        final end = //
            old.clone() //
              ..leftTranslate(-(x ?? 0.0), -(y ?? 0.0));

        _animateTo(end);
      },
      time: Duration(milliseconds: 50),
    );

    viewCtrl.addListener(_onChange);
  }

  @override
  void onClose() {
    viewCtrl.removeListener(_onChange);
    _animCtrl.dispose();

    super.onClose();
  }

  void _onChange() => _holdRx(DateTime.now());

  void _onAnimate() {
    viewCtrl.value = _animation!.value;

    if (!_animCtrl.isAnimating) {
      _animation!.removeListener(_onAnimate);
      _animation = null;

      _animCtrl.reset();
    }
  }

  void _animateStop() {
    _animCtrl.stop();

    _animation?.removeListener(_onAnimate);
    _animation = null;

    _animCtrl.reset();
  }

  TickerFuture _animateTo(Matrix4 end) {
    _animCtrl.reset();

    _animation = //
        Matrix4Tween(begin: viewCtrl.value, end: end) //
            .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.fastLinearToSlowEaseIn))
              ..addListener(_onAnimate);

    return _animCtrl.forward();
  }

  void onInteractionStart(_) {
    _lockRx(true);

    if (_animCtrl.status == AnimationStatus.forward) {
      _animateStop();
    }
  }
  void onInteractionEnd(_) => _lockRx(false);

  void crop() {}
}
