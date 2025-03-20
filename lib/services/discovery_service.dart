import 'package:flutter/material.dart';
// Uncomment for native platforms:
// import 'package:flutter_nsd/flutter_nsd.dart';
import '../models/device.dart';

class DiscoveryService extends ChangeNotifier {
  // Uncomment for native platforms:
  // final FlutterNsd _nsd = FlutterNsd();
  List<Device> _devices = [];

  DiscoveryService() {
    // Start discovery on initialization for web debugging
    startDiscovery();
  }

  Future<void> startDiscovery() async {
    // Mock discovery for Chrome (web)
    _devices = [
      Device(name: 'Mock WLED 1', ip: '192.168.50.17'),
      Device(name: 'Mock WLED 2', ip: '192.168.50.246'),
    ];
    notifyListeners();

    // Uncomment for native platforms with flutter_nsd:
    /*
    _devices.clear();
    await _nsd.stopDiscovery(); // Ensure no ongoing discovery
    await _nsd.discoverServices('_http._tcp.');
    _nsd.stream.listen((NsdServiceInfo service) async {
      final url = 'http://${service.host}:${service.port}/json';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.containsKey('state') && data.containsKey('info')) {
            final device = Device(
              name: service.name ?? 'WLED Device',
              ip: service.host!,
              port: service.port ?? 80,
            );
            if (!_devices.any((d) => d.ip == device.ip)) {
              _devices.add(device);
              notifyListeners();
            }
          }
        }
      } catch (e) {
        // Handle errors (e.g., not a WLED device)
      }
    });
    */
  }

  List<Device> get devices => _devices;
}