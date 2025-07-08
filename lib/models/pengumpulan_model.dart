import 'tugas_model.dart';

class Pengumpulan {
  final int id;
  final int mahasiswaId;
  final int tugasId;
  final String fileTugas;
  final DateTime waktuKumpul;
  final int? nilai;
  final String? komentarDosen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Tugas? tugas;

  Pengumpulan({
    required this.id,
    required this.mahasiswaId,
    required this.tugasId,
    required this.fileTugas,
    required this.waktuKumpul,
    this.nilai,
    this.komentarDosen,
    required this.createdAt,
    required this.updatedAt,
    this.tugas,
  });

  factory Pengumpulan.fromJson(Map<String, dynamic> json) {
    return Pengumpulan(
      id: json['id'],
      mahasiswaId: json['mahasiswa_id'],
      tugasId: json['tugas_id'],
      fileTugas: json['file'],
      waktuKumpul: DateTime.parse(json['waktu_kumpul']),
      nilai: json['nilai'],
      komentarDosen: json['komentar_dosen'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tugas: json['tugas'] != null ? Tugas.fromJson(json['tugas']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'tugas_id': tugasId,
      'file': fileTugas,
      'waktu_kumpul': waktuKumpul.toIso8601String(),
      'nilai': nilai,
      'komentar_dosen': komentarDosen,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tugas': tugas?.toJson(),
    };
  }
}
