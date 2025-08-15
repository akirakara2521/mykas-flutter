import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/kategori_model.dart';
import '../models/transaksi_model.dart';

class ApiService {
  final String baseUrl = "https://5121fa5db47a.ngrok-free.app/api";

  Future<List<Kategori>> getKategori() async {
    final response = await http.get(Uri.parse('$baseUrl/kategori'));
    if (response.statusCode == 200) {
      return kategoriFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data kategori');
    }
  }

  Future<bool> createKategori(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kategori'),
      body: data,
    );
    return response.statusCode == 201;
  }

  Future<bool> updateKategori(int id, Map<String, String> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kategori/$id'),
      body: data,
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteKategori(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/kategori/$id'));
    return response.statusCode == 200;
  }

  Future<List<Transaksi>> getTransaksi() async {
    final response = await http.get(Uri.parse('$baseUrl/transaksi'));
    if (response.statusCode == 200) {
      return transaksiFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data transaksi');
    }
  }

  Future<bool> createTransaksi(Map<String, String> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transaksi'),
      body: data,
    );
    if (response.statusCode == 201) {
      // 201 Created
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateTransaksi(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transaksi/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Gagal mengupdate: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteTransaksi(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/transaksi/$id'));

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Gagal menghapus: ${response.body}');
      return false;
    }
  }
}
