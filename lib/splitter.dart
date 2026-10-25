import 'package:flutter/material.dart';
import 'printer.dart';

class SplitterWidget extends StatefulWidget {
  final Widget Function(BuildContext) top;
  final Widget Function(BuildContext) bottom;
  final void Function(double) setter;
  final double initialSize;
  final Color background;
  final Color outline;

  const SplitterWidget({
    required this.top,
    required this.bottom,
    required this.setter,
    required this.initialSize,
    this.background = Colors.black,
    this.outline = Colors.green,
    super.key,
  });

  @override
  State<SplitterWidget> createState() => SplitterWidgetState();
}

class SplitterWidgetState extends State<SplitterWidget> {
  static const double _minimumSize = 5;
  late double _bottomSize;

  @override
  void initState() {
    super.initState();
    _bottomSize = widget.initialSize;
  }

  BoxDecoration decoration() {
    return BoxDecoration(
      color: widget.background,
      border: Border.all(width: 2.0, color: widget.outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = 20;
    Widget icon = CircleAvatar(
      radius: iconSize / 2.0,
      backgroundColor: widget.outline,
      child: Icon(Icons.drag_handle, color: widget.background, size: iconSize),
    );
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: decoration(),
                child: ClipRect(child: widget.top(context)),
              ),
            ),
            Container(
              constraints: BoxConstraints(minHeight: _bottomSize),
              decoration: decoration(),
              child: ClipRect(child: widget.bottom(context)),
            ),
          ],
        ),
        Positioned(
          right: 3,
          bottom: _bottomSize - iconSize / 2.0,
          child: GestureDetector(
            child: icon,
            onScaleStart: (info) {
              Log.mouseScale.log("ICON. scale start in both view.");
            },
            onScaleUpdate: (info) {
              if (context.size != null) {
                setState(() {
                  _bottomSize -= info.focalPointDelta.dy;
                  double maximumSize = context.size!.height - 2 * _minimumSize;
                  _bottomSize = _bottomSize.clamp(_minimumSize, maximumSize);
                  widget.setter(_bottomSize);
                  Log.mouseScale.log("bottom_size = ${zzz(_bottomSize)}");
                });
              }
            },
            onScaleEnd: (info) {
              Log.mouseScale.log(
                "ICON -- end bottom_size = ${zzz(_bottomSize)}",
              );
            },
          ),
        ),
      ],
    );
  }
}
