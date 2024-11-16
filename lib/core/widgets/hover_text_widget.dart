import 'package:flutter/widgets.dart';


class HoverTextWidget extends StatefulWidget {
  final Widget visibleChild;
  final Widget hoverChild;

  const HoverTextWidget({super.key, required this.visibleChild, required this.hoverChild});

  @override
  HoverTextWidgetState createState() => HoverTextWidgetState();
}


class HoverTextWidgetState extends State<HoverTextWidget> {
  bool _isHovered = false;
  

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: _isHovered ? widget.hoverChild : widget.visibleChild,
    );
  }

  void _onEnter(_) {
    setState(() => _isHovered = true);
  }

  void _onExit(_) {
    setState(() => _isHovered = false);
  }
}
