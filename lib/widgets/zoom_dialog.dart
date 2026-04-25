import 'package:flutter/material.dart';

class ZoomDialog extends StatefulWidget {
  final String imagePath;
  const ZoomDialog({super.key, required this.imagePath});

  @override
  State<ZoomDialog> createState() => _ZoomDialogState();
}

class _ZoomDialogState extends State<ZoomDialog> {
  final TransformationController _controller = TransformationController();
  double _currentScale = 1.0;

  void _updateZoom(double step) {
    setState(() {
      _currentScale = (_currentScale + step).clamp(1.0, 5.0);
      _controller.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Top Bar with Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.white10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Image Preview", style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out, color: Colors.white),
                      onPressed: () => _updateZoom(-0.5),
                      tooltip: 'Zoom Out',
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in, color: Colors.white),
                      onPressed: () => _updateZoom(0.5),
                      tooltip: 'Zoom In',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 2. The Interactive Image Area with "Pan Hand" cursor
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: InteractiveViewer(
                  transformationController: _controller,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: Hero(
                    tag: widget.imagePath, // Hero tag for smooth transition
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Scroll to zoom • Drag to pan",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
