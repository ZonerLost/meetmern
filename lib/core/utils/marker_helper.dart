import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';

class MarkerHelper {
  MarkerHelper._();

  static const double _w = 152.0;
  static const double _cardH = 54.0;
  static const double _arrowH = 11.0;
  static const double _totalH = _cardH + _arrowH;
  static const double _av = 36.0;
  static const double _pad = 9.0;
  static const double _cornerR = 11.0;
  static const double _px = 3.0;

  /// Colour + glyph for a venue amenity (cafe / restaurant / bar / pub).
  static Color venueColor(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'cafe':
        return const Color(0xFF6D4C41); // brown
      case 'restaurant':
        return const Color(0xFFBF360C); // deep orange
      case 'bar':
        return const Color(0xFF3949AB); // indigo
      case 'pub':
        return const Color(0xFFEF6C00); // amber
      default:
        return const Color(0xFF6200EE);
    }
  }

  static IconData venueIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'bar':
        return Icons.local_bar;
      case 'pub':
        return Icons.sports_bar;
      default:
        return Icons.place;
    }
  }

  /// Small circular venue chip for the map. When [selected] it grows and gains
  /// a pin tail so it reads as "pinned here".
  static Future<BitmapDescriptor> buildVenueMarker({
    required String amenity,
    required bool selected,
  }) async {
    final color = venueColor(amenity);
    final icon = venueIcon(amenity);

    final double size = selected ? 42.0 : 30.0;
    final double tail = selected ? 11.0 : 0.0;
    final double w = size * _px;
    final double h = (size + tail) * _px;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = Offset(w / 2, size * _px / 2);
    final radius = size * _px / 2 - 2 * _px;

    // Drop shadow
    canvas.drawCircle(
      center.translate(0, 1.5 * _px),
      radius,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
    );

    if (selected) {
      final tailPath = Path()
        ..moveTo(w / 2 - 6 * _px, size * _px - 4 * _px)
        ..lineTo(w / 2, h)
        ..lineTo(w / 2 + 6 * _px, size * _px - 4 * _px)
        ..close();
      canvas.drawPath(tailPath, Paint()..color = color);
      canvas.drawCircle(center, radius, Paint()..color = color);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * _px,
      );
      _drawIconGlyph(canvas, icon, center, 20 * _px, Colors.white);
    } else {
      canvas.drawCircle(center, radius, Paint()..color = Colors.white);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * _px,
      );
      _drawIconGlyph(canvas, icon, center, 15 * _px, color);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), h.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      width: size,
      height: size + tail,
    );
  }

  static void _drawIconGlyph(
    Canvas canvas,
    IconData icon,
    Offset center,
    double fontSize,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  static Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'coffee':
        return const Color(0xFF6D4C41);
      case 'drink':
      case 'drinks':
        return const Color(0xFF1565C0);
      case 'meal':
      case 'meals':
        return const Color(0xFFBF360C);
      default:
        return const Color(0xFF6200EE);
    }
  }

  static Future<BitmapDescriptor> buildMeetupMarker(Meetup meetup) async {
    const double w = _w * _px;
    const double cardH = _cardH * _px;
    const double totalH = _totalH * _px;
    const double av = _av * _px;
    const double pad = _pad * _px;
    const double r = _cornerR * _px;

    ui.Image? photo;
    if (meetup.image.isNotEmpty && meetup.image.startsWith('http')) {
      photo = await _loadNetworkImage(meetup.image);
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_px, _px * 2, w - _px * 2, cardH - _px * 2),
        Radius.circular(r),
      ),
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );

    // White card
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, cardH), Radius.circular(r)),
      Paint()..color = Colors.white,
    );

    // Arrow pointer
    final arrow = Path()
      ..moveTo(w / 2 - 8 * _px, cardH)
      ..lineTo(w / 2, totalH - 0.5 * _px)
      ..lineTo(w / 2 + 8 * _px, cardH)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.white);

    // Avatar
    final cx = pad + av / 2;
    final cy = cardH / 2;

    if (photo != null) {
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: av / 2)),
      );
      paintImage(
        canvas: canvas,
        rect: Rect.fromCircle(center: Offset(cx, cy), radius: av / 2),
        image: photo,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else {
      final color = typeColor(meetup.type);
      canvas.drawCircle(
        Offset(cx, cy), av / 2,
        Paint()..color = color.withValues(alpha: 0.15),
      );
      canvas.drawCircle(
        Offset(cx, cy), av / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * _px,
      );
      _drawText(
        canvas,
        meetup.hostName.isNotEmpty ? meetup.hostName[0].toUpperCase() : '?',
        Offset(cx, cy),
        14 * _px,
        FontWeight.w700,
        color,
        av,
        centered: true,
      );
    }

    // Title + name
    final textLeft = pad + av + pad;
    final textWidth = w - textLeft - pad;

    _drawText(
      canvas,
      'Meet For ${meetup.type}',
      Offset(textLeft, cy - 11 * _px),
      10.5 * _px,
      FontWeight.w700,
      const Color(0xFF1A1A1A),
      textWidth,
      centered: false,
    );
    _drawText(
      canvas,
      meetup.hostName.split(' ').last,
      Offset(textLeft, cy + 4 * _px),
      9.5 * _px,
      FontWeight.w400,
      const Color(0xFF777777),
      textWidth,
      centered: false,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(w.toInt(), totalH.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      width: _w,
      height: _totalH,
    );
  }

  static Future<BitmapDescriptor> buildUserLocationMarker() async {
    const double size = 22.0;
    final double sz = size * _px;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(
      Offset(sz / 2, sz / 2),
      sz / 2 - _px,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * _px,
    );
    canvas.drawCircle(
      Offset(sz / 2, sz / 2),
      sz / 2 - 3 * _px,
      Paint()..color = const Color(0xFF1A73E8),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(sz.toInt(), sz.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      width: size,
      height: size,
    );
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    double fontSize,
    FontWeight weight,
    Color color,
    double maxWidth, {
    bool centered = true,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );
    painter.layout(maxWidth: maxWidth);
    final dx = centered ? position.dx - painter.width / 2 : position.dx;
    final dy = position.dy - painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  static Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final completer = Completer<ui.Image?>();
      final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!completer.isCompleted) completer.complete(info.image);
          stream.removeListener(listener);
        },
        onError: (_, __) {
          if (!completer.isCompleted) completer.complete(null);
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);
      return await completer.future
          .timeout(const Duration(seconds: 4), onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }
}
