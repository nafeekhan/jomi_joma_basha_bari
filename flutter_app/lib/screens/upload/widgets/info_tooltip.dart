import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../../config/app_theme.dart';

/// Info Tooltip Widget
/// Displays helpful hints and tooltips for form fields
class InfoTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final TooltipDirection direction;

  const InfoTooltip({
    Key? key,
    required this.child,
    required this.message,
    this.direction = TooltipDirection.down,
  }) : super(key: key);

  @override
  State<InfoTooltip> createState() => _InfoTooltipState();
}

class _InfoTooltipState extends State<InfoTooltip> {
  final _controller = SuperTooltipController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 0,
          top: 0,
          child: SuperTooltip(
            controller: _controller,
            popupDirection: widget.direction,
            backgroundColor: AppTheme.primaryColor,
            arrowTipDistance: 15.0,
            arrowBaseWidth: 15.0,
            arrowLength: 15.0,
            borderColor: AppTheme.primaryColor,
            borderWidth: 2.0,
            hasShadow: true,
            shadowColor: Colors.black26,
            content: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 250),
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  softWrap: true,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                _controller.showTooltip();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.help_outline,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

