import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

final bluetoothServiceProvider = Provider((ref) => BluetoothService());

class BluetoothService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  Future<bool> connect() async {
    try {
      final isAvailable = await FlutterWebBluetooth.instance.isAvailable.first;
      if (!isAvailable) {
        print('Web Bluetooth not available');
        return false;
      }

      final device = await FlutterWebBluetooth.instance.requestDevice(
        RequestOptionsBuilder(
          [
            RequestFilterBuilder(
              services: [
                '000018f0-0000-1000-8000-00805f9b34fb', 
                'e7810a71-73ae-499d-8c15-faa9aef0c3f2',
              ],
            ),
          ],
          optionalServices: [
             '000018f0-0000-1000-8000-00805f9b34fb',
             'e7810a71-73ae-499d-8c15-faa9aef0c3f2'
          ], 
        ),
      );

      await device.connect();
      _device = device;
      
      // Discover services
      // We need to find a characteristic to write to.
      // Usually it's a Write or WriteWithoutResponse characteristic.
      // This part is tricky without knowing the exact printer model.
      // We'll iterate to find a writable characteristic.
      
      final services = await device.discoverServices();
      for (var service in services) {
        final characteristics = await service.getCharacteristics();
        for (var c in characteristics) {
          if (c.properties.write || c.properties.writeWithoutResponse) {
            _characteristic = c;
            break;
          }
        }
        if (_characteristic != null) break;
      }

      if (_characteristic != null) {
        _connectionStatusController.add(true);
        return true;
      } else {
        print('No writable characteristic found');
        device.disconnect();
        return false;
      }
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }

  Future<void> printData(List<int> data) async {
    if (_device != null && _characteristic != null) {
      try {
        // Chunk data if needed (max 512 bytes usually, but safer to do 20)
        // Web Bluetooth often handles larger chunks but some devices fail.
        // Let's send in chunks of 512.
        final Uint8List bytes = Uint8List.fromList(data);
        const int chunkSize = 512;
        
        for (int i = 0; i < bytes.length; i += chunkSize) {
          int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
          final chunk = bytes.sublist(i, end);
          
          if (_characteristic!.properties.writeWithoutResponse) {
             await _characteristic!.writeValueWithoutResponse(chunk);
          } else {
             await _characteristic!.writeValueWithResponse(chunk);
          }
        }
      } catch (e) {
        print('Print failed: $e');
      }
    } else {
      print('Printer not connected. Mock Print: $data');
    }
  }

  void disconnect() {
    _device?.disconnect();
    _device = null;
    _characteristic = null;
    _connectionStatusController.add(false);
  }
}
