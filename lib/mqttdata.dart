// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:universal_html/html.dart'
//     as html; // For web-specific file downloads

// class MQTTDataPage extends StatefulWidget {
//   @override
//   _MQTTDataPageState createState() => _MQTTDataPageState();
// }

// class _MQTTDataPageState extends State<MQTTDataPage> {
//   String? ipAddress;
//   List<dynamic> files = [];

//   // Fetch the IP address of the user's PC
//   Future<void> getIpAddress() async {
//     try {
//       final response =
//           await http.get(Uri.parse('http://localhost:5000/api/ip'));

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         setState(() {
//           ipAddress = data['ip'];
//         });

//         if (ipAddress != null) {
//           fetchFiles(
//               ipAddress!); // Once the IP is fetched, get the list of files.
//         }
//       } else {
//         throw Exception('Failed to fetch IP');
//       }
//     } catch (e) {
//       print('Error getting IP: $e');
//     }
//   }

//   // Fetch the files/folders from the Flask API dynamically using the fetched IP
//   Future<void> fetchFiles(String ip) async {
//     try {
//       final response = await http.get(Uri.parse('http://$ip:5000/api/files'));

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         setState(() {
//           files = data['files'];
//         });

//         // Print the files and folders to the console
//         print('Files and Folders at IP $ip:');
//         for (var file in files) {
//           print(
//               'File: ${file['name']} | Type: ${file['is_directory'] ? 'Folder' : 'File'}');
//         }
//       } else {
//         throw Exception('Failed to fetch files');
//       }
//     } catch (e) {
//       print('Error fetching files: $e');
//     }
//   }

//   // Function to download a file
//   Future<void> downloadFile(String filePath, String fileName) async {
//     final url = 'http://$ipAddress:5000/api/download?path=$filePath';

//     if (kIsWeb) {
//       // Web-specific logic
//       try {
//         html.AnchorElement anchor = html.AnchorElement(href: url)
//           ..target = 'blank'
//           ..download = fileName;
//         anchor.click();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Download started for $fileName')),
//         );
//       } catch (e) {
//         print('Error downloading file on web: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error downloading file: $e')),
//         );
//       }
//     } else {
//       // Android/Desktop-specific logic
//       try {
//         final response = await http.get(Uri.parse(url));

//         if (response.statusCode == 200) {
//           // Get the local directory to save the file
//           final directory = await getApplicationDocumentsDirectory();
//           final file = File('${directory.path}/$fileName');

//           // Write the file content to local storage
//           await file.writeAsBytes(response.bodyBytes);

//           // Notify the user
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Downloaded $fileName')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to download $fileName')),
//           );
//         }
//       } catch (e) {
//         print('Error downloading file: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error downloading file: $e')),
//         );
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getIpAddress(); // Fetch the IP on initial screen load
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Files and Folders"),
//       ),
//       body: ipAddress == null
//           ? Center(child: CircularProgressIndicator())
//           : files.isEmpty
//               ? Center(child: Text('No files found!'))
//               : ListView.builder(
//                   itemCount: files.length,
//                   itemBuilder: (context, index) {
//                     var file = files[index];
//                     return ListTile(
//                       title: Text(file['name']),
//                       subtitle: Text(file['is_directory'] ? 'Folder' : 'File'),
//                       trailing: file['is_directory']
//                           ? null
//                           : IconButton(
//                               icon: Icon(Icons.download),
//                               onPressed: () {
//                                 downloadFile(file['path'], file['name']);
//                               },
//                             ),
//                     );
//                   },
//                 ),
//     );
//   }
// }
