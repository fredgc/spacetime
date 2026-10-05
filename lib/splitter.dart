import 'package:flutter/material.dart';
import 'printer.dart';

class SplitterWidget extends StatefulWidget {
  final Widget Function(BuildContext) top;
  final Widget Function(BuildContext) bottom;
  final void Function(double) setter;
  final double initial_size;
  final Color background;
  final Color outline;

  const SplitterWidget({
    required this.top,
    required this.bottom,
    required this.setter,
    required this.initial_size,
    this.background = Colors.black,
    this.outline = Colors.green,
    super.key,
  });

  @override
  State<SplitterWidget> createState() => SplitterWidgetState(initial_size);
}

class SplitterWidgetState extends State<SplitterWidget> {
  final double minimum_size = 5;
  double bottom_size;
  SplitterWidgetState(this.bottom_size);

  @override
  void initState() {
    super.initState();
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
              constraints: BoxConstraints(minHeight: bottom_size),
              decoration: decoration(),
              child: ClipRect(child: widget.bottom(context)),
            ),
          ],
        ),
        Positioned(
          right: 3,
          bottom: bottom_size - iconSize / 2.0,
          child: GestureDetector(
            child: icon,
            onScaleStart: (info) {
              Log.mouse_scale.log("ICON. scale start in both view.");
            },
            onScaleUpdate: (info) {
              if (context.size != null) {
                setState(() {
                  bottom_size -= info.focalPointDelta.dy;
                  double maximumSize = context.size!.height - 2 * minimum_size;
                  bottom_size = bottom_size.clamp(minimum_size, maximumSize);
                  widget.setter(bottom_size);
                  Log.mouse_scale.log("bottom_size = ${zzz(bottom_size)}");
                });
              }
            },
            onScaleEnd: (info) {
              Log.mouse_scale.log(
                "ICON -- end bottom_size = ${zzz(bottom_size)}",
              );
            },
          ),
        ),
      ],
    );
  }
}
