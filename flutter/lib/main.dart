import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Panel Verileri',
      home: PanelIdGirisEkrani(),
    );
  }
}

// --- 1. Panel ID giriş ekranı ---
class PanelIdGirisEkrani extends StatefulWidget {
  const PanelIdGirisEkrani({super.key});

  @override
  State<PanelIdGirisEkrani> createState() => _PanelIdGirisEkraniState();
}

class _PanelIdGirisEkraniState extends State<PanelIdGirisEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _panelIdController = TextEditingController();
  String? _errorMesaji;

  void _girisYap() {
    final panelId = _panelIdController.text.trim();
    if (panelId == '111') {
      // Geçerli panel ID ise veri ekranına geç
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PanelVeriEkrani(panelId: panelId)),
      );
    } else {
      // Geçersiz panel ID ise uyarı göster
      setState(() {
        _errorMesaji = 'Panel bulunamadı. Lütfen geçerli bir panel ID giriniz.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel ID Girişi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _panelIdController,
                decoration: const InputDecoration(
                  labelText: 'Panel ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Panel ID giriniz' : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _girisYap();
                  }
                },
                child: const Text('Giriş Yap'),
              ),
              if (_errorMesaji != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMesaji!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'solar panel monitoring system.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. Panel veri ekranı ---
class PanelVeriEkrani extends StatefulWidget {
  final String panelId;  // Panel ID bilgisi

  const PanelVeriEkrani({super.key, required this.panelId});

  @override
  State<PanelVeriEkrani> createState() => _PanelVeriEkraniState();
}

class _PanelVeriEkraniState extends State<PanelVeriEkrani> {
  late MqttServerClient client;
  String sicaklik = '-';
  String nem = '-';
  String voltaj = '-';
  String akim = '-';
  String zaman = '-';

  @override
  void initState() {
    super.initState();
    client = MqttServerClient('broker.hivemq.com', '');
    baglantiKur();
  }

  void baglantiKur() async {
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
    client.onDisconnected = () => print('MQTT bağlantısı kesildi');
    client.onConnected = () => print('MQTT bağlantısı kuruldu');
    client.onSubscribed = (String topic) => print('Abone olundu: $topic');

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    try {
      await client.connect();
    } catch (e) {
      print('MQTT bağlantı hatası: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      // Panel ID'ye göre topic abone ol
      client.subscribe('panel/veri', MqttQos.atMostOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        try {
          final veri = json.decode(payload);
          setState(() {
            sicaklik = veri['sicaklik'].toString();
            nem = veri['nem'].toString();
            voltaj = veri['voltaj'].toString();
            akim = veri['akim'].toString();
            zaman = DateTime.now().toLocal().toString().substring(0, 19);
          });
        } catch (e) {
          print("JSON ayrıştırma hatası: $e");
        }
      });
    } else {
      print('MQTT bağlantısı başarısız: ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void cikisYap() {
    client.disconnect(); // MQTT bağlantısını kapat
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PanelIdGirisEkrani()),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Güneş Paneli Verileri - ID: ${widget.panelId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: cikisYap,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            veriKutusu('🌡️ Sıcaklık', '$sicaklik °C'),
            veriKutusu('💧 Nem', '$nem %'),
            veriKutusu('🔋 Voltaj', '$voltaj V'),
            veriKutusu('⚡ Akım', '$akim A'),
            veriKutusu('⏱️ Veri Alım Zamanı', zaman),
          ],
        ),
      ),
    );
  }

  Widget veriKutusu(String baslik, String deger) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(deger, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
