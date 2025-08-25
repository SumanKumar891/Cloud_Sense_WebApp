import 'package:flutter/material.dart';

class UltrasonicSensorPage extends StatelessWidget {
  const UltrasonicSensorPage({super.key});

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
                  ? [const Color(0xFFC0B9B9), const Color(0xFF7B9FAE)]
                  : [const Color(0xFF7EABA6), const Color(0xFF363A3B)],
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
                      "assets/tree.jpg",
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          child: SizedBox(
                            width: isWideScreen ? 600 : double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                               
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "WindSensors",
                                      style: TextStyle(
                                        fontSize: isWideScreen ? 48 : 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 6, bottom: 16),
                                      height: 4,
                                      width: (isWideScreen ? 270 : 190),
                                      color: Colors.lightBlueAccent,
                                    ),
                                  ],
                                ),

                               
                                Text(
                                  "High quality, general purpose, ultrasonic wind sensors",
                                  style: TextStyle(
                                    fontSize: isWideScreen ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),

                               
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    BannerPoint(
                                        "High accuracy, low cost wind measurement"),
                                    BannerPoint(
                                        "Excellent reliability, low maintenance"),
                                    BannerPoint(
                                        "Models and outputs to suit varied applications"),
                                  ],
                                ),
                                const SizedBox(height: 24),

                              
                                Wrap(
                                  spacing: 12,
                                  children: [
                                    _buildBannerButton(
                                        "ENQUIRE", Colors.lightBlue),
                                    _buildBannerButton(
                                        "DATASHEETS", Colors.teal),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

           
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isWideScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildFeaturesCard(isDarkMode)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildApplicationsCard(isDarkMode)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildFeaturesCard(isDarkMode),
                            const SizedBox(height: 16),
                            _buildApplicationsCard(isDarkMode),
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


  Widget _buildFeaturesCard(bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Key Features",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                )),
            const SizedBox(height: 10),
            featureItem("Measurements up to 60m/s (216 km/h)", isDarkMode),
            featureItem("Models up to 75m/s (270 km/h)", isDarkMode),
            featureItem("WMO-compliant gust calculation", isDarkMode),
            featureItem("Unheated and heated models available", isDarkMode),
            featureItem("Maintenance-free, low cost", isDarkMode),
          ],
        ),
      ),
    );
  }


  Widget _buildApplicationsCard(bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Typical Applications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                )),
            const SizedBox(height: 10),
            featureItem("Wind speed & direction observation", isDarkMode),
            featureItem("Pollution plume monitoring", isDarkMode),
            featureItem("Solar plant asset protection", isDarkMode),
            featureItem("Tunnel & industrial ventilation", isDarkMode),
            featureItem("IoT, smart city applications", isDarkMode),
            featureItem("Integration into weather systems", isDarkMode),
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
          const Icon(Icons.check, color: Colors.teal, size: 20),
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

class BannerPoint extends StatelessWidget {
  final String text;
  const BannerPoint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
