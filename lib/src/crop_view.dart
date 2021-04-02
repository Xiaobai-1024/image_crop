import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'crop_controller.dart';
import 'crop_indicator.dart';

class CropView extends GetView<CropController> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          maxScale: max(1, controller.scale),
          minScale: controller.scale,
          constrained: false,
          transformationController: controller.viewCtrl,
          boundaryMargin: EdgeInsets.all(double.infinity),
          onInteractionStart: controller.onInteractionStart,
          onInteractionEnd: controller.onInteractionEnd,
          child: Image(
            image: controller.image.item1,
            width: controller.image.item2.width,
            height: controller.image.item2.height,
            fit: BoxFit.fill,
          ),
        ),
        Positioned.fromRect(
          rect: controller.rect,
          child: IgnorePointer(child: CropIndicator()),
        ),
      ],
    );
  }
}
