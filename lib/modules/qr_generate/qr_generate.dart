import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class QRGenerate extends StatefulWidget {
  final String regNo;
  const QRGenerate({super.key, required this.regNo});

  @override
  State<QRGenerate> createState() => _QRGenerateState();
}

class _QRGenerateState extends State<QRGenerate> {
  GlobalKey globalKey = GlobalKey();

  Future<void> shareQrCode() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile('${tempDir.path}/image.png')],
        text:
            'Here is your QR code of our association for your vechile no. ${widget.regNo}',
      );
    } catch (e) {
      // print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code of ${widget.regNo}'),
      ),
      body: Center(
        child: RepaintBoundary(
          key: globalKey,
          child: QrImageView(
            data: widget.regNo,
            version: QrVersions.auto,
            size: 320.0,
            embeddedImage: const AssetImage('assets/images/logo.png'),
            embeddedImageStyle: const QrEmbeddedImageStyle(
              size: Size(80, 80),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: shareQrCode,
        tooltip: 'Share',
        child: const Icon(Icons.share),
      ),
    );
  }
}
