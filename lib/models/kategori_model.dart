import 'dart:convert';

List<Kategori> kategoriFromJson(String str) =>
    List<Kategori>.from(json.decode(str).map((x) => Kategori.fromJson(x)));

class Kategori {
  final int idKategori;
  final String namaKategori;
  final String tipeKategori;

  Kategori({
    required this.idKategori,
    required this.namaKategori,
    required this.tipeKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    idKategori: int.parse(
      json["id_kategori"],
    ), // Parsing dari string jika perlu
    namaKategori: json["nama_kategori"],
    tipeKategori: json["tipe_kategori"],
  );
}
