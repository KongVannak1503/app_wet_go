import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class QrCodeGeneration {
  static Future<void> show(BuildContext context, String data) async {
    final ScreenshotController screenshotController = ScreenshotController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('QR Code'),
          content: SizedBox(
            width: 220,
            height: 220,
            child: Screenshot(
              controller: screenshotController,
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final status = await Permission.storage.request();
                if (!status.isGranted) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Permission denied ❌')),
                    );
                  }
                  return;
                }

                final image = await screenshotController.capture();
                if (image == null) return;

                Directory? directory;

                // This is the hardcoded path you requested. It is not recommended.
                if (Platform.isAndroid) {
                  directory = Directory('/storage/emulated/0/Download');
                } else if (Platform.isIOS) {
                  directory = await getApplicationDocumentsDirectory();
                } else {
                  directory = await getApplicationDocumentsDirectory();
                }

                if (directory == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not find a valid directory to save file.',
                        ),
                      ),
                    );
                  }
                  return;
                }

                if (!await directory.exists()) {
                  await directory.create(recursive: true);
                }

                final filePath = '${directory.path}/store-qr.png';
                final file = File(filePath);
                await file.writeAsBytes(image);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved to ${file.path} ✅')),
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
