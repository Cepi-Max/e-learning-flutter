class Padi {
  final int id;
  final String nama;
  final String jumlahPadi;
  final String jenisPadi;

  Padi({
    required this.id,
    required this.nama,
    required this.jumlahPadi,
    required this.jenisPadi,
  });

  factory Padi.fromJson(Map<String, dynamic> json) {
    return Padi(
      id: json['id'],
      nama: json['nama'],
      jumlahPadi: json['jumlah_padi'],
      jenisPadi: json['jenis_padi'],
    );
  }
}
