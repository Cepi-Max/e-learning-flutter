import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/farmer/filter_bottom.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../../models/padi_model.dart';
import '../../api/padi_service.dart';
import '../../models/weather_model.dart';
import '../../api/weather_service.dart';


class DataPadiScreen extends StatefulWidget {
  const DataPadiScreen({super.key});

  @override
  State<DataPadiScreen> createState() => _DataPadiScreenState();
}

class _DataPadiScreenState extends State<DataPadiScreen> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  List<Padi> listPadi =[];
  List<Padi> allPadis = [];       // Ini semua data dari API
  List<Padi> filteredPadis = [];
  PadiService padiService = PadiService();

  bool isLoading = true;
  String? error;

  int? id; 
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  Weather? currentWeather;


  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    
    if (context.mounted) {
      // Navigasi ke halaman login setelah logout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false, 
      );
    }
  }

  
 @override
  void initState() {
    fetchPadis();
    super.initState();
    fetchWeather();
  }

  void fetchWeather() async {
    final weather = await WeatherService().fetchWeather();
    setState(() {
      currentWeather = weather;
    });
  }

  void fetchPadis() async {
    try {
      final response = await PadiService().getData();

     if (response.success) {
        final List<Padi> padis = response.data?['padis'] ?? [];
        setState(() {
          allPadis = padis;
          filteredPadis = padis;
          isLoading = false;
        });

      } else {
        setState(() {
          error = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _deleteData(int id) async {
    final response = await padiService.deleteData(id.toString());

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil dihapus')),
      );
      fetchPadis();
    } else {
      print('Hapus data gagal: ${response.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  Future<void> fetchDataPadiFiltered(int bulan, int tahun) async {
    setState(() {
      currentMonth = bulan;
      currentYear = tahun;
    });
    
    final response = await padiService.getFilteredData(bulan, tahun);

    if (response.success) {
        final List<Padi> padis = response.data?['padis'] ?? [];
        setState(() {
          allPadis = padis;
          isLoading = false;
        });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
    }
  }

  // Add this function to show a delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, int id, String name) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteData(id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
    }

  void filterPadi(String keyword) {
    final filtered = allPadis.where((padi) {
      final nameLower = padi.nama.toLowerCase();
      final jenisLower = padi.jenisPadi.toLowerCase();
      final searchLower = keyword.toLowerCase();
      return nameLower.contains(searchLower) || jenisLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredPadis = filtered;
    });
  }


  Widget buildWeatherCard() {
  if (currentWeather == null) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8BC34A)),
      ),
    );
  }
  
  // Mendapatkan ikon yang sesuai berdasarkan deskripsi cuaca
  IconData getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('hujan')) {
      return Icons.water_drop;
    } else if (description.contains('cerah')) {
      return Icons.wb_sunny;
    } else if (description.contains('berawan') || description.contains('mendung')) {
      return Icons.cloud;
    } else if (description.contains('badai') || description.contains('petir')) {
      return Icons.thunderstorm;
    } else if (description.contains('kabut')) {
      return Icons.foggy;
    } else {
      return Icons.cloud_queue;
    }
  }
  
  return Card(
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 6,
    color: Colors.white,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFAED581), // Hijau daun muda
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cuaca di Desa Rias',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33691E), // Hijau tua untuk kontras
                  ),
                ),
                Icon(
                  getWeatherIcon(currentWeather!.description),
                  size: 38,
                  color: Color(0xFF33691E),
                ),
              ],
            ),
            Divider(color: Color(0xFFDCEDC8), thickness: 1.5),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${currentWeather!.temperature}°C',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33691E),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              currentWeather!.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF558B2F),
              ),
            ),
            SizedBox(height: 20),
            _buildWeatherInfoRow(
              Icons.water_outlined,
              'Kelembapan',
              '${currentWeather!.humidity}%',
            ),
            SizedBox(height: 12),
            _buildWeatherInfoRow(
              Icons.air,
              'Kecepatan Angin',
              '${currentWeather!.windSpeed} m/s',
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildWeatherInfoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFDCEDC8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Color(0xFF558B2F),
          size: 24,
        ),
      ),
      SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF689F38),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF33691E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
          child: isSearching
            ? AppBar(
                key: const ValueKey('searchAppBar'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchController.clear();
                      filteredPadis = allPadis;
                    });
                  },
                ),
                title: TextField(
                  controller: searchController,
                  autofocus: true,
                  style: TextStyle(
                      color: Colors.white,
                    ),
                  decoration: const InputDecoration(
                    hintText: 'Cari data padi...',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() => filteredPadis = allPadis);
                    } else {
                      filterPadi(value);
                    }
                  },
                ),
                backgroundColor: Colors.transparent, 
                elevation: 0, 
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 28, 126, 19),
                        Color.fromARGB(255, 28, 126, 19),
                        Color.fromARGB(255, 28, 126, 19),
                      ],
                      stops: [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                foregroundColor: Colors.white,
              )
              : Container(
                  key: const ValueKey('mainAppBar'),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 73, 201, 79), Color.fromARGB(255, 33, 218, 42), Color.fromARGB(255, 28, 126, 19)],
                      stops: [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: AppBar(
                   title: const Text(
                    'Data Padi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            isSearching = true;
                          });
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'filter') {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => FilterBottomSheet(
                                initialMonth: currentMonth,
                                initialYear: currentYear,
                                onFilter: (bulan, tahun) {
                                  fetchDataPadiFiltered(bulan, tahun);
                                },
                              ),
                            );
                          } else if (value == 'profile') {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          } else if (value == 'logout') {
                            _handleLogout(context, authProvider);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'filter',
                            child: ListTile(
                              leading: Icon(Icons.filter_alt_outlined),
                              title: Text('Filter'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'profile',
                            child: ListTile(
                              leading: Icon(Icons.person_outline),
                              title: Text('Profile'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Logout'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),

      body: Column(
  children: [
    // Tampilkan kartu cuaca
    buildWeatherCard(),

    // Tampilkan konten utama
    Expanded(
      child: allPadis.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 80, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data padi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 13, 148, 20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/tambah-data-padi'),
                  ),
                ],
              ),
            )
          : filteredPadis.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.orange[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green[50]!, Colors.white],
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredPadis.length,
                    itemBuilder: (context, index) {
                      final padi = filteredPadis[index];
                      return Hero(
                        tag: 'padi-${padi.id}',
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Colors.green[100],
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/tambah-data-padi',
                                arguments: [
                                  padi.id,
                                  padi.nama,
                                  padi.jumlahPadi.toString(),
                                  padi.jenisPadi,
                                ],
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          padi.nama,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(
                                                padi.jenisPadi,
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              backgroundColor: Colors.green[50],
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${padi.jumlahPadi.toString()} kg",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red[700],
                                    tooltip: 'Hapus',
                                    onPressed: () => _showDeleteConfirmation(context, padi.id, padi.nama),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    ),
  ],
),
floatingActionButton: allPadis.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/tambah-data-padi'),
              backgroundColor: Color.fromARGB(255, 13, 148, 20),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Data'),
              elevation: 4,
            ),
    );
  }
}
