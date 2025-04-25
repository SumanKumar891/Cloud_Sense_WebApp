import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http; // For API requests
import 'package:intl/intl.dart'; // For date formatting

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng centerCoordinates = LatLng(0, 0); // Default center coordinates
  double zoomLevel = 5.0; // Default zoom level
  late MapController mapController; // Declare MapController
  bool isLoading = false; // Track loading state

  List<Map<String, dynamic>> deviceLocations = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> filteredDevices = [];
  List<Map<String, dynamic>> suggestions = [];
  Marker? searchPin;

  // Dropdown and date picker variables
  List<String> deviceIds = [];
  String? selectedDeviceId;
  DateTime? startDate;
  DateTime? endDate;
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');

  // Track previous positions for each device
  Map<String, LatLng> previousPositions = {};
  final double displacementThreshold = 2000.0; // 2 kilometers
  final Distance distance =
      Distance(); // For calculating distance between coordinates

  @override
  void initState() {
    super.initState();
    mapController = MapController(); // Initialize MapController
    _fetchDeviceLocations(); // Fetch all devices on initialization
  }

  Future<void> _fetchDeviceLocations(
      {String? deviceId, DateTime? start, DateTime? end}) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      // Construct API URL
      String url =
          'https://nv9spsjdpe.execute-api.us-east-1.amazonaws.com/default/GPS_API_Data_func';
      if (deviceId != null && start != null && end != null) {
        final String startStr = dateFormatter.format(start);
        final String endStr = dateFormatter.format(end);
        url += '?Device_id=$deviceId&startdate=$startStr&enddate=$endStr';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Group by Device_id and take the most recent record
        Map<String, Map<String, dynamic>> latestDevices = {};

        for (var device in data) {
          String deviceId = device['Device_id'].toString();
          String timestamp = device['Timestamp'].toString();

          if (!latestDevices.containsKey(deviceId) ||
              DateTime.parse(timestamp).isAfter(
                  DateTime.parse(latestDevices[deviceId]!['Timestamp']))) {
            latestDevices[deviceId] = device;
          }
        }

        // Update deviceIds for dropdown if fetching all devices
        if (deviceId == null) {
          deviceIds = latestDevices.keys.toList();
          deviceIds.sort(); // Sort for better UX
        }

        List<Map<String, dynamic>> fetchedDevices = [];
        for (var device in latestDevices.values) {
          String deviceId = device['Device_id'].toString();
          double lat = device['Latitude'] is String
              ? double.parse(device['Latitude'])
              : device['Latitude'];
          double lon = device['Longitude'] is String
              ? double.parse(device['Longitude'])
              : device['Longitude'];
          LatLng currentPosition = LatLng(lat, lon);

          // Check if position has changed
          bool hasMoved = false;
          if (previousPositions.containsKey(deviceId)) {
            double dist = distance.as(
              LengthUnit.Meter,
              previousPositions[deviceId]!,
              currentPosition,
            );
            if (dist >= displacementThreshold) {
              hasMoved = true;
            }
          }

          // Update previous position
          previousPositions[deviceId] = currentPosition;

          // Perform reverse geocoding to get place, state, and country
          final geoData = await _reverseGeocode(lat, lon);

          fetchedDevices.add({
            'name': 'Device: $deviceId',
            'latitude': lat,
            'longitude': lon,
            'place': geoData['place'] ?? 'Unknown',
            'state': geoData['state'] ?? 'Unknown',
            'country': geoData['country'] ?? 'Unknown',
            'last_active': device['Timestamp'].toString(),
            'has_moved': hasMoved, // Track if device has moved
          });
        }

        setState(() {
          deviceLocations = fetchedDevices;
          filteredDevices = fetchedDevices;
          if (fetchedDevices.isNotEmpty) {
            centerCoordinates = LatLng(
              fetchedDevices[0]['latitude'],
              fetchedDevices[0]['longitude'],
            );
            zoomLevel = 12.0; // Adjusted for better initial view
            mapController.move(centerCoordinates, zoomLevel);
          } else {
            // Reset to default if no devices
            centerCoordinates = LatLng(0, 0);
            zoomLevel = 5.0;
            mapController.move(centerCoordinates, zoomLevel);
          }
        });
      } else {
        _showError('Failed to fetch devices: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error fetching devices: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<Map<String, String>> _reverseGeocode(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=18&addressdetails=1';
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'YourAppName/1.0', // Required by Nominatim
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        // Prioritize specific place names for better accuracy
        String place = address['amenity'] ?? // e.g., IIT Ropar
            address['building'] ??
            address['shop'] ??
            address['office'] ??
            address['tourism'] ??
            address['leisure'] ??
            address['suburb'] ??
            address['neighbourhood'] ??
            address['hamlet'] ??
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'] ??
            data['display_name']
                ?.split(',')[0] ?? // Fallback to first part of display_name
            'Unknown';

        return {
          'place': place,
          'state': address['state'] ?? 'Unknown',
          'country': address['country'] ?? 'Unknown',
        };
      } else {
        return {'place': 'Unknown', 'state': 'Unknown', 'country': 'Unknown'};
      }
    } catch (e) {
      return {'place': 'Unknown', 'state': 'Unknown', 'country': 'Unknown'};
    }
  }

  Future<void> _geocode(String query) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json';
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'YourAppName/1.0', // Required by Nominatim
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0]['lat'] != null && data[0]['lon'] != null
              ? {'lat': data[0]['lat'], 'lon': data[0]['lon']}
              : null;

          if (location != null) {
            double lat = double.parse(location['lat']);
            double lon = double.parse(location['lon']);
            LatLng searchCoordinates = LatLng(lat, lon);

            setState(() {
              centerCoordinates = searchCoordinates;
              zoomLevel = 12.0;
              searchPin = Marker(
                width: 80.0,
                height: 80.0,
                point: searchCoordinates,
                builder: (ctx) => Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.blue,
                ),
              );
            });
            mapController.move(searchCoordinates, zoomLevel);
          } else {
            _showError("No coordinates found for '$query'.");
          }
        } else {
          _showError("No results found for '$query'.");
        }
      } else {
        _showError(
            "Failed to fetch location. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      _showError('Error during geocoding: $e');
    }
  }

  void _searchDevices(String query) async {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredDevices = deviceLocations.where((device) {
        return device['place']?.toLowerCase().contains(searchQuery) == true ||
            device['state']?.toLowerCase().contains(searchQuery) == true ||
            device['country']?.toLowerCase().contains(searchQuery) == true ||
            device['name']?.toLowerCase().contains(searchQuery) == true;
      }).toList();
    });

    if (filteredDevices.isEmpty && query.isNotEmpty) {
      await _geocode(query);
    } else if (filteredDevices.isNotEmpty) {
      final device = filteredDevices.first;
      setState(() {
        centerCoordinates = LatLng(device['latitude'], device['longitude']);
        zoomLevel = 12.0;
        searchPin = null;
      });
      mapController.move(centerCoordinates, zoomLevel);
    }
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    setState(() {
      suggestions = deviceLocations
          .where((device) =>
              device['name'].toLowerCase().contains(query.toLowerCase()) ||
              device['place'].toLowerCase().contains(query.toLowerCase()) ||
              device['state'].toLowerCase().contains(query.toLowerCase()) ||
              device['country'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectSuggestion(Map<String, dynamic> suggestion) {
    searchController.text = suggestion['place'];
    _searchDevices(suggestion['place']);
    setState(() {
      suggestions = [];
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Date picker for start and end dates
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        // Trigger API call if all fields are selected
        if (selectedDeviceId != null && startDate != null && endDate != null) {
          _fetchDeviceLocations(
              deviceId: selectedDeviceId, start: startDate, end: endDate);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlue[100],
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: centerCoordinates,
                zoom: zoomLevel,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  backgroundColor: const Color.fromARGB(255, 173, 216, 230),
                ),
                MarkerLayer(
                  markers: [
                    if (searchPin != null) searchPin!,
                    ...deviceLocations.map((device) {
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(
                          device['latitude'],
                          device['longitude'],
                        ),
                        builder: (ctx) => Tooltip(
                          message:
                              '${device['name']}\nLatitude: ${device['latitude'].toStringAsFixed(6)}\nLongitude: ${device['longitude'].toStringAsFixed(6)}\nPlace: ${device['place']}\nState: ${device['state']}\nCountry: ${device['country']}\nLast Active: ${device['last_active']}',
                          child: Icon(
                            Icons.location_pin,
                            size: 40,
                            color: device['has_moved'] == true
                                ? Colors.blue // Displaced devices (≥ 2 km)
                                : Colors.red, // Stationary devices (< 2 km)
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Device Map',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: isLoading
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                )
                              : Icon(Icons.refresh, color: Colors.black),
                          onPressed: isLoading
                              ? null
                              : () =>
                                  _fetchDeviceLocations(), // Reload all devices
                          tooltip: 'Reload Map',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          onChanged: _updateSuggestions,
                          onSubmitted: _searchDevices,
                          decoration: InputDecoration(
                            hintText: 'Search here',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.7)
                                    : Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Device ID Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedDeviceId,
                          hint: Text('Select Device ID'),
                          items: deviceIds.map((String id) {
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(id),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDeviceId = newValue;
                              // Trigger API call if all fields are selected
                              if (selectedDeviceId != null &&
                                  startDate != null &&
                                  endDate != null) {
                                _fetchDeviceLocations(
                                    deviceId: selectedDeviceId,
                                    start: startDate,
                                    end: endDate);
                              }
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.7)
                                    : Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Date Pickers
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                onTap: () => _selectDate(context, true),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.white,
                                  hintText: startDate == null
                                      ? 'Select Start Date'
                                      : dateFormatter.format(startDate!),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                onTap: () => _selectDate(context, false),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.white,
                                  hintText: endDate == null
                                      ? 'Select End Date'
                                      : dateFormatter.format(endDate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (suggestions.isNotEmpty)
                          Container(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.5),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = suggestions[index];
                                return ListTile(
                                  title: Text(suggestion['place']),
                                  subtitle: Text(
                                      '${suggestion['state']}, ${suggestion['country']} - ${suggestion['name']}'),
                                  onTap: () => _selectSuggestion(suggestion),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}
