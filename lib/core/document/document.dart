import 'page_format.dart';
import 'page_orientation.dart';

class StampifyDocument {
  final PageFormat pageFormat;
  final PageOrientation orientation;

  const StampifyDocument({
    required this.pageFormat,
    this.orientation = PageOrientation.portrait,
  });

  double get widthMm {
    return orientation == PageOrientation.portrait
        ? pageFormat.widthMm
        : pageFormat.heightMm;
  }

  double get heightMm {
    return orientation == PageOrientation.portrait
        ? pageFormat.heightMm
        : pageFormat.widthMm;
  }
}