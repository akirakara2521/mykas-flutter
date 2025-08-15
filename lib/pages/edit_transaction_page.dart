import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kategori_model.dart';
import '../models/transaksi_model.dart'; // Impor Transaksi model
import '../services/api_service.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaksi transaksi; // Terima data transaksi

  EditTransactionPage({required this.transaksi}); // Constructor

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _jumlahController = TextEditingController();
  final _deskripsiController = TextEditingController();

  late Future<List<Kategori>> _kategoriFuture;
  String? _selectedKategoriId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _kategoriFuture = apiService.getKategori();

    // Isi form dengan data yang ada dari widget.transaksi
    _jumlahController.text = widget.transaksi.jumlah;
    _deskripsiController.text = widget.transaksi.deskripsi ?? '';
    _selectedKategoriId = widget.transaksi.idKategori.toString();
    _selectedDate = widget.transaksi.tanggalTransaksi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ubah Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown Kategori (kode sama persis dengan halaman tambah)
                FutureBuilder<List<Kategori>>(
                  future: _kategoriFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData) {
                      return Text('Tidak ada kategori');
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

                // Input Jumlah (kode sama persis)
                TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Jumlah tidak boleh kosong';
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Input Deskripsi (kode sama persis)
                TextFormField(
                  controller: _deskripsiController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Pemilih Tanggal (kode sama persis)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(onPressed: _pickDate, child: Text('PILIH')),
                  ],
                ),
                SizedBox(height: 24),

                // Tombol Simpan Perubahan
                ElevatedButton(
                  onPressed: _submitUpdate, // Panggil fungsi update
                  child: Text('Simpan Perubahan'),
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

  // Fungsi pickDate sama persis dengan halaman tambah
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Fungsi untuk submit perubahan
  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'id_kategori': _selectedKategoriId!,
        'jumlah': _jumlahController.text,
        'deskripsi': _deskripsiController.text,
        'tanggal_transaksi': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      };

      bool success = await apiService.updateTransaksi(
        widget.transaksi.idTransaksi,
        data,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kirim sinyal true untuk refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate transaksi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
