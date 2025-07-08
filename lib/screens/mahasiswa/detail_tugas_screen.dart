import 'dart:io';

import 'package:Edu_Sohib/screens/mahasiswa/pdfview_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/tugas_model.dart';
import '../../models/pengumpulan_model.dart';
import '../../api/pengumpulan_service.dart'; // Menggunakan nama file yang konsisten
import '../../utils/constants.dart';

class DetailTugasScreen extends StatefulWidget {
  final Tugas tugas;

  const DetailTugasScreen({super.key, required this.tugas});

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  final PengumpulanService _pengumpulanService = PengumpulanService();

  Pengumpulan? _pengumpulan;
  File? _selectedFile;
  bool _isSubmitting = false;
  bool _isLoading = true; // Set ke true untuk loading awal

  @override
  void initState() {
    super.initState();
    _refreshPengumpulanData();
  }

  // Method untuk refresh data pengumpulan
  Future<void> _refreshPengumpulanData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await _pengumpulanService.getPengumpulanByTugasId(
        widget.tugas.id,
      );
      if (mounted && response.success) {
        setState(() {
          _pengumpulan = response.data;
        });
      }
    } catch (e) {
      print('Error refreshing pengumpulan data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDeadline(DateTime deadline) {
    return DateFormat('EEEE, dd MMMM HH:mm', 'id_ID').format(deadline);
  }

  String _getTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) return "Waktu habis";
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    if (days > 0) return '$days hari $hours jam lagi';
    final minutes = difference.inMinutes % 60;
    if (hours > 0) return '$hours jam $minutes menit lagi';
    return '$minutes menit lagi';
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip'],
    );

    if (result != null) {
      final filePath = result.files.single.path!;
      setState(() {
        _selectedFile = File(filePath);
      });
    }
  }

  Future<void> _submitOrUpdateTugas() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih file tugas terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (DateTime.now().isAfter(widget.tugas.batasPengumpulan)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas waktu telah berakhir.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = _pengumpulan == null
          ? await _pengumpulanService.submitTugas(
              tugasId: widget.tugas.id,
              filePath: _selectedFile!.path,
              context: context,
            )
          : await _pengumpulanService.updateTugas(
              pengumpulanId: _pengumpulan!.id,
              filePath: _selectedFile!.path,
            );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
          ),
        );

        // DIPERBAIKI: Jika sukses, langsung update state dari data response
        // Ini lebih efisien daripada memanggil refresh API lagi.
        if (response.success) {
          setState(() {
            _pengumpulan = response.data; // Gunakan data dari response
            _selectedFile = null; // Reset file yang dipilih setelah berhasil
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _viewSubmittedFile(String fileName) {
    final fileUrl = '${AppConstants.apiStorageUrl}$fileName';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          fileUrl: fileUrl,
          materiJudul: 'Jawaban: ${widget.tugas.judul}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLate = DateTime.now().isAfter(widget.tugas.batasPengumpulan);
    final timeRemaining = _getTimeRemaining(widget.tugas.batasPengumpulan);
    final bool hasSubmitted = _pengumpulan != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1565C0)),
          onPressed: () =>
              Navigator.pop(context, true), // Selalu kirim true untuk refresh
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1565C0)),
            onPressed: _refreshPengumpulanData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(timeRemaining, isLate),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  hasSubmitted ? _buildSubmittedView() : _buildSubmissionView(),
                  const SizedBox(height: 32),
                  if (_isSubmitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            (isLate && !hasSubmitted) ||
                                (!hasSubmitted && _selectedFile == null) ||
                                (hasSubmitted && _selectedFile == null)
                            ? null
                            : _submitOrUpdateTugas,
                        icon: Icon(
                          hasSubmitted
                              ? Icons.edit_document
                              : Icons.upload_file,
                        ),
                        label: Text(
                          hasSubmitted ? 'Perbarui Jawaban' : 'Kumpulkan Tugas',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasSubmitted
                              ? Colors.orange.shade700
                              : const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(String timeRemaining, bool isLate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.tugas.mataKuliah?.namaMk ?? 'Mata Kuliah',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            widget.tugas.judul,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today,
            'Batas Waktu',
            _formatDeadline(widget.tugas.batasPengumpulan),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.timer_outlined,
            'Sisa Waktu',
            timeRemaining,
            highlightColor: isLate ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Tugas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.tugas.deskripsi,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengumpulan Tugas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFile?.path.split('/').last ??
                        'Belum ada file dipilih',
                    style: TextStyle(color: Colors.grey[800]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Pilih File'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF1565C0)),
                foregroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Tugas Sudah Dikumpulkan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dikumpulkan pada: ${DateFormat('dd MMM HH:mm', 'id_ID').format(_pengumpulan!.createdAt)}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'File Jawaban Anda:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _viewSubmittedFile(_pengumpulan!.fileTugas),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Color(0xFF1565C0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pengumpulan!.fileTugas,
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.visibility, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ingin mengubah jawaban? Pilih file baru di bawah ini.'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.edit_document),
              label: Text(
                _selectedFile == null
                    ? 'Pilih File Baru'
                    : _selectedFile!.path.split('/').last,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.orange.shade700),
                foregroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? highlightColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 16),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: highlightColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
