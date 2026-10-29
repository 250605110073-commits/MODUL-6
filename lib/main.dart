
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const DaftarGame(),
    );
  }
}

class DaftarGame extends StatefulWidget {
  const DaftarGame({super.key});

  @override
  State<DaftarGame> createState() => _DaftarGameState();
}

class _DaftarGameState extends State<DaftarGame> {
  List dataGame = [];
  bool loading = true;
  String pesanError = '';

  @override
  void initState() {
    super.initState();
    _ambilData();
  }

  Future<void> _ambilData() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.freetogame.com/api/games'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          dataGame = data.take(20).toList();
          loading = false;
        });
      } else {
        throw Exception('Gagal mengambil data game');
      }
    } catch (e) {
      setState(() {
        loading = false;
        pesanError = 'Data game gagal dimuat. Coba lagi.';
      });
    }
  }

  Container _tombolBaca() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Baca Info',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _listItem(
    String url,
    String judul,
    String genre,
    String rilis,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              url,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: Colors.black12,
                  child: const Icon(Icons.videogame_asset),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  genre,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 3),
                Text(
                  rilis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 7),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _tombolBaca(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Game'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pesanError.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pesanError),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                            pesanError = '';
                          });
                          _ambilData();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: dataGame.length,
                  itemBuilder: (context, index) {
                    final game = dataGame[index];

                    return _listItem(
                      game['thumbnail'] ?? '',
                      game['title'] ?? 'Tidak ada judul',
                      game['genre'] ?? 'Tidak ada genre',
                      game['release_date'] ?? 'Tidak ada tanggal',
                    );
                  },
                ),
    );
  }
}
