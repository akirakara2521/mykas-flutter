import 'dart:convert';

List<Transaksi> transaksiFromJson(String str) =>
    List<Transaksi>.from(json.decode(str).map((x) => Transaksi.fromJson(x)));

class Transaksi {
  final int idTransaksi;
  final int idKategori;
  final String? deskripsi;
  final String jumlah;
  final DateTime tanggalTransaksi;
  final String namaKategori; // Hasil join
  final String tipeKategori; // Hasil join

  Transaksi({
    required this.idTransaksi,
    required this.idKategori,
    this.deskripsi,
    required this.jumlah,
    required this.tanggalTransaksi,
    required this.namaKategori,
    required this.tipeKategori,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
    idTransaksi: int.parse(json["id_transaksi"]),
    idKategori: int.parse(json["id_kategori"]),
    deskripsi: json["deskripsi"],
    jumlah: json["jumlah"],
    tanggalTransaksi: DateTime.parse(json["tanggal_transaksi"]),
    namaKategori: json["nama_kategori"],
    tipeKategori: json["tipe_kategori"],
  );
}
