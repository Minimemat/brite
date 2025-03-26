// screens/timers_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../api.dart';
import '../presets_database.dart';
import '../models/device.dart';
import 'dart:convert';

class TimersScreen extends StatefulWidget {
  final Device device;

  const TimersScreen({super.key, required this.device});

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  List<TimerConfig> timers = [];

  @override
  void initState() {
    super.initState();
    _createInitialWLEDPresets();
    _checkTimerExpiration();
  }

  Future<void> _createInitialWLEDPresets() async {
    // Create the "OFF" preset (ID 200)
    await savePreset(
      widget.device.ip,
      200,
      'OFF',
      {
        'on': false,
        'bri': 0,
      },
    );
  }

  void _checkTimerExpiration() {
    final now = DateTime.now();
    for (var timer in timers) {
      final stopDate = DateTime(now.year, timer.stopMonth, timer.stopDay);
      if (now.isAfter(stopDate) && timer.isEnabled) {
        setState(() {
          timer.isEnabled = false;
        });
        _saveTimer(timer);
      }
    }
  }

  Future<void> _saveAllTimers() async {
    for (var timer in timers) {
      await _saveTimer(timer);
    }
  }

  Future<void> _saveTimer(TimerConfig timer) async {
    try {
      print('Saving timer: Slot=${timer.slot}, Enabled=${timer.isEnabled}, Hour=${timer.hour}${timer.isPM ? "PM" : "AM"}, Minute=${timer.minute}, Preset=${timer.preset?.name ?? "OFF"}, Start=${timer.startMonth}/${timer.startDay}, Stop=${timer.stopMonth}/${timer.stopDay}');

      // If the timer is disabled, explicitly disable it on WLED
      if (!timer.isEnabled) {
        await disableTimer(widget.device.ip, timer.slot);
        print('Timer in slot ${timer.slot} disabled on WLED');
        return;
      }

      final now = DateTime.now();
      final startDate = DateTime(now.year, timer.startMonth, timer.startDay);
      final stopDate = DateTime(now.year, timer.stopMonth, timer.stopDay);
      if (now.isBefore(startDate) || now.isAfter(stopDate)) {
        // Timer is not active yet or has expired
        print('Timer not active: Current date ${now.toIso8601String()} is outside range ${startDate.toIso8601String()} to ${stopDate.toIso8601String()}');
        await disableTimer(widget.device.ip, timer.slot);
        return;
      }

      // Determine the preset ID
      int presetId;
      if (timer.isDaily) {
        presetId = 200; // OFF preset for daily turn-off
      } else if (timer.slot == 14) {
        presetId = 209; // Sunrise
      } else if (timer.slot == 15) {
        presetId = 210; // Sunset
      } else {
        presetId = 200 + timer.slot; // 201 for slot 1, 202 for slot 2, etc.
      }

      // Create the preset on WLED if it's not the OFF preset
      if (!timer.isDaily) {
        final presetState = {
          'on': true,
          'bri': 150,
          'seg': [
            {
              'col': timer.preset?.colors?.map((hex) {
                    return hexToRgb(hex);
                  }).toList() ??
                  [[255, 255, 255, 0]], // Default to white if no colors
              'fx': timer.preset?.fx ?? 0,
              'sx': timer.preset?.sx ?? 128,
              'ix': timer.preset?.ix ?? 128,
              'pal': timer.preset?.paletteId ?? 0,
              'c1': timer.preset?.c1 ?? 128,
              'c2': timer.preset?.c2 ?? 128,
              'c3': timer.preset?.c3 ?? 16,
            }
          ],
        };
        await savePreset(widget.device.ip, presetId, timer.preset?.name ?? 'Timer ${timer.slot} Preset', presetState);
        print('Preset $presetId created/overwritten on WLED');
      }

      // Save the timer to WLED
      final timerSettings = {
        'hour': timer.useSunrise ? 'sr' : (timer.useSunset ? 'ss' : (timer.isPM ? (timer.hour == 12 ? 12 : timer.hour + 12) : (timer.hour == 12 ? 0 : timer.hour))),
        'minute': timer.useSunrise || timer.useSunset ? timer.minuteOffset : timer.minute,
        'macro': presetId,
        'enabled': timer.isEnabled,
        'dow': _daysOfWeekToInt(timer.daysOfWeek),
        'month': timer.startMonth,
        'day': timer.startDay,
      };
      await setTimer(widget.device.ip, timer.slot, timerSettings);
      print('Timer in slot ${timer.slot} set on WLED with preset ID $presetId');
    } catch (e) {
      print('Error saving timer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save timer: $e')),
      );
    }
  }

  List<int> hexToRgb(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      try {
        final r = int.parse(hex.substring(0, 2), radix: 16);
        final g = int.parse(hex.substring(2, 4), radix: 16);
        final b = int.parse(hex.substring(4, 6), radix: 16);
        return [r, g, b, 0];
      } catch (e) {
        return [255, 255, 255, 0];
      }
    }
    return [255, 255, 255, 0];
  }

  int _daysOfWeekToInt(List<bool> daysOfWeek) {
    // WLED expects days of week as a single integer (bitmask):
    // Mon=1, Tue=2, Wed=4, Thu=8, Fri=16, Sat=32, Sun=64
    int result = 0;
    if (daysOfWeek[0]) result += 1;  // Mon
    if (daysOfWeek[1]) result += 2;  // Tue
    if (daysOfWeek[2]) result += 4;  // Wed
    if (daysOfWeek[3]) result += 8;  // Thu
    if (daysOfWeek[4]) result += 16; // Fri
    if (daysOfWeek[5]) result += 32; // Sat
    if (daysOfWeek[6]) result += 64; // Sun
    return result;
  }

  void _showAddTimerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTimerDialog(
          onSave: (timer) {
            setState(() {
              // Find the next available slot (1–16, excluding 0 which is for daily turn-off)
              int nextSlot = 1;
              while (timers.any((t) => t.slot == nextSlot) && nextSlot <= 13) {
                nextSlot++;
              }
              if (nextSlot > 13 && !timer.useSunrise && !timer.useSunset) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No more timer slots available (max 14 for regular timers)')),
                );
                return;
              }
              // Ensure only one sunrise (slot 14) and sunset (slot 15)
              if (timer.useSunrise && timers.any((t) => t.slot == 14)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A sunrise timer already exists in slot 14')),
                );
                return;
              }
              if (timer.useSunset && timers.any((t) => t.slot == 15)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('A sunset timer already exists in slot 15')),
                );
                return;
              }
              timer.slot = timer.useSunrise ? 14 : (timer.useSunset ? 15 : nextSlot);
              timers.add(timer);
              _saveTimer(timer);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2526),
      appBar: AppBar(
        title: const Text('Timer Setup'),
        backgroundColor: const Color(0xFF2D3436),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final timer = timers[index];
                return TimerTile(
                  timer: timer,
                  onDelete: () {
                    setState(() {
                      final slot = timer.slot;
                      timers.removeAt(index);
                      disableTimer(widget.device.ip, slot).catchError((e) {
                        print('Error disabling timer on delete: $e');
                      });
                    });
                  },
                  onToggle: (enabled) {
                    setState(() {
                      timer.isEnabled = enabled;
                      _saveTimer(timer);
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddTimerDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Add Timer',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerConfig {
  int slot; // WLED timer slot (1–16, 0 for daily turn-off)
  bool isEnabled;
  int hour; // 1–12 (AM/PM)
  bool isPM; // AM/PM indicator
  int minute;
  Preset? preset; // From PresetDatabase (null for daily turn-off which uses OFF)
  bool useSunrise;
  bool useSunset;
  int minuteOffset;
  List<bool> daysOfWeek; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  int startMonth;
  int startDay;
  int stopMonth;
  int stopDay;
  bool isDaily;

  TimerConfig({
    this.slot = 0,
    this.isEnabled = false,
    this.hour = 1,
    this.isPM = false,
    this.minute = 0,
    this.preset,
    this.useSunrise = false,
    this.useSunset = false,
    this.minuteOffset = 0,
    this.daysOfWeek = const [true, true, true, true, true, true, true],
    this.startMonth = 1,
    this.startDay = 1,
    this.stopMonth = 12,
    this.stopDay = 31,
    this.isDaily = false,
  });
}

class TimerTile extends StatelessWidget {
  final TimerConfig timer;
  final VoidCallback onDelete;
  final Function(bool) onToggle;

  const TimerTile({
    super.key,
    required this.timer,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    String timeText;
    if (timer.useSunrise) {
      timeText = 'Sunrise +${timer.minuteOffset} min';
    } else if (timer.useSunset) {
      timeText = 'Sunset +${timer.minuteOffset} min';
    } else {
      timeText = '${timer.hour}:${timer.minute.toString().padLeft(2, '0')} ${timer.isPM ? 'PM' : 'AM'}';
    }

    String daysText = '';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 0; i < 7; i++) {
      if (timer.daysOfWeek[i]) {
        daysText += days[i] + ' ';
      }
    }

    return Card(
      color: const Color(0xFF2D3436),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: timer.isEnabled,
          activeColor: Colors.blue,
          onChanged: (value) => onToggle(value ?? false),
        ),
        title: Text(
          timer.isDaily ? 'Daily Turn-Off' : 'Timer ${timer.slot}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          'Time: $timeText\nDays: $daysText\nStart: ${timer.startMonth}/${timer.startDay}\nStop: ${timer.stopMonth}/${timer.stopDay}\nPreset: ${timer.preset?.name ?? "OFF"}',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white70),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class AddTimerDialog extends StatefulWidget {
  final Function(TimerConfig) onSave;

  const AddTimerDialog({super.key, required this.onSave});

  @override
  State<AddTimerDialog> createState() => _AddTimerDialogState();
}

class _AddTimerDialogState extends State<AddTimerDialog> {
  int hour = 1;
  bool isPM = false;
  int minute = 0;
  Preset? selectedPreset;
  bool useSunrise = false;
  bool useSunset = false;
  int minuteOffset = 0;
  List<bool> daysOfWeek = [true, true, true, true, true, true, true];
  int startMonth = 1;
  int startDay = 1;
  int stopMonth = 12;
  int stopDay = 31;

  @override
  void initState() {
    super.initState();
    selectedPreset = PresetDatabase.presets.isNotEmpty ? PresetDatabase.presets[0] : null;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025, startMonth, startDay),
      firstDate: DateTime(2025),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF2D3436),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2D3436),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        startMonth = picked.month;
        startDay = picked.day;
      });
    }
  }

  Future<void> _selectStopDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025, stopMonth, stopDay),
      firstDate: DateTime(2025),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF2D3436),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2D3436),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        stopMonth = picked.month;
        stopDay = picked.day;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2D3436),
      title: const Text('Add Timer', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Selection
            Row(
              children: [
                Checkbox(
                  value: useSunrise,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      useSunrise = value ?? false;
                      if (value == true) {
                        useSunset = false;
                      }
                    });
                  },
                ),
                const Text('Sunrise', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 16),
                Checkbox(
                  value: useSunset,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      useSunset = value ?? false;
                      if (value == true) {
                        useSunrise = false;
                      }
                    });
                  },
                ),
                const Text('Sunset', style: TextStyle(color: Colors.white)),
              ],
            ),
            if (useSunrise || useSunset) ...[
              const Text('Offset (min)', style: TextStyle(color: Colors.white70)),
              DropdownButton<int>(
                value: minuteOffset,
                dropdownColor: const Color(0xFF2D3436),
                items: List.generate(61, (index) => index).map((offset) {
                  return DropdownMenuItem<int>(
                    value: offset,
                    child: Text(
                      offset.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    minuteOffset = value ?? 0;
                  });
                },
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hour', style: TextStyle(color: Colors.white70)),
                      DropdownButton<int>(
                        value: hour,
                        dropdownColor: const Color(0xFF2D3436),
                        items: List.generate(12, (index) => index + 1).map((h) {
                          return DropdownMenuItem<int>(
                            value: h,
                            child: Text(
                              h.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            hour = value ?? 1;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AM/PM', style: TextStyle(color: Colors.white70)),
                      DropdownButton<bool>(
                        value: isPM,
                        dropdownColor: const Color(0xFF2D3436),
                        items: const [
                          DropdownMenuItem(value: false, child: Text('AM', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: true, child: Text('PM', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            isPM = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Minute', style: TextStyle(color: Colors.white70)),
                      DropdownButton<int>(
                        value: minute,
                        dropdownColor: const Color(0xFF2D3436),
                        items: List.generate(60, (index) => index).map((m) {
                          return DropdownMenuItem<int>(
                            value: m,
                            child: Text(
                              m.toString().padLeft(2, '0'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            minute = value ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Days of the Week
            const Text('Days of the Week', style: TextStyle(color: Colors.white70)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < 7; i++)
                  Column(
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Checkbox(
                        value: daysOfWeek[i],
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            daysOfWeek[i] = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
            if (!useSunrise && !useSunset) ...[
              const SizedBox(height: 16),
              // Start Date
              const Text('Start Date', style: TextStyle(color: Colors.white70)),
              Row(
                children: [
                  Text(
                    'Month: $startMonth, Day: $startDay',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white70),
                    onPressed: () => _selectStartDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stop Date
              const Text('Stop Date', style: TextStyle(color: Colors.white70)),
              Row(
                children: [
                  Text(
                    'Month: $stopMonth, Day: $stopDay',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white70),
                    onPressed: () => _selectStopDate(context),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Preset Selection
            const Text('Preset', style: TextStyle(color: Colors.white70)),
            DropdownButton<Preset>(
              value: selectedPreset,
              dropdownColor: const Color(0xFF2D3436),
              items: PresetDatabase.presets.map((preset) {
                return DropdownMenuItem<Preset>(
                  value: preset,
                  child: Text(
                    preset.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPreset = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () {
            final newTimer = TimerConfig(
              isEnabled: true,
              hour: hour,
              isPM: isPM,
              minute: minute,
              preset: selectedPreset,
              useSunrise: useSunrise,
              useSunset: useSunset,
              minuteOffset: minuteOffset,
              daysOfWeek: daysOfWeek,
              startMonth: useSunrise || useSunset ? 1 : startMonth, // Default to 1/1 if sunrise/sunset
              startDay: useSunrise || useSunset ? 1 : startDay,
              stopMonth: useSunrise || useSunset ? 12 : stopMonth,
              stopDay: useSunrise || useSunset ? 31 : stopDay,
            );
            widget.onSave(newTimer);
            Navigator.pop(context);
          },
          child: const Text('Save', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}