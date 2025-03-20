class Device {
  final String name;
  final String ip;
  final int port;

  Device({
    required this.name,
    required this.ip,
    this.port = 80, // Default HTTP port
  });

  String get baseUrl => 'http://$ip:$port';
}