import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';
import 'edit_transaction_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Future<List<Transaksi>> listTransaksi;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      listTransaksi = apiService.getTransaksi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: listTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Belum ada transaksi.'));
          } else {
            return AnimationLimiter(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 8),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Transaksi transaksi = snapshot.data![index];
                  bool isPemasukan = transaksi.tipeKategori == 'pemasukan';

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Dismissible(
                          key: Key(transaksi.idTransaksi.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Konfirmasi Hapus"),
                                  content: const Text(
                                    "Apakah Anda yakin ingin menghapus transaksi ini?",
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text("Batal"),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text("Hapus"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) async {
                            bool success = await apiService.deleteTransaksi(
                              transaksi.idTransaksi,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Transaksi berhasil dihapus'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _loadData();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menghapus transaksi'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: ListTile(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditTransactionPage(
                                          transaksi: transaksi,
                                        ),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
                                }
                              },
                              leading: Icon(
                                isPemasukan
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isPemasukan ? Colors.green : Colors.red,
                              ),
                              title: Text(transaksi.namaKategori),
                              subtitle: Text(
                                transaksi.deskripsi ?? 'Tanpa deskripsi',
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currencyFormatter.format(
                                      double.parse(transaksi.jumlah),
                                    ),
                                    style: TextStyle(
                                      color:
                                          isPemasukan
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(transaksi.tanggalTransaksi),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.white),
              title: Container(height: 16, width: 100, color: Colors.white),
              subtitle: Container(height: 12, width: 150, color: Colors.white),
              trailing: Container(height: 24, width: 80, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
