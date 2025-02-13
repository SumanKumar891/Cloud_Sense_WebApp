// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'FTP File Fetcher',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: FtpFilesScreen(),
// //     );
// //   }
// // }

// // class FtpFilesScreen extends StatefulWidget {
// //   @override
// //   _FtpFilesScreenState createState() => _FtpFilesScreenState();
// // }

// // class _FtpFilesScreenState extends State<FtpFilesScreen> {
// //   List<String> files = [];
// //   bool isLoading = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchFiles();
// //   }

// //   Future<void> fetchFiles() async {
// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       final response =
// //           await http.get(Uri.parse('http://127.0.0.1:5000/list-files'));
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         setState(() {
// //           files = List<String>.from(data['files']);
// //         });
// //       } else {
// //         setState(() {
// //           files = ['Error fetching files: ${response.statusCode}'];
// //         });
// //       }
// //     } catch (e) {
// //       print("Error: $e");
// //       setState(() {
// //         files = ['Error fetching files'];
// //       });
// //     } finally {
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('FTP File Fetcher'),
// //       ),
// //       body: isLoading
// //           ? Center(child: CircularProgressIndicator())
// //           : ListView.builder(
// //               itemCount: files.length,
// //               itemBuilder: (context, index) {
// //                 return ListTile(
// //                   title: Text(files[index]),
// //                 );
// //               },
// //             ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'FTP File Fetcher',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: FtpFilesScreen(),
//     );
//   }
// }

// class FtpFilesScreen extends StatefulWidget {
//   @override
//   _FtpFilesScreenState createState() => _FtpFilesScreenState();
// }

// class _FtpFilesScreenState extends State<FtpFilesScreen> {
//   Map<String, dynamic>? directoryStructure;
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchDirectoryStructure();
//   }

//   Future<void> fetchDirectoryStructure() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response =
//           await http.get(Uri.parse('http://127.0.0.1:5000/list-files'));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           directoryStructure = data;
//         });
//       } else {
//         setState(() {
//           directoryStructure = {
//             "error":
//                 "Error fetching directory structure: ${response.statusCode}"
//           };
//         });
//       }
//     } catch (e) {
//       print("Error: $e");
//       setState(() {
//         directoryStructure = {"error": "Error fetching directory structure"};
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Widget buildDirectory(dynamic node) {
//     if (node == null) {
//       return Center(child: Text("No data available."));
//     }

//     // Handle error case
//     if (node is Map<String, dynamic> && node.containsKey("error")) {
//       return Center(child: Text(node["error"]));
//     }

//     // Display directories and files
//     if (node["type"] == "directory") {
//       return ExpansionTile(
//         title: Text(node["path"].isEmpty ? "/" : node["path"]),
//         children: node["children"]
//             .map<Widget>((child) => buildDirectory(child))
//             .toList(),
//       );
//     } else if (node["type"] == "file") {
//       return ListTile(
//         title: Text(node["path"]),
//         trailing: Icon(Icons.file_download),
//         onTap: () {
//           downloadFile(node["path"]);
//         },
//       );
//     } else {
//       return SizedBox.shrink(); // Fallback for unknown types
//     }
//   }

//   Future<void> downloadFile(String filePath) async {
//     // Implement file download logic here
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Downloading: $filePath')),
//     );
//     // Add file download implementation as needed
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('FTP File Fetcher'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: directoryStructure != null
//                   ? buildDirectory(directoryStructure)
//                   : Center(child: Text('No directory structure available')),
//             ),
//     );
//   }
// }
