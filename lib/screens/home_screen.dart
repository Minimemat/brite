import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';
import '../api.dart';
import 'device_card.dart';
import 'web_view.dart';
import 'presets_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Device> devices = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadDevices(); // Load saved devices on startup
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _syncDevices());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Load devices from shared preferences
  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? devicesJson = prefs.getString('devices');
    if (devicesJson != null) {
      final List<dynamic> devicesList = jsonDecode(devicesJson);
      setState(() {
        devices = devicesList
            .map((json) => Device(
                  name: json['name'],
                  ip: json['ip'],
                  isOn: json['isOn'] ?? false,
                  brightness: (json['brightness'] ?? 100).toDouble(),
                  isSynced: json['isSynced'] ?? true,
                ))
            .toList();
      });
    } else {
      // Default devices if none are saved
      setState(() {
        devices = [
          Device(name: 'Home', ip: '192.168.50.246'),
          Device(name: 'Test Device', ip: '192.168.50.17'),
        ];
      });
      _saveDevices(); // Save the default devices
    }
    _syncDevices();
  }

  // Save devices to shared preferences
  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devicesJson = jsonEncode(devices.map((device) => {
          'name': device.name,
          'ip': device.ip,
          'isOn': device.isOn,
          'brightness': device.brightness,
          'isSynced': device.isSynced,
        }).toList());
    await prefs.setString('devices', devicesJson);
  }

  Future<void> _syncDevices() async {
    List<Device> syncedDevices = [];
    List<Device> unsyncedDevices = [];

    for (var device in devices) {
      try {
        final state = await getState(device.ip);
        print('Device ${device.name} state: $state'); // Debug log
        setState(() {
          device.isOn = state['on'] ?? false;
          device.brightness = (state['bri'] ?? 100).toDouble();
          device.isSynced = true;
          device.backgroundColor = extractFirstColor(state);
          print('Device ${device.name} color: ${device.backgroundColor}'); // Debug log
        });
        syncedDevices.add(device);
      } catch (e) {
        print('Failed to sync device ${device.name}: $e'); // Debug log
        setState(() {
          device.isSynced = false;
          device.backgroundColor = null;
        });
        unsyncedDevices.add(device);
      }
    }
    setState(() {
      devices = [...syncedDevices, ...unsyncedDevices];
    });
    await _saveDevices(); // Save after syncing
  }

  Future<void> _togglePower(Device device, bool value) async {
    try {
      await setPower(device.ip, value);
      await _syncDevice(device);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle power: $e')),
      );
    }
  }

  Future<void> _setBrightness(Device device, double value) async {
    try {
      await setBrightness(device.ip, value.round());
      await _syncDevice(device);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set brightness: $e')),
      );
    }
  }

  Future<void> _syncDevice(Device device) async {
    try {
      final state = await getState(device.ip);
      print('Device ${device.name} state (syncDevice): $state'); // Debug log
      setState(() {
        device.isOn = state['on'] ?? false;
        device.brightness = (state['bri'] ?? 100).toDouble();
        device.isSynced = true;
        device.backgroundColor = extractFirstColor(state);
        print('Device ${device.name} color (syncDevice): ${device.backgroundColor}'); // Debug log
      });
    } catch (e) {
      print('Failed to sync device ${device.name} (syncDevice): $e'); // Debug log
      setState(() {
        device.isSynced = false;
        device.backgroundColor = null;
      });
    }
    await _saveDevices(); // Save after syncing a single device
  }

  void _updateBrightness(Device device, double value) {
    setState(() {
      device.brightness = value;
    });
  }

  void _addDevice(String name, String ip) {
    setState(() {
      devices.insert(0, Device(name: name, ip: ip));
    });
    _saveDevices();
    _syncDevices();
  }

  void _updateDevice(Device device, String newName, String newIp) {
    setState(() {
      device.name = newName;
      device.ip = newIp;
    });
    _saveDevices();
    _syncDevices();
  }

  void _deleteDevice(Device device) {
    setState(() {
      devices.remove(device);
    });
    _saveDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brite', textAlign: TextAlign.center),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDeviceDialog(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text('Brite', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            ListTile(
              title: const Text('Add a new device'),
              onTap: () {
                Navigator.pop(context);
                _showAddDeviceDialog(context);
              },
            ),
            ListTile(
              title: const Text('Manage Devices'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageDevicesScreen(
                      devices: devices,
                      onUpdateDevice: _updateDevice,
                      onDeleteDevice: _deleteDevice,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _syncDevices,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return DeviceCard(
                    device: device,
                    onTogglePower: (value) => _togglePower(device, value),
                    onUpdateBrightness: (value) => _updateBrightness(device, value),
                    onSetBrightness: (value) => _setBrightness(device, value),
                    onOpenWebView: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(device: device),
                        ),
                      );
                    },
                    onOpenPresets: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PresetsScreen(device: device),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    String name = '';
    String ip = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'IP Address'),
              onChanged: (value) => ip = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty && ip.isNotEmpty) {
                _addDevice(name, ip);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Manage Devices Screen
class ManageDevicesScreen extends StatelessWidget {
  final List<Device> devices;
  final Function(Device, String, String) onUpdateDevice;
  final Function(Device) onDeleteDevice;

  const ManageDevicesScreen({
    super.key,
    required this.devices,
    required this.onUpdateDevice,
    required this.onDeleteDevice,
  });

  void _showEditDeviceDialog(BuildContext context, Device device) {
    String newName = device.name;
    String newIp = device.ip;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              controller: TextEditingController(text: device.name),
              onChanged: (value) => newName = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'IP Address'),
              controller: TextEditingController(text: device.ip),
              onChanged: (value) => newIp = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newName.isNotEmpty && newIp.isNotEmpty) {
                onUpdateDevice(device, newName, newIp);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDevice(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDeleteDevice(device);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Devices'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.ip),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDeviceDialog(context, device),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteDevice(context, device),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}