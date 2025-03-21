import 'package:flutter/material.dart';

class Device {
  String name; // Removed 'final' to make mutable
  String ip;   // Removed 'final' to make mutable
  bool isOn;
  double brightness;
  bool isSynced;
  Color? backgroundColor;

  Device({
    required this.name,
    required this.ip,
    this.isOn = false,
    this.brightness = 100.0,
    this.isSynced = true,
    this.backgroundColor,
  });
}