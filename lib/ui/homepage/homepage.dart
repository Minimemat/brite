import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/discovery_service.dart';
import '../control_page/control_page.dart';
import 'device_list.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final discoveryService = Provider.of<DiscoveryService>(context);
    return Scaffold(
      appBar: AppBar(title: Text('WLED Devices')),
      body: DeviceList(devices: discoveryService.devices),
      floatingActionButton: FloatingActionButton(
        onPressed: () => discoveryService.startDiscovery(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}