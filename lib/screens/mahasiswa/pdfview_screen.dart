import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String materiJudul;

  const PdfViewerScreen({
    super.key,
    required this.fileUrl,
    required this.materiJudul,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localFilePath;
  bool isLoading = true;
  String loadingMessage = "Mempersiapkan file...";
  double downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      final dio = Dio();
      // Dapatkan direktori temporary di perangkat
      final dir = await getApplicationDocumentsDirectory();
      // Buat path file lokal
      final fileName = widget.fileUrl.split('/').last;
      final savePath = "${dir.path}/$fileName";

      setState(() {
        loadingMessage = "Mengunduh file...";
      });

      // Mulai unduh file dengan dio untuk mendapatkan progress
      await dio.download(
        widget.fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      // Setelah selesai, update state
      setState(() {
        localFilePath = savePath;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingMessage = "Gagal memuat file. Silakan coba lagi.";
      });
      // Tampilkan pesan error jika gagal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.materiJudul,
          style: const TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1565C0)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tampilkan progress bar selama mengunduh
                  CircularProgressIndicator(
                    value: downloadProgress > 0 ? downloadProgress : null,
                  ),
                  const SizedBox(height: 20),
                  Text(loadingMessage, style: const TextStyle(fontSize: 16)),
                  if (downloadProgress > 0) const SizedBox(height: 8),
                  if (downloadProgress > 0)
                    Text("${(downloadProgress * 100).toStringAsFixed(0)}%"),
                ],
              )
            : localFilePath != null
            ? PDFView(
                filePath: localFilePath!,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: true,
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saat menampilkan PDF: $error'),
                    ),
                  );
                },
              )
            : Text(loadingMessage), // Tampilkan pesan error jika path null
      ),
    );
  }
}
