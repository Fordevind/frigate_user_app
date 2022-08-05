import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';

final Duration colorAnimationDuration = const Duration(milliseconds: 300);
final Duration checkboxAnimationDuration = const Duration(milliseconds: 100);

class DeviceListTile extends StatefulWidget {
  /// Creates a ListTile which represents [device]
  ///
  /// Requires one of its ancestors to be a [Material] widget.
  const DeviceListTile(
    this.device, {
      Key key,
      this.onLongPress,
      this.onTap,
      this.showMore,
      this.leading,
      this.checkboxMode = false,
      this.isSelected = false
    }) : super(key: key);

  final Device device;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback showMore;
  final bool checkboxMode;
  final bool isSelected;
  final Widget leading;
  @override
  _DeviceListTileState createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<DeviceListTile> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;
  bool showCheckbox = false;

  @override
  void initState() {
    animationController = new AnimationController(
      vsync: this,
      duration: checkboxAnimationDuration
    );

    animation = new Tween(begin: 0.0, end: 0.02).animate(
      new CurvedAnimation(
        parent: animationController,
        curve: Curves.fastOutSlowIn,
      )
    )..addStatusListener(animationHandler);
    super.initState();
  }

  void animationHandler(AnimationStatus status) async {

  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    if (widget.checkboxMode) {
      animationController.forward();
      showCheckbox = true;
    }
    else  {
      animationController.animateBack(0.0);
      showCheckbox = false;
    }

    return new AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return new Transform(
          transform: new Matrix4.translationValues(animation.value * width, 0.0, 0.0),
          child: new AnimatedContainer(
            duration: colorAnimationDuration,
            decoration: new BoxDecoration(
              color: widget.isSelected? colorSelected : null
            ),
            child: widget.device.devClass == classPPKOP? _ppkop(widget.device) : _zone(widget.device)
          )
        );
      },
    );
  }

  Widget _ppkop(Device ppkop) {
    return new ListTile(
      leading: widget.leading,
      title: new Text(ppkop.name),
      subtitle: new Text(ppkop.stamp, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: new GestureDetector(
        child: const Icon(Icons.more_vert),
        onTap: widget.showMore,
      ),
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
    );
  }

  Widget _zone(Device zone) {
    return new ListTile(
      leading: widget.leading,
      title: new Text(zone.name, style: widget.isSelected? new TextStyle(fontWeight: FontWeight.bold) : null),
      subtitle: new Text(zone.stamp, maxLines: 1, overflow: TextOverflow.ellipsis),
      contentPadding: new EdgeInsets.fromLTRB(32.0, 0, 0, 0),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
    );
  }

  Widget buildLeading(Device device) {
    if (device.devClass == classPPKOP) {
      if (showCheckbox)
        return new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Checkbox(value: widget.isSelected, onChanged: (bool value) {},),
            ppkopIcon(device.style)
          ],
        );
      else
        return ppkopIcon(device.style);
    }
    else {
      if (showCheckbox)
        return new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Checkbox(value: widget.isSelected, onChanged: (bool value) {},),
            zoneIcon(device.style)
          ],
        );
      else
        return zoneIcon(device.style);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}