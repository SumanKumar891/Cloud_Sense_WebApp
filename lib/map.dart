import 'dart:convert';
import 'package:cloud_sense_webapp/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' show Distance;
import 'package:provider/provider.dart';
import 'package:cloud_sense_webapp/main.dart'; // Import main.dart for ThemeProvider

enum MapType { defaultMap, satellite, terrain }

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

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

  // Track previous positions for each device (persistent)
  Map<String, Map<String, dynamic>> previousPositions = {};
  final double displacementThreshold = 200.0; // 200 meters
  final Distance distance =
      Distance(); // For calculating distance between coordinates
  final int stationaryTimeThreshold = 5 * 60 * 1000; // 5 minutes

  // SharedPreferences key for storing positions
  static const String POSITIONS_KEY = 'device_previous_positions';

  // State for map type
  MapType currentMapType = MapType.defaultMap; // Default map type

  @override
  void initState() {
    super.initState();
    mapController = MapController(); // Initialize MapController
    _loadPreviousPositions(); // Load stored positions first
  }

  // Load previous positions from SharedPreferences
  Future<void> _loadPreviousPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storedData = prefs.getString(POSITIONS_KEY);

      if (storedData != null) {
        final Map<String, dynamic> decodedData = json.decode(storedData);
        previousPositions = decodedData.map((key, value) => MapEntry(
              key,
              Map<String, dynamic>.from(value),
            ));
        print(
            'Loaded ${previousPositions.length} previous positions from storage');
      }
    } catch (e) {
      print('Error loading previous positions: $e');
      previousPositions = {};
    }

    // Fetch device locations after loading previous positions
    _fetchDeviceLocations();
  }

  // Save previous positions to SharedPreferences
  Future<void> _savePreviousPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(previousPositions);
      await prefs.setString(POSITIONS_KEY, encodedData);
      print('Saved ${previousPositions.length} positions to storage');
    } catch (e) {
      print('Error saving previous positions: $e');
    }
  }

  // Helper method to truncate a number to 3 decimal places
  double _truncateToThreeDecimals(double value) {
    String valueStr = value.toString();
    List<String> parts = valueStr.split('.');
    if (parts.length < 2) return value; // No decimal part
    String integerPart = parts[0];
    String decimalPart =
        parts[1].length > 3 ? parts[1].substring(0, 3) : parts[1];
    return double.parse('$integerPart.$decimalPart');
  }

  Future<void> _fetchDeviceLocations(
      {String? deviceId, DateTime? start, DateTime? end}) async {
    setState(() {
      isLoading = true;
      searchPin = null; // Clear search pin on reload
    });

    try {
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
        if (data.isEmpty) {
          print('No new data returned from API');
          setState(() {
            isLoading = false;
          });
          return; // Exit early if no data
        }

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

        if (deviceId == null) {
          deviceIds = latestDevices.keys.toList();
          deviceIds.sort();
          if (!deviceIds.contains('None')) {
            deviceIds.insert(0, 'None');
          }
        }

        List<Map<String, dynamic>> fetchedDevices = [];
        bool positionsUpdated = false;

        for (var device in latestDevices.values) {
          String deviceId = device['Device_id'].toString();
          double lat = device['Latitude'] is String
              ? _truncateToThreeDecimals(double.parse(device['Latitude']))
              : _truncateToThreeDecimals(device['Latitude']);
          double lon = device['Longitude'] is String
              ? _truncateToThreeDecimals(double.parse(device['Longitude']))
              : _truncateToThreeDecimals(device['Longitude']);
          LatLng currentPosition = LatLng(lat, lon);
          String currentTimestamp = device['Timestamp'].toString();

          bool hasMoved = false;
          bool shouldUpdatePosition = false;

          if (previousPositions.containsKey(deviceId)) {
            final prevData = previousPositions[deviceId]!;
            final LatLng prevPosition = LatLng(
              prevData['latitude'],
              prevData['longitude'],
            );
            final String prevTimestamp = prevData['timestamp'];
            final String? lastMovedTimestamp = prevData['last_moved_timestamp'];

            if (currentTimestamp == prevTimestamp) {
              print('No new timestamp for device $deviceId, skipping update');
              fetchedDevices.add({
                'name': 'Device: $deviceId',
                'latitude': lat,
                'longitude': lon,
                'place': prevData['place'] ?? 'Unknown',
                'state': prevData['state'] ?? 'Unknown',
                'country': prevData['country'] ?? 'Unknown',
                'last_active': currentTimestamp,
                'has_moved': prevData['has_moved'] ?? false,
              });
              continue;
            }

            double dist = distance.as(
              LengthUnit.Meter,
              prevPosition,
              currentPosition,
            );

            if (dist >= displacementThreshold) {
              hasMoved = true;
              shouldUpdatePosition = true;
              print(
                  'Device $deviceId moved ${dist.toStringAsFixed(2)}m (>200m threshold)');
            } else if (DateTime.parse(currentTimestamp)
                .isAfter(DateTime.parse(prevTimestamp))) {
              shouldUpdatePosition = true;
              if (lastMovedTimestamp != null) {
                try {
                  final currentTime = DateTime.parse(currentTimestamp);
                  final lastMovedTime = DateTime.parse(lastMovedTimestamp);
                  final timeDiff =
                      currentTime.difference(lastMovedTime).inMilliseconds;
                  if (timeDiff >= stationaryTimeThreshold) {
                    hasMoved = false;
                    print(
                        'Device $deviceId stationary for ${timeDiff / 1000 / 60} minutes, setting to green');
                  } else {
                    hasMoved = prevData['has_moved'] ?? false;
                    print(
                        'Device $deviceId stationary for ${timeDiff / 1000 / 60} minutes, not yet 5 minutes');
                  }
                } catch (e) {
                  print('Error parsing timestamps for device $deviceId: $e');
                }
              }
            }
          } else {
            shouldUpdatePosition = true;
            print('First time tracking device $deviceId');
          }

          if (shouldUpdatePosition) {
            final geoData = await _reverseGeocode(lat, lon);
            previousPositions[deviceId] = {
              'latitude': lat,
              'longitude': lon,
              'timestamp': currentTimestamp,
              'last_moved_timestamp': hasMoved
                  ? currentTimestamp
                  : previousPositions[deviceId]?['last_moved_timestamp'] ??
                      currentTimestamp,
              'has_moved': hasMoved,
              'place': geoData['place'],
              'state': geoData['state'],
              'country': geoData['country'],
            };
            positionsUpdated = true;
          }

          final geoData = previousPositions[deviceId] != null
              ? {
                  'place': previousPositions[deviceId]!['place'] ?? 'Unknown',
                  'state': previousPositions[deviceId]!['state'] ?? 'Unknown',
                  'country':
                      previousPositions[deviceId]!['country'] ?? 'Unknown',
                }
              : await _reverseGeocode(lat, lon);

          fetchedDevices.add({
            'name': 'Device: $deviceId',
            'latitude': lat,
            'longitude': lon,
            'place': geoData['place'] ?? 'Unknown',
            'state': geoData['state'] ?? 'Unknown',
            'country': geoData['country'] ?? 'Unknown',
            'last_active': currentTimestamp,
            'has_moved': hasMoved,
          });
        }

        if (positionsUpdated) {
          await _savePreviousPositions();
        }

        setState(() {
          deviceLocations = fetchedDevices;
          filteredDevices = fetchedDevices;
          if (fetchedDevices.isNotEmpty) {
            centerCoordinates = LatLng(
                fetchedDevices[0]['latitude'], fetchedDevices[0]['longitude']);
            zoomLevel = 12.0;
            mapController.move(centerCoordinates, zoomLevel);
          } else {
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
        isLoading = false;
      });
    }
  }

  // Method to manually clear stored positions (for testing/debugging)
  Future<void> _clearStoredPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(POSITIONS_KEY);
      previousPositions.clear();
      print('Cleared all stored positions');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cleared stored device positions')),
      );

      _fetchDeviceLocations();
    } catch (e) {
      print('Error clearing positions: $e');
    }
  }

  Future<Map<String, String>> _reverseGeocode(double lat, double lon) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=18&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'CloudSenseApp/1.0 (contact@example.com)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        String place = address['amenity'] ??
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
            data['display_name']?.split(',')[0] ??
            'Unknown';

        return {
          'place': place,
          'state': address['state'] ?? 'Unknown',
          'country': address['country'] ?? 'Unknown',
        };
      } else {
        print('Reverse geocoding failed: ${response.statusCode}');
        return {'place': 'Unknown', 'state': 'Unknown', 'country': 'Unknown'};
      }
    } catch (e) {
      print('Error during reverse geocoding: $e');
      return {'place': 'Unknown', 'state': 'Unknown', 'country': 'Unknown'};
    }
  }

  Future<void> _geocode(String query) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'CloudSenseApp/1.0 (contact@example.com)'},
      );

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
                  color: Colors.red,
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
      if (query.isEmpty) {
        searchPin = null; // Clear search pin when search query is empty
      }
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
        searchPin = null; // Clear search pin when suggestions are cleared
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
        if (selectedDeviceId != null && startDate != null && endDate != null) {
          _fetchDeviceLocations(
              deviceId: selectedDeviceId, start: startDate, end: endDate);
        }
      });
    }
  }

  void _showDeviceInfoDialog(
    BuildContext context,
    String name,
    double latitude,
    double longitude,
    String place,
    String state,
    String country,
    String lastActive,
    bool hasMoved,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Latitude: ${latitude.toStringAsFixed(3)}',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Longitude: ${longitude.toStringAsFixed(3)}',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Place: $place',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'State: $state',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Country: $country',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Last Active: $lastActive',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Status: ${hasMoved ? "Moved (>200m)" : "Stationary (<200m or >5min)"}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasMoved ? Colors.blue : Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to get the appropriate TileLayer based on map type and theme
  TileLayer _getTileLayer() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    String urlTemplate;
    Color backgroundColor;

    switch (currentMapType) {
      case MapType.defaultMap:
        urlTemplate = isDarkMode
            ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
            : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
        backgroundColor = isDarkMode
            ? const Color(0xFF1A2A44) // Dark blue for dark mode
            : const Color.fromARGB(255, 173, 216, 230); // Light mode background
        break;
      case MapType.satellite:
        urlTemplate =
            'https://tiles.stadiamaps.com/tiles/alidade_satellite/{z}/{x}/{y}{r}.png';
        backgroundColor = isDarkMode
            ? const Color(0xFF1A2A44)
            : const Color.fromARGB(255, 173, 216, 230);
        break;
      case MapType.terrain:
        urlTemplate =
            'https://tiles.stadiamaps.com/tiles/stamen_terrain/{z}/{x}/{y}{r}.png';
        backgroundColor = isDarkMode
            ? const Color(0xFF1A2A44)
            : const Color.fromARGB(255, 173, 216, 230);
        break;
    }

    return TileLayer(
      urlTemplate: urlTemplate,
      subdomains: currentMapType == MapType.defaultMap && !isDarkMode
          ? ['a', 'b', 'c']
          : [],
      backgroundColor: backgroundColor,
      maxZoom: 19.0,
      minZoom: 2.0,
      errorTileCallback: (tile, error, stackTrace) {
        print('Tile failed to load: $error');
      },
    );
  }

  // Method to handle map type selection
  void _toggleMapType(MapType type) {
    setState(() {
      currentMapType = type;
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content:
      //           Text('Switched to ${type.toString().split('.').last} Map')),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        color: themeProvider.isDarkMode
            ? const Color(0xFF1A2A44)
            : Colors.lightBlue[100],
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: centerCoordinates,
                zoom: zoomLevel,
                minZoom: 2.0,
                maxZoom: 19.0,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                keepAlive: true,
              ),
              children: [
                _getTileLayer(),
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
                        builder: (ctx) => GestureDetector(
                          onTap: () {
                            _showDeviceInfoDialog(
                              context,
                              device['name'],
                              device['latitude'],
                              device['longitude'],
                              device['place'],
                              device['state'],
                              device['country'],
                              device['last_active'],
                              device['has_moved'] == true,
                            );
                          },
                          child: Icon(
                            Icons.location_pin,
                            size: 40,
                            color: device['has_moved'] == true
                                ? Colors.blue
                                : Colors.green,
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
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Device Map',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        // Map Type Selection Menu with white circular background
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: PopupMenuButton<MapType>(
                            icon: Icon(Icons.map, color: Colors.black),
                            tooltip: 'Select Map Type',
                            onSelected: (MapType type) {
                              _toggleMapType(type);
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<MapType>>[
                              PopupMenuItem<MapType>(
                                value: MapType.defaultMap,
                                child: Text('Default Map'),
                              ),
                              PopupMenuItem<MapType>(
                                value: MapType.satellite,
                                child: Text('Satellite Map'),
                              ),
                              PopupMenuItem<MapType>(
                                value: MapType.terrain,
                                child: Text('Terrain Map'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10), // Space between icons
                        // Reload Icon with white circular background
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                )
                              : IconButton(
                                  icon:
                                      Icon(Icons.refresh, color: Colors.black),
                                  onPressed: isLoading
                                      ? null
                                      : () => _fetchDeviceLocations(),
                                  tooltip: 'Reload Map',
                                ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: _updateSuggestions,
                                onSubmitted: _searchDevices,
                                decoration: InputDecoration(
                                  hintText: 'Search Location',
                                  hintStyle: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: themeProvider.isDarkMode
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedDeviceId,
                                hint: Text(
                                  'Select Device ID',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                items: deviceIds.map((String id) {
                                  return DropdownMenuItem<String>(
                                    value: id,
                                    child: Text(id),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDeviceId = newValue;
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
                                  fillColor: themeProvider.isDarkMode
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                onTap: () => _selectDate(context, true),
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: themeProvider.isDarkMode
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.2),
                                  hintText: startDate == null
                                      ? 'Select Start Date'
                                      : dateFormatter.format(startDate!),
                                  hintStyle: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                onTap: () => _selectDate(context, false),
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: themeProvider.isDarkMode
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.2),
                                  hintText: endDate == null
                                      ? 'Select End Date'
                                      : dateFormatter.format(endDate!),
                                  hintStyle: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (suggestions.isNotEmpty)
                          Container(
                            color: themeProvider.isDarkMode
                                ? Colors.grey[850]
                                : Colors.white,
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
