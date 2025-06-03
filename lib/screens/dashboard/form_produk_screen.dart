import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../api/product_service.dart';


class FormProductScreen extends StatefulWidget {
  const FormProductScreen({super.key});

  @override
  State<FormProductScreen> createState() => _FormProductScreenState();
}

class _FormProductScreenState extends State<FormProductScreen> {
  final ProductService productService = ProductService();
  final picker = ImagePicker();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  File? selectedImage;
  String? imageUrl;

  int? id;
  bool isViewOnly = false;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        id = args['id'];
        nameController.text = args['name'] ?? '';
        descController.text = args['description'] ?? '';
        priceController.text = args['price']?.toString() ?? '';
        stockController.text = args['stock']?.toString() ?? '';
        imageUrl = args['image'] ?? '';
        isViewOnly = args['viewOnly'] ?? false;
      });
    }
  }

Future<void> pickImage() async {
  try {
    // Meminta izin penyimpanan untuk Android dan akses foto untuk iOS
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showSnackBar('Permission untuk mengakses penyimpanan ditolak');
        return;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        _showSnackBar('Permission untuk mengakses foto ditolak');
        return;
      }
    }

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        imageUrl = null; // Reset image URL jika pilih baru
      });
    } else {
      _showSnackBar('Tidak ada gambar yang dipilih.');
    }
  } catch (e) {
    debugPrint('pickImage error: $e');
    _showSnackBar('Gagal mengambil gambar: ${e.toString()}');
  }
}



  Future<void> _submitOrUpdate() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final price = priceController.text.trim();
    final stock = stockController.text.trim();

    if ([name, desc, price, stock].any((e) => e.isEmpty)) {
      _showSnackBar('Semua field harus diisi!');
      return;
    }

    final parsedPrice = double.tryParse(price);
    final parsedStock = int.tryParse(stock);

    if (parsedPrice == null || parsedStock == null) {
      _showSnackBar('Harga harus berupa angka desimal dan stok berupa angka bulat.');
      return;
    }

    if (selectedImage == null && (imageUrl == null || imageUrl!.isEmpty)) {
      _showSnackBar('Gambar produk harus dipilih.');
      return;
    }

    setState(() => isLoading = true);

    final response = id == null
        ? await productService.postData(
            name, desc, price, stock, imageUrl ?? '', file: selectedImage)
        : await productService.putData(
            id!, name, desc, price, stock, imageUrl ?? '', file: selectedImage);

    setState(() => isLoading = false);

    if (response.success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/product-list', (_) => false);
    } else {
      _showSnackBar(response.message);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = isViewOnly;

    return Scaffold(
      appBar: AppBar(
        title: Text(isViewOnly
            ? 'Detail Produk'
            : id == null ? 'Tambah Produk' : 'Edit Produk'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildTextField('Nama Produk', nameController, readOnly),
                      const SizedBox(height: 16),
                      _buildTextField('Deskripsi', descController, readOnly, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField('Harga', priceController, readOnly,
                          inputType: TextInputType.number,
                          inputFormatter: FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))),
                      const SizedBox(height: 16),
                      _buildTextField('Stok', stockController, readOnly,
                          inputType: TextInputType.number,
                          inputFormatter: FilteringTextInputFormatter.digitsOnly),
                      const SizedBox(height: 16),
                      if (!readOnly) ...[
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: pickImage,
                              icon: const Icon(Icons.image),
                              label: const Text('Pilih Gambar'),
                            ),
                            const SizedBox(width: 16),
                            if (selectedImage != null)
                              const Text('Gambar dipilih', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((imageUrl?.isNotEmpty ?? false) && selectedImage == null)
                        Image.network(imageUrl!, height: 150),
                      const SizedBox(height: 24),
                      if (!readOnly)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitOrUpdate,
                            icon: Icon(id == null ? Icons.send : Icons.update),
                            label: Text(id == null ? 'Tambah' : 'Update'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool readOnly, {
    TextInputType inputType = TextInputType.text,
    TextInputFormatter? inputFormatter,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: inputType,
      inputFormatters: inputFormatter != null ? [inputFormatter] : [],
      maxLines: maxLines,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
