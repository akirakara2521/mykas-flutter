import 'package:flutter/material.dart';
import '../models/kategori_model.dart';
import '../services/api_service.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final ApiService apiService = ApiService();
  late Future<List<Kategori>> _kategoriFuture;

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  void _loadKategori() {
    setState(() {
      _kategoriFuture = apiService.getKategori();
    });
  }

  void _showFormDialog({Kategori? kategori}) {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: kategori?.namaKategori);
    String _tipeValue = kategori?.tipeKategori ?? 'pengeluaran';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(kategori == null ? 'Tambah Kategori' : 'Ubah Kategori'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(labelText: 'Nama Kategori'),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _tipeValue,
                  items:
                      ['pengeluaran', 'pemasukan']
                          .map(
                            (tipe) => DropdownMenuItem(
                              value: tipe,
                              child: Text(tipe),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _tipeValue = value;
                    }
                  },
                  decoration: InputDecoration(labelText: 'Tipe'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final data = {
                    'nama_kategori': _namaController.text,
                    'tipe_kategori': _tipeValue,
                  };

                  bool success;
                  if (kategori == null) {
                    success = await apiService.createKategori(data);
                  } else {
                    success = await apiService.updateKategori(
                      kategori.idKategori,
                      data,
                    );
                  }

                  if (success) {
                    Navigator.pop(context);
                    _loadKategori(); // Refresh list
                  }
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteKategori(int id) async {
    bool success = await apiService.deleteKategori(id);
    if (success) {
      _loadKategori();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kategori berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus kategori'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Kategori')),
      body: FutureBuilder<List<Kategori>>(
        future: _kategoriFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada kategori.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final kategori = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(kategori.namaKategori),
                  subtitle: Text('Tipe: ${kategori.tipeKategori}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(kategori: kategori),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteKategori(kategori.idKategori),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: Icon(Icons.add),
        tooltip: 'Tambah Kategori',
      ),
    );
  }
}
