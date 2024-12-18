import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? connectedDevice;
  bool isLedOn = false; 

  @override
  void initState() {
    super.initState();
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == "MeuDispositivoIoT") {
          connectedDevice = result.device;
          _connectToDevice();
          break;
        }
      }
    });
  }

  Future<void> _connectToDevice() async {
    await connectedDevice!.connect();

    const guidService = "your_service_uuid"; 
    const guidCharacteristic = "your_characteristic_uuid"; 

    var services = await connectedDevice!.discoverServices();
    for (var service in services) {
      var characteristics = service.characteristics;
      for (var characteristic in characteristics) {
        if (characteristic.uuid.toString() == guidCharacteristic) {
          _writeLedState(characteristic); 
          break;
        }
      }
    }
  }

  void _writeLedState(BluetoothCharacteristic characteristic) async {
    List<int> data = [isLedOn ? 1 : 0]; 
    await characteristic.write(data);
  }

  void _toggleLED() async {
    isLedOn = !isLedOn;
    if (connectedDevice != null) {
      _writeLedState(await _findLedCharacteristic()); 
    }
    setState(() {}); 
  }

  Future<BluetoothCharacteristic> _findLedCharacteristic() async {
    const guidService = "your_service_uuid"; 
    const guidCharacteristic = "your_characteristic_uuid"; 

    var services = await connectedDevice!.discoverServices();
    for (var service in services) {
      var characteristics = service.characteristics;
      for (var characteristic in characteristics) {
        if (characteristic.uuid.toString() == guidCharacteristic) {
          return characteristic;
        }
      }
    }
    throw Exception("Characteristic not found"); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle IoT'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleLED,
          child: Text(isLedOn ? 'Desligar LED' : 'Ligar LED'),
        ),
      ),
    );
  }
}
