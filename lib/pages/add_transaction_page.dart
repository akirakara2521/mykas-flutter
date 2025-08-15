import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../models/kategori_model.dart';
import '../services/api_service.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input text
  final _jumlahController = TextEditingController();
  final _deskripsiController = TextEditingController();

  // Variabel untuk menampung data
  late Future<List<Kategori>> _kategoriFuture;
  String? _selectedKategoriId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Ambil data kategori saat halaman pertama kali dibuka
    _kategoriFuture = apiService.getKategori();
    _selectedDate = DateTime.now(); // Set tanggal default ke hari ini
  }

  // --- UI dan LOGIKA AKAN DITAMBAHKAN DI SINI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Transaksi Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown untuk Kategori
                FutureBuilder<List<Kategori>>(
                  future: _kategoriFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('Tidak ada kategori ditemukan');
                    } else {
                      return DropdownButtonFormField<String>(
                        value: _selectedKategoriId,
                        hint: Text('Pilih Kategori'),
                        items:
                            snapshot.data!.map((kategori) {
                              return DropdownMenuItem<String>(
                                value: kategori.idKategori.toString(),
                                child: Text(kategori.namaKategori),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKategoriId = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Kategori tidak boleh kosong'
                                    : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),

                // Input untuk Jumlah
                TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah (Contoh: 50000)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Input untuk Deskripsi
                TextFormField(
                  controller: _deskripsiController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Pemilih Tanggal
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal'
                            : 'Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(onPressed: _pickDate, child: Text('PILIH')),
                  ],
                ),
                SizedBox(height: 24),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: _submitData,
                  child: Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tambahkan dua fungsi ini di dalam class _AddTransactionPageState
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      // Siapkan data untuk dikirim
      final data = {
        'id_kategori': _selectedKategoriId!,
        'jumlah': _jumlahController.text,
        'deskripsi': _deskripsiController.text,
        'tanggal_transaksi': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      };

      // Panggil API
      bool success = await apiService.createTransaksi(data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman sebelumnya dan kirim sinyal 'true' untuk refresh
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
