import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../api/padi_service.dart';

class FormTambahPadiScreen extends StatefulWidget {
  const FormTambahPadiScreen({super.key});

  @override
  State<FormTambahPadiScreen> createState() => _FormTambahPadiScreenState();
}

class _FormTambahPadiScreenState extends State<FormTambahPadiScreen> {
  final PadiService padiService = PadiService();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();

  int? id; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List) {
      setState(() {
        id = int.tryParse(args[0].toString());
        namaController.text = args[1].toString();
        jumlahController.text = args[2].toString();
        jenisController.text = args[3].toString();
      });
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    jumlahController.dispose();
    jenisController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    final nama = namaController.text;
    final jumlah = jumlahController.text;
    final jenis = jenisController.text;

    if (nama.isEmpty || jumlah.isEmpty || jenis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }

    final response = await padiService.postData(nama, jumlah, jenis);
    if (response.success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/datapadi',
        (Route<dynamic> route) => false, // menghapus semua stack sebelumnya
      );
    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  Future<void> _putData() async {
    final nama = namaController.text;
    final jumlah = jumlahController.text;
    final jenis = jenisController.text;

    if (nama.isEmpty || jumlah.isEmpty || jenis.isEmpty || id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi dengan benar!')),
      );
      return;
    }
    
    final response = await padiService.putData(id!, nama, jumlah, jenis);
    
    if (response.success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/datapadi',
        (Route<dynamic> route) => false, // menghapus semua stack sebelumnya
      );
    } else {
      print('Update data gagal: ${response.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Padi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 73, 201, 79),
          Color.fromARGB(255, 33, 218, 42),
          Color.fromARGB(255, 28, 126, 19),
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(15),
      ),
    ),
  ),
  backgroundColor: Colors.transparent,
  elevation: 4,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(15),
    ),
  ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //       // Implementasi fungsi pencarian
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.filter_alt_outlined),
        //     onPressed: () {
        //       // Implementasi fungsi filter
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.person_outline),
        //     onPressed: () {
        //       // Implementasi fungsi profil
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    id == null ? 'Tambah Data Padi' : 'Edit Data Padi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Padi',
                      // prefixIcon: const Icon(Icons.grass),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: jumlahController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Jumlah (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: jenisController,
                    decoration: InputDecoration(
                      labelText: 'Jenis Padi',
                      // prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: id == null ? _submitData : _putData,
                      icon: Icon(id == null ? Icons.send : Icons.update),
                      label: Text(id == null ? 'Submit' : 'Update'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color.fromARGB(255, 13, 148, 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
