import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Cek Resi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlutterFirstApp(),
    );
  }
}

class FlutterFirstApp extends StatefulWidget {
  const FlutterFirstApp({Key? key}) : super(key: key);

  @override
  State<FlutterFirstApp> createState() => _FlutterFirstAppState();
}

class _FlutterFirstAppState extends State<FlutterFirstApp> {
  List<String> options = ['jne', 'pos', 'tiki', 'sicepat', 'jnt', 'spx'];
  final TextEditingController _resiController = TextEditingController();
  final TextEditingController _kurirController = TextEditingController();
  dynamic _data = {};
  bool _isLoading = false;
  final Api _api = Api();

  @override
  void dispose() {
    _resiController.dispose();
    _kurirController.dispose();
    super.dispose();
  }

  Future<void> _cekResi() async {
    setState(() {
      _isLoading = true;
      _data = {};
    });

    final result =
        await _api.cekResi(_kurirController.text, _resiController.text);

    setState(() {
      _data = result;
      _isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tentang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Pembuat: Aditya Wahyu A'),
              const SizedBox(height: 8),
              GestureDetector(
                child: const Text(
                  'LINK TOKO KAMI : ',
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  await _launchURL('https://id.shp.ee/HKJRPM7');
                },
                child: const Text(
                  'Shopee',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  await _launchURL('https://s.lazada.co.id/s.I2lcD');
                },
                child: const Text('Lazada',
                    style: TextStyle(
                      color: Colors.blue,
                    )),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  await _launchURL('https://www.tokopedia.com/warnaparabola');
                },
                child: const Text('Tokopedia',
                    style: TextStyle(
                      color: Colors.blue,
                    )),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Warna Parabola',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Cek Resi By A.W.A',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'Tentang':
                  _showAboutDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Tentang',
                child: Text('Tentang'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Resi',
                      labelText: 'Resi',
                    ),
                    controller: _resiController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    items: options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _kurirController.text = newValue ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Kurir',
                      labelText: 'Kurir',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _cekResi,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Cari Resi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Hasil Pengecekan',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: _data.isNotEmpty
                  ? _data['status'] == 200
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Resi: ${_data['data']['summary']['awb']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Divider(),
                            Text(
                              'Kurir: ${_data['data']['summary']['courier']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Divider(),
                            Text(
                              'Status: ${_data['data']['summary']['status']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Divider(),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _data['data']['history'].length,
                              itemBuilder: (context, index) {
                                final item = _data['data']['history'][index];
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${item['date']}'),
                                      subtitle: Text('${item['desc']}'),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              },
                            ),
                          ],
                        )
                      : const Text(
                          'Nomor Resi Tidak Ditemukan',
                          style: TextStyle(fontSize: 16),
                        )
                  : const Text(
                      'Belum Ada Data ditemukan',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
