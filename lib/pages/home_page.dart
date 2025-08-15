import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mykas_frontend_flutter/pages/add_transaction_page.dart';
import 'package:mykas_frontend_flutter/pages/kategori_page.dart';
import 'package:mykas_frontend_flutter/pages/history_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaksi_model.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Transaksi>> listTransaksi;
  final ApiService apiService = ApiService();
  bool _isBalanceVisible = true;
  final List<Color> chartColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.teal,
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyKas Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4e54c8), Color(0xFF8f94fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KategoriPage()),
                ).then((_) => _loadData()),
            tooltip: 'Manajemen Kategori',
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: listTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          double totalPemasukan = 0;
          double totalPengeluaran = 0;
          List<Transaksi> transaksiList = snapshot.data ?? [];
          Map<String, double> spendingByCategory = {}; // Data untuk grafik

          for (var trx in transaksiList) {
            if (trx.tipeKategori == 'pemasukan') {
              totalPemasukan += double.parse(trx.jumlah);
            } else {
              totalPengeluaran += double.parse(trx.jumlah);
              // Mengisi data untuk grafik
              spendingByCategory.update(
                trx.namaKategori,
                (value) => value + double.parse(trx.jumlah),
                ifAbsent: () => double.parse(trx.jumlah),
              );
            }
          }
          double sisaUang = totalPemasukan - totalPengeluaran;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWalletCard(
                  sisaUang,
                  totalPengeluaran,
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ),
                ),

                // Menampilkan grafik jika ada pengeluaran
                if (totalPengeluaran > 0)
                  _buildPieChart(spendingByCategory, totalPengeluaran),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionHistoryPage(),
                          ),
                        ).then((_) => _loadData()),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Transaksi Terakhir",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (transaksiList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: Text('Belum ada transaksi.')),
                  )
                else
                  ListView.builder(
                    itemCount:
                        transaksiList.length > 3 ? 3 : transaksiList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final transaksi = transaksiList[index];
                      final isPemasukan = transaksi.tipeKategori == 'pemasukan';
                      final currencyFormatter = NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      );
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: ListTile(
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
                          trailing: Text(
                            currencyFormatter.format(
                              double.parse(transaksi.jumlah),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPemasukan ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionPage()),
          );
          if (result == true) _loadData();
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, double totalSpending) {
    int colorIndex = 0;
    final chartData =
        data.entries.map((entry) {
          final percentage = (entry.value / totalSpending) * 100;
          final color = chartColors[colorIndex % chartColors.length];
          colorIndex++;
          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2),
              ],
            ),
          );
        }).toList();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ringkasan Pengeluaran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: chartData,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  data.keys.map((name) {
                    final color =
                        chartColors[data.keys.toList().indexOf(name) %
                            chartColors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(name),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              height: 110,
            ),
            SizedBox(height: 24),
            ...List.generate(
              3,
              (index) => Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.white),
                  title: Container(height: 16, width: 100, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(
    double sisaUang,
    double pengeluaran,
    NumberFormat formatter,
  ) {
    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: 8.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4e54c8), Color(0xFF8f94fb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sisa Uang Anda',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _isBalanceVisible
                            ? formatter.format(sisaUang)
                            : 'Rp *******',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Pengeluaran',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    formatter.format(pengeluaran),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
