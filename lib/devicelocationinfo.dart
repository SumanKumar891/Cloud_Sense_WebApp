import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_sense_webapp/devicemap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeviceActivityPage extends StatefulWidget {
  const DeviceActivityPage({super.key});

  @override
  State<DeviceActivityPage> createState() => _DeviceActivityPageState();
}

class _DeviceActivityPageState extends State<DeviceActivityPage> {
  final String apiUrl =
      "https://xa9ry8sls0.execute-api.us-east-1.amazonaws.com/CloudSense_device_activity_api_function";

  bool isLoading = true;
  bool showList = true; // New toggle variable
  List<Map<String, dynamic>> allDevices = [];
  int totalActive = 0;
  int totalInactive = 0;

  String? filter = "All"; // Default to show all devices

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, dynamic>> devices = [];

        // Merge selected groups
        final keysToInclude = [
          'WS_Device_Activity',
          'Awadh_Jio_Device_Activity',
          'weather_Device_Activity',
        ];

        for (var key in keysToInclude) {
          if (data[key] != null) {
            for (var device in data[key]) {
              DateTime? lastTime = parseDate(device['lastReceivedTime']);
              bool isActive = false;

              if (lastTime != null) {
                final diff = DateTime.now().difference(lastTime);
                isActive = diff.inHours <= 24;
              }

              devices.add({
                "DeviceId": device['DeviceId'],
                "lastReceivedTime": lastTime?.toString() ?? "Invalid date",
                "isActive": isActive,
                "Group": key,
                // Add Topic only if WS_Device_Activity has it
                "Topic":
                    key == "WS_Device_Activity" ? device['Topic'] ?? "" : null
              });
            }
          }
        }
        // Sort devices: Active first
        devices.sort((a, b) {
          if (a['isActive'] == b['isActive']) return 0;
          return a['isActive'] ? -1 : 1;
        });

        int activeCount = devices.where((d) => d['isActive']).length;
        int inactiveCount = devices.length - activeCount;

        setState(() {
          allDevices = devices;
          totalActive = activeCount;
          totalInactive = inactiveCount;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  DateTime? parseDate(String dateStr) {
    try {
      // 1. Handle compact format: 20250731T101428
      final compactRegex = RegExp(r'^\d{8}T\d{6}$');
      if (compactRegex.hasMatch(dateStr)) {
        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = int.parse(dateStr.substring(6, 8));
        final hour = int.parse(dateStr.substring(9, 11));
        final minute = int.parse(dateStr.substring(11, 13));
        final second = int.parse(dateStr.substring(13, 15));
        return DateTime(year, month, day, hour, minute, second);
      }

      // 2. Handle format: DD-MM-YYYY HH:mm:ss (01-08-2025 16:01:28)
      final dmyRegex = RegExp(r'^\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}$');
      if (dmyRegex.hasMatch(dateStr)) {
        final parts = dateStr.split(' ');
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');

        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = int.parse(timeParts[2]);

        return DateTime(year, month, day, hour, minute, second);
      }

      // 3. Handle format: 2024-09-24 04:28 PM (12-hour format with AM/PM)
      final amPmRegex = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2} (AM|PM)$');
      if (amPmRegex.hasMatch(dateStr)) {
        // Using intl is better, but here we'll handle manually
        final isPm = dateStr.endsWith('PM');
        final base = dateStr.replaceAll(RegExp(r' (AM|PM)$'), '');
        final dateTimeParts = base.split(' ');
        final date = dateTimeParts[0];
        final time = dateTimeParts[1];
        final dateParts = date.split('-');
        final timeParts = time.split(':');

        int hour = int.parse(timeParts[0]);
        if (isPm && hour < 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;

        return DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          hour,
          int.parse(timeParts[1]),
        );
      }

      // 4. Fallback for standard ISO and space-separated formats
      return DateTime.tryParse(dateStr.replaceAll('  ', ' '));
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> get filteredDevices {
    if (filter == "Active") {
      return allDevices.where((d) => d['isActive']).toList();
    } else if (filter == "Inactive") {
      return allDevices.where((d) => !d['isActive']).toList();
    } else if (filter == "All") {
      return allDevices;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[200] : Colors.blueGrey[900],
        title: Text('Device Status',
            style: TextStyle(color: isDarkMode ? Colors.black : Colors.white)),
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.black : Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,
                color: isDarkMode ? Colors.black : Colors.white),
            onPressed: fetchDevices, // reload data
          ),
          IconButton(
            icon: Icon(Icons.map,
                color: isDarkMode ? Colors.black : Colors.white),
            tooltip: 'Open Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DeviceMapScreen()), // map.dart widget
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchDevices,
              child: Column(
                children: [
                  // Header with total count and counts
                  Container(
                    color: isDarkMode ? Colors.blueGrey[900] : Colors.grey[200],
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          "Total Devices: ${allDevices.length}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Active: $totalActive",
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.green[300]
                                    : Colors.green,
                              ),
                            ),
                            Text(
                              "Inactive: $totalInactive",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.red[300] : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Dropdown filter
                        DropdownButton<String>(
                          dropdownColor:
                              isDarkMode ? Colors.grey[900] : Colors.white,
                          hint: Text(
                            "Select Device Type",
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white70 : Colors.black),
                          ),
                          value: filter,
                          items: const [
                            DropdownMenuItem(
                                value: "All", child: Text("All Devices")),
                            DropdownMenuItem(
                                value: "Active", child: Text("Active Devices")),
                            DropdownMenuItem(
                                value: "Inactive",
                                child: Text("Inactive Devices")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              if (value == "Clear") {
                                filter = null;
                                showList = false;
                              } else if (value == filter) {
                                // toggle if same option is selected again
                                showList = !showList;
                              } else {
                                filter = value;
                                showList = true;
                              }
                            });
                          },
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        AnimatedTextKit(
                          onTap: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          repeatForever: true,
                          pause: const Duration(milliseconds: 2000),
                          animatedTexts: [
                            TyperAnimatedText(
                              'To see your device data, login/signup',
                              textStyle: TextStyle(
                                fontSize: 16, // font size
                                color: isDarkMode
                                    ? Colors.deepOrange
                                    : Colors.deepOrange, // font color
                                fontWeight: FontWeight.bold, // optional
                              ),
                            ),
                          ],
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                        ),
                      ],
                    ),
                  ),
                  // Show list only if toggle is true
                  Expanded(
                    child: (!showList || filter == null)
                        ? const Center()
                        : filteredDevices.isEmpty
                            ? const Center(child: Text("No devices found"))
                            : ListView.builder(
                                itemCount: filteredDevices.length,
                                itemBuilder: (context, index) {
                                  final device = filteredDevices[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: ListTile(
                                      leading: Icon(Icons.devices,
                                          color: device['isActive']
                                              ? Colors.green
                                              : Colors.red),
                                      title: Text(
                                          "Device ID: ${device['DeviceId']}"),
                                      subtitle: Text(
                                        "Last Received: ${device['lastReceivedTime']}"
                                        // "\nGroup: ${device['Group']
                                        // }"
                                        "${device['Topic'] != null && device['Topic'] != '' ? '\nTopic: ${device['Topic']}' : ''}",
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(context, "/login");
                                      },
                                    ),
                                  );
                                },
                              ),
                  )
                ],
              ),
            ),
    );
  }
}
