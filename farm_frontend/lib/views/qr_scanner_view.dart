import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/cow_provider.dart';

class QRScannerView extends ConsumerStatefulWidget {
  const QRScannerView({super.key});

  @override
  ConsumerState<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends ConsumerState<QRScannerView> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Küpe Kodu Oku'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.unavailable:
                  case TorchState.auto:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                  default:
                    return const Icon(Icons.camera);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_isProcessing) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isProcessing = true);
                  final String tagNumber = barcode.rawValue!;
                  
                  // Backend'e sorgu atıyoruz
                  try {
                    final cowData = await ref.read(cowByTagProvider(tagNumber).future);
                    
                    if (mounted) {
                      if (cowData != null) {
                         _showSuccessDialog(cowData);
                      } else {
                         _showErrorDialog('Bu küpe numarasına ait hayvan bulunamadı: $tagNumber');
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      _showErrorDialog('Sunucu hatası: Küpe numarası sorgulanamadı.');
                    }
                  } finally {
                    // İşlem bittiğinde biraz bekleyip kamerayı tekrar aktif et
                    await Future.delayed(const Duration(seconds: 3));
                    if (mounted) {
                      setState(() => _isProcessing = false);
                    }
                  }
                  break; // Sadece ilk okunan barkodu işle
                }
              }
            },
          ),
          // Scanner Overlay (Nişangah)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryGreen, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            ),
        ],
      ),
    );
  }

  void _showSuccessDialog(dynamic cowData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('✅ Hayvan Bulundu: ${cowData['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Küpe No: ${cowData['tag_number']}'),
            Text('Kategori: ${cowData['category']}'),
            Text('Durum: ${cowData['status']}'),
            // Detaylar artırılabilir
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.pop(context);
               Navigator.pop(context); // Scanner ekranından çık
            },
            child: const Text('Kapat', style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('❌ Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: AppColors.barnRed)),
          ),
        ],
      ),
    );
  }
}
