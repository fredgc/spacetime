import 'package:flutter/material.dart';

import 'scene_view.dart';

class ScenePainter extends CustomPainter {
  SceneView sceneViewer;
  ScenePainter({required this.sceneViewer, super.repaint});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    bool should = (this != oldDelegate);
    return should;
  }

  @override
  void paint(Canvas canvas, Size size) {
    sceneViewer.paint(canvas, size);
  }
}

class SideViewPainter extends CustomPainter {
  SceneView sceneViewer;
  SideViewPainter({required this.sceneViewer, super.repaint});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    bool should = (this != oldDelegate);
    return should;
  }

  @override
  void paint(Canvas canvas, Size size) {
    sceneViewer.paintSideView(canvas, size);
  }
}
