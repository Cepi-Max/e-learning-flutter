class MataKuliah {
  final int id;
  final String kodeMk;
  final String namaMk;
  final String deskripsi;
  final int dosenId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MataKuliah({
    required this.id,
    required this.kodeMk,
    required this.namaMk,
    required this.deskripsi,
    required this.dosenId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      id: json['id'],
      kodeMk: json['kode_mk'],
      namaMk: json['nama_mk'],
      deskripsi: json['deskripsi'],
      dosenId: json['dosen_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_mk': kodeMk,
      'nama_mk': namaMk,
      'deskripsi': deskripsi,
      'dosen_id': dosenId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Materi {
  final int id;
  final int mataKuliahId;
  final String judul;
  final String isi;
  final String? file;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MataKuliah? mataKuliah;

  Materi({
    required this.id,
    required this.mataKuliahId,
    required this.judul,
    required this.isi,
    this.file,
    required this.createdAt,
    required this.updatedAt,
    this.mataKuliah,
  });

  factory Materi.fromJson(Map<String, dynamic> json) {
    return Materi(
      id: json['id'],
      mataKuliahId: json['mata_kuliah_id'],
      judul: json['judul'],
      isi: json['isi'],
      file: json['file'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      mataKuliah: json['mata_kuliah'] != null
          ? MataKuliah.fromJson(json['mata_kuliah'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mata_kuliah_id': mataKuliahId,
      'judul': judul,
      'isi': isi,
      'file': file,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'mata_kuliah': mataKuliah?.toJson(),
    };
  }
}
