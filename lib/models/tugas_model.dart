import 'pengumpulan_model.dart';
import 'materi_model.dart';

class Tugas {
  final int id;
  final int mataKuliahId;
  final String judul;
  final String deskripsi;
  final DateTime batasPengumpulan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MataKuliah? mataKuliah;
  final Pengumpulan? pengumpulan;

  Tugas({
    required this.id,
    required this.mataKuliahId,
    required this.judul,
    required this.deskripsi,
    required this.batasPengumpulan,
    required this.createdAt,
    required this.updatedAt,
    this.mataKuliah,
    this.pengumpulan,
  });

  factory Tugas.fromJson(Map<String, dynamic> json) {
    return Tugas(
      id: json['id'],
      mataKuliahId: json['mata_kuliah_id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      batasPengumpulan: DateTime.parse(json['batas_pengumpulan']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mataKuliah: json['mata_kuliah'] != null
          ? MataKuliah.fromJson(json['mata_kuliah'])
          : null,
      // Di dalam factory Tugas.fromJson
      pengumpulan: json['pengumpulan'] != null
          ? Pengumpulan.fromJson(json['pengumpulan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mata_kuliah_id': mataKuliahId,
      'judul': judul,
      'deskripsi': deskripsi,
      'batas_pengumpulan': batasPengumpulan.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mata_kuliah': mataKuliah?.toJson(),
    };
  }
}
