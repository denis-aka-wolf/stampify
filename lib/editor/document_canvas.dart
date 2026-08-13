import 'package:flutter/material.dart';

import '../core/document/document.dart';

class DocumentCanvas extends StatelessWidget {
  final StampifyDocument document;

  const DocumentCanvas({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 40.0;

        final availableWidth = constraints.maxWidth - padding * 2;
        final availableHeight = constraints.maxHeight - padding * 2;

        final scaleX = availableWidth / document.widthMm;
        final scaleY = availableHeight / document.heightMm;

        final scale = scaleX < scaleY ? scaleX : scaleY;

        final width = document.widthMm * scale;
        final height = document.heightMm * scale;

        return Center(
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}