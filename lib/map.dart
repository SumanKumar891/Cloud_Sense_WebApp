// import 'dart:convert'; // For JSON decoding
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http; // For API requests

// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   LatLng centerCoordinates = LatLng(0, 0); // Default center coordinates
//   double zoomLevel = 5.0; // Default zoom level
//   late MapController mapController; // Declare MapController

//   final List<Map<String, dynamic>> deviceLocations = [
//     {
//       'name': 'Device 1',
//       'latitude': 37.7749, // San Francisco, USA
//       'longitude': -122.4194,
//       'city': 'San Francisco',
//       'country': 'USA',
//       'last_active': '2023-12-15 10:00 AM',
//     },
//     {
//       'name': 'Device 2',
//       'latitude': 51.5074, // London, UK
//       'longitude': -0.1278,
//       'city': 'London',
//       'country': 'UK',
//       'last_active': '2023-12-16 03:00 PM',
//     },
//     {
//       'name': 'Device 3',
//       'latitude': -33.8688, // Sydney, Australia
//       'longitude': 151.2093,
//       'city': 'Sydney',
//       'country': 'Australia',
//       'last_active': '2023-12-14 08:00 AM',
//     },
//     {
//       'name': 'Device 4',
//       'latitude': 28.6139, // New Delhi, India
//       'longitude': 77.2090,
//       'city': 'New Delhi',
//       'country': 'India',
//       'last_active': '2023-12-13 02:00 PM',
//     },
//     {
//       'name': 'Device 5',
//       'latitude': 55.7558, // Moscow, Russia
//       'longitude': 37.6173,
//       'city': 'Moscow',
//       'country': 'Russia',
//       'last_active': '2023-12-06 11:00 AM',
//     },
//     {
//       'name': 'Device 6',
//       'latitude': 39.9042, // Beijing, China
//       'longitude': 116.4074,
//       'city': 'Beijing',
//       'country': 'China',
//       'last_active': '2023-12-05 09:00 AM',
//     },
//     {
//       'name': 'Device 7',
//       'latitude': 48.8566, // Paris, France
//       'longitude': 2.3522,
//       'city': 'Paris',
//       'country': 'France',
//       'last_active': '2023-12-08 04:00 PM',
//     },
//   ];

//   TextEditingController searchController = TextEditingController();
//   String searchQuery = '';
//   List<Map<String, dynamic>> filteredDevices = [];
//   List<Map<String, dynamic>> suggestions = [];
//   Marker? searchPin;

//   @override
//   void initState() {
//     super.initState();
//     mapController = MapController(); // Initialize MapController
//     filteredDevices = deviceLocations; // Initially show all devices
//   }

//   Future<void> _geocode(String query) async {
//     try {
//       final url =
//           'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json';
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final location = data[0]['lat'] != null && data[0]['lon'] != null
//               ? {'lat': data[0]['lat'], 'lon': data[0]['lon']}
//               : null;

//           if (location != null) {
//             double lat = double.parse(location['lat']);
//             double lon = double.parse(location['lon']);
//             LatLng searchCoordinates = LatLng(lat, lon);

//             setState(() {
//               centerCoordinates = searchCoordinates;
//               zoomLevel = 12.0;
//               searchPin = Marker(
//                 width: 80.0,
//                 height: 80.0,
//                 point: searchCoordinates,
//                 builder: (ctx) => Icon(
//                   Icons.location_pin,
//                   size: 40,
//                   color: Colors.blue,
//                 ),
//               );
//             });
//             mapController.move(searchCoordinates, zoomLevel);
//           } else {
//             _showError("No coordinates found for '$query'.");
//           }
//         } else {
//           _showError("No results found for '$query'.");
//         }
//       } else {
//         _showError(
//             "Failed to fetch location. Status Code: ${response.statusCode}");
//       }
//     } catch (e) {
//       _showError('Error during geocoding: $e');
//     }
//   }

//   void _searchDevices(String query) async {
//     setState(() {
//       searchQuery = query.toLowerCase();
//       filteredDevices = deviceLocations.where((device) {
//         return device['city']?.toLowerCase().contains(searchQuery) == true ||
//             device['country']?.toLowerCase().contains(searchQuery) == true ||
//             device['name']?.toLowerCase().contains(searchQuery) == true;
//       }).toList();
//     });

//     if (filteredDevices.isEmpty && query.isNotEmpty) {
//       await _geocode(query);
//     } else if (filteredDevices.isNotEmpty) {
//       final device = filteredDevices.first;
//       setState(() {
//         centerCoordinates = LatLng(device['latitude'], device['longitude']);
//         zoomLevel = 12.0;
//         searchPin = null;
//       });
//       mapController.move(centerCoordinates, zoomLevel);
//     }
//   }

//   void _updateSuggestions(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         suggestions = [];
//       });
//       return;
//     }

//     setState(() {
//       suggestions = deviceLocations
//           .where((device) =>
//               device['name'].toLowerCase().contains(query.toLowerCase()) ||
//               device['city'].toLowerCase().contains(query.toLowerCase()) ||
//               device['country'].toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _selectSuggestion(Map<String, dynamic> suggestion) {
//     searchController.text = suggestion['city'];
//     _searchDevices(suggestion['city']);
//     setState(() {
//       suggestions = [];
//     });
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.lightBlue[100],
//         child: Stack(
//           children: [
//             FlutterMap(
//               mapController: mapController,
//               options: MapOptions(
//                 center: centerCoordinates,
//                 zoom: zoomLevel,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: ['a', 'b', 'c'],
//                   backgroundColor: const Color.fromARGB(255, 173, 216, 230),
//                 ),
//                 MarkerLayer(
//                   markers: [
//                     if (searchPin != null) searchPin!,
//                     ...deviceLocations.map((device) {
//                       return Marker(
//                         width: 80.0,
//                         height: 80.0,
//                         point: LatLng(
//                           device['latitude'],
//                           device['longitude'],
//                         ),
//                         builder: (ctx) => Tooltip(
//                           message:
//                               "${device['name']}\nCity: ${device['city']}\nCountry: ${device['country']}\nLast Active: ${device['last_active']}",
//                           child: Icon(
//                             Icons.location_pin,
//                             size: 40,
//                             color: Colors.red,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ],
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   Container(
//                     color: Colors.transparent,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.arrow_back, color: Colors.black),
//                           onPressed: () => Navigator.of(context).pop(),
//                         ),
//                         Text(
//                           "Device Map",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Spacer(),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Column(
//                       children: [
//                         TextField(
//                           controller: searchController,
//                           onChanged: _updateSuggestions,
//                           onSubmitted: _searchDevices,
//                           decoration: InputDecoration(
//                             hintText: 'Search here',
//                             prefixIcon: Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             filled: true,
//                             fillColor:
//                                 Theme.of(context).brightness == Brightness.dark
//                                     ? Colors.black.withOpacity(0.7)
//                                     : Colors.white,
//                           ),
//                         ),
//                         if (suggestions.isNotEmpty)
//                           Container(
//                             color:
//                                 Theme.of(context).brightness == Brightness.dark
//                                     ? Colors.black.withOpacity(0.5)
//                                     : Colors.white.withOpacity(0.5),
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: suggestions.length,
//                               itemBuilder: (context, index) {
//                                 final suggestion = suggestions[index];
//                                 return ListTile(
//                                   title: Text(suggestion['city']),
//                                   subtitle: Text(
//                                       "${suggestion['country']} - ${suggestion['name']}"),
//                                   onTap: () => _selectSuggestion(suggestion),
//                                 );
//                               },
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: MapPage(),
//   ));
// }
