import 'package:flutter/material.dart';

class DataLoggerPage extends StatelessWidget {
  const DataLoggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF757F9A), const Color(0xFFD7DDE8)]
                  : [const Color.fromARGB(255, 124, 165, 163), const Color.fromARGB(255, 102, 136, 143)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
             
                Stack(
                  children: [
                    Image.asset(
                      "assets/weather_station.jpg",
                      height: isWideScreen ? 400 : 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: isWideScreen ? 400 : 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.3)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                       
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Data Logger / Gateway",
                                    style: TextStyle(
                                      fontSize: isWideScreen ? 42 : 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 6, bottom: 16),
                                    height: 4,
                                  
                                    width: (isWideScreen ? 450 : 250),
                                    color: Colors.orangeAccent,
                                  ),
                                  Text(
                                    "Compact wireless device for data logging & real-time monitoring",
                                    style: TextStyle(
                                      fontSize: isWideScreen ? 18 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 12,
                                    children: [
                                      _buildBannerButton(
                                          "ENQUIRE", Colors.deepOrange),
                                      _buildBannerButton(
                                          "DOWNLOAD BROCHURE", Colors.blue),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 20),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),

           
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDescriptionCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildSpecificationsCard(isDarkMode),
                      const SizedBox(height: 16),
                      _buildUseCaseCard(isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 
  static Widget _buildBannerButton(String label, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: () {},
      icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

 
  Widget _buildDescriptionCard(bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "The Gateway is a compact wireless device that collects data from weather sensors "
          "over long distances using Bluetooth technology. It features built-in data logging "
          "to store readings locally and supports real-time monitoring. Powered by battery or solar, "
          "it is ideal for remote and outdoor weather stations.",
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }


  Widget _buildSpecificationsCard(bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Specifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                )),
            const SizedBox(height: 10),
            featureItem("Material: ABS", isDarkMode),
            featureItem(
                "Function: Sends sensor data to the cloud via mobile network (Internet or SMS)",
                isDarkMode),
            featureItem(
                "Antenna: External SMA or PCB antenna for strong signal reception",
                isDarkMode),
            featureItem(
                "Use Case: Ideal for remote locations without Wi-Fi, enables real-time data transmission to cloud/server",
                isDarkMode),
          ],
        ),
      ),
    );
  }


  Widget _buildUseCaseCard(bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Highlights / Use Cases",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                )),
            const SizedBox(height: 10),
            featureItem("Works in extreme weather conditions", isDarkMode),
            featureItem("Battery or solar powered for remote sites",
                isDarkMode),
            featureItem("Supports multiple sensors simultaneously", isDarkMode),
            featureItem("Easy integration with cloud platforms", isDarkMode),
          ],
        ),
      ),
    );
  }


  Widget featureItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



