import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/screens/widgets/transaction/unpaid_transaction_dialog.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  String? qrResult;
  final MobileScannerController cameraController = MobileScannerController();
  bool isDialogOpen = false;

  /// Pick image from gallery and scan QR
  Future<void> _pickImageAndScan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final BarcodeCapture? capture = await cameraController.analyzeImage(
          pickedFile.path,
        );

        final Barcode? barcode =
            (capture != null && capture.barcodes.isNotEmpty)
            ? capture.barcodes.first
            : null;

        if (barcode != null) {
          _showQrResult(barcode.rawValue);
        } else {
          setState(() {
            qrResult = "No QR code found in image";
          });
        }
      } catch (e) {
        setState(() {
          qrResult = "Error decoding QR: $e";
        });
      }
    }
  }

  /// Show QR value in a dialog
  void _showQrResult(String? value) {
    if (value == null || isDialogOpen) return;

    setState(() {
      qrResult = value;
      isDialogOpen = true;
    });

    showDialog(
      context: context,
      builder: (ctx) => UnpaidTransactionDialog(id: value),
      // AlertDialog(
      //   title: const Text("QR Code Detected"),
      //   content: Text(value),
      //   actions: [
      //     TextButton(
      //       onPressed: () => Navigator.of(ctx).pop(),
      //       child: const Text("Close"),
      //     ),
      //   ],
      // ),
    ).then((_) => setState(() => isDialogOpen = false));
  }

  /// Toggle flashlight
  void _toggleFlash() {
    cameraController.toggleTorch();
  }

  // @override
  // void dispose() {
  //   cameraController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc.scanQr),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: "Pick Image",
            onPressed: _pickImageAndScan,
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: "Toggle Flashlight",
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (capture.barcodes.isNotEmpty) {
                  _showQrResult(capture.barcodes.first.rawValue);
                }
              },
            ),
          ),
          // Expanded(
          //   flex: 1,
          //   child: Center(
          //     child: Text(
          //       qrResult ?? loc.scanPrompt,
          //       textAlign: TextAlign.center,
          //       style: const TextStyle(fontSize: 16),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
