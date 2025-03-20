import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../control_page/control_page.dart';

class DeviceList extends StatelessWidget {
  final List<Device> devices;

  DeviceList({required this.devices});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(device.name),
            subtitle: Text(device.ip),
            trailing: Icon(Icons.circle, color: Colors.green), // Mock online status
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ControlPage(device: device),
                ),
              );
            },
          ),
        );
      },
    );
  }
}