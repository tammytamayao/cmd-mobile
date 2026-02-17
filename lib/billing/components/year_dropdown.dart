import 'dart:math' as math;
import 'package:flutter/material.dart';

class YearDropdown extends StatefulWidget {
  const YearDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChange,
  });

  final int value;
  final List<int> options;
  final ValueChanged<int> onChange;

  @override
  State<YearDropdown> createState() => _YearDropdownState();
}

class _YearDropdownState extends State<YearDropdown> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();

  OverlayEntry? _overlay;
  bool open = false;

  void _toggle() => open ? _close() : _open();

  void _open() {
    _overlay = _createOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => open = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    setState(() => open = false);
  }

  OverlayEntry _createOverlay() {
    final renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonSize = renderBox.size;
    final buttonOffset = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    const rowH = 40.0;
    const maxMenuH = 260.0;
    const menuW = 110.0;

    final desiredH = (widget.options.length * rowH) + 12;
    final menuH = math.min(desiredH, maxMenuH);

    final spaceBelow =
        screenHeight - (buttonOffset.dy + buttonSize.height) - 12;
    final spaceAbove = (buttonOffset.dy - topPadding) - 12;
    final openUp = spaceBelow < menuH && spaceAbove > spaceBelow;

    final yOffset = openUp ? -(menuH + 4) : 4.0; // ✅ just a small gap

    // Keep menu inside screen horizontally (right-aligned to button)
    final rightEdge = buttonOffset.dx + buttonSize.width;
    final overflowRight = rightEdge - screenWidth;
    final xNudge = overflowRight > 0 ? -overflowRight - 8 : 0.0;

    return OverlayEntry(
      builder: (_) => Stack(
        children: [
          // tap outside to close
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
              child: const SizedBox.expand(),
            ),
          ),

          // ✅ IMPORTANT: no Positioned wrapper here
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: Offset(xNudge, yOffset),
            showWhenUnlinked: false,
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: menuW,
                  maxWidth: menuW,
                  maxHeight: maxMenuH,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      children: widget.options.map((y) {
                        final active = y == widget.value;
                        return InkWell(
                          onTap: () {
                            widget.onChange(y);
                            _close();
                          },
                          child: Container(
                            height: rowH,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.centerLeft,
                            color: active
                                ? const Color(0xFFEFF6FF) // blue-50
                                : Colors.transparent,
                            child: Text(
                              "$y",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _buttonKey,
        onTap: _toggle,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${widget.value}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
