/// Script to generate a simple LUXE app icon PNG using Dart.
/// Run with: dart run tool/generate_icon.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

void main() async {
  // This uses a simple PNG approach via dart:ui
  // We'll create a 1024x1024 image with an orange shopping bag icon
  
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 1024, 1024));
  
  // Background: white
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 1024, 1024),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  
  // Orange circle
  canvas.drawCircle(
    const ui.Offset(512, 512),
    400,
    ui.Paint()..color = const ui.Color(0xFFFF5722),
  );
  
  // Shopping bag shape (simplified as white filled path)
  final bagPaint = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.fill;
  
  final path = ui.Path();
  // Bag body
  path.addRRect(ui.RRect.fromRectAndRadius(
    const ui.Rect.fromLTWH(280, 440, 464, 380),
    const ui.Radius.circular(40),
  ));
  canvas.drawPath(path, bagPaint);
  
  // Bag handle (arc)
  final handlePaint = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 44
    ..strokeCap = ui.StrokeCap.round;
  
  final handlePath = ui.Path();
  handlePath.moveTo(362, 440);
  handlePath.cubicTo(362, 300, 662, 300, 662, 440);
  canvas.drawPath(handlePath, handlePaint);
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  
  final file = File('assets/images/app_icon.png');
  await file.writeAsBytes(bytes);
  print('App icon generated: assets/images/app_icon.png');
}
