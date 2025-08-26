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
                      "assets/dataLoggerBg.jpg",
                      height: isWideScreen ? 450 : 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                    Container(
                      height: isWideScreen ? 450 : 400,
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
Positioned.fill(
  child: Align(
    alignment: Alignment.topLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 8), 
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Colors.white, size: 22),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed("/");
              }
            },
          ),
        ),

     
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 84 : 16,
            vertical: isWideScreen ? 20 : 12,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

           
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Data",
                        style: TextStyle(
                          fontSize: isWideScreen ? 48 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      TextSpan(
                        text: "Logger",
                        style: TextStyle(
                          fontSize: isWideScreen ? 48 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 219, 80, 145),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 16),
                  height: 3,
                  width: isWideScreen ? 270 : 150,
                  color: Colors.lightBlueAccent,
                ),

                Text(
                  "Reliable Data Logging & Seamless Connectivity",
                  style: TextStyle(
                    fontSize: isWideScreen ? 20 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    BannerPoint("30-day Data Backup with GPS"),
                    BannerPoint("4G Dual SIM with Multi-Protocol Support"),
                    BannerPoint("Rugged IP66 Weatherproof Design"),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBannerButton("ENQUIRE", Colors.lightBlue),
                    _buildBannerButton("DATASHEETS", Colors.teal),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
)

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

          
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
  color: isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50, 
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  elevation: 6,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child:isWideScreen
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Image.asset(
                                      "assets/weather_station.jpg",
                                      height: 300,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 50),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Technical Overview",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      const SizedBox(height: 12),
                                       featureItem("Connectivity: 4G Dual SIM with GNSS", isDarkMode),
                                      featureItem("Data Support: HTTP, HTTPS, MQTT, FTP", isDarkMode),
                                      featureItem("Interfaces: ADC, UART, I2C, SPI, RS232, CAN", isDarkMode),
                                      featureItem("Enclosure: IP66, waterproof & dustproof", isDarkMode),
                                      featureItem("Backup: 30-day onboard data storage", isDarkMode),
                                      featureItem("Power Options: Battery / Solar", isDarkMode),
                                      const SizedBox(height: 16),
                                      _buildBannerButton("DOWNLOAD DATASHEET", Colors.teal),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Image.asset(
                                  "assets/weather_station.jpg",
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 12),
                                Text("Technical Overview",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    )),
                                const SizedBox(height: 10),
                           featureItem("Connectivity: 4G Dual SIM with GNSS", isDarkMode),
                                      featureItem("Data Support: HTTP, HTTPS, MQTT, FTP", isDarkMode),
                                      featureItem("Interfaces: ADC, UART, I2C, SPI, RS232, CAN", isDarkMode),
                                      featureItem("Enclosure: IP66, waterproof & dustproof", isDarkMode),
                                      featureItem("Backup: 30-day onboard data storage", isDarkMode),
                                      featureItem("Power Options: Battery / Solar", isDarkMode),
                                        
                                const SizedBox(height: 16),
                                _buildBannerButton("DOWNLOAD DATASHEET", Colors.teal),
                              ],
                            ),
                    ),
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
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isWideScreen = screenWidth > 800;

      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 20 : 12,
            vertical: isWideScreen ? 14 : 10,
          ),
          minimumSize: Size(isWideScreen ? 140 : 100, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onPressed: () {},
        icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWideScreen ? 15 : 12, // responsive text
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    },
  );
}


  Widget _buildFeaturesCard(bool isDarkMode) {
  return Card(
    color: isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50, 
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
                color: isDarkMode ? Colors.white : Colors.teal.shade800,
              )),
          const SizedBox(height: 10),
          featureItem("4G Dual SIM, GNSS enabled for reliable connectivity", isDarkMode),
          featureItem("Built-in 30-day data backup with GPS support", isDarkMode),
          featureItem("Multiple interfaces: ADC, UART, I2C, SPI, RS232, CAN", isDarkMode),
          featureItem("Supports modern protocols (HTTP, HTTPS, MQTT, FTP)", isDarkMode),
          featureItem("Rugged IP66 enclosure for harsh outdoor environments", isDarkMode),
          featureItem("Solar and battery-powered option for remote sites", isDarkMode),
        ],
      ),
    ),
  );
}

Widget _buildApplicationsCard(bool isDarkMode) {
  return Card(
    color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50, 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Applications",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.blue.shade800, 
              )),
          const SizedBox(height: 10),
          featureItem("Remote weather monitoring stations", isDarkMode),
          featureItem("Smart agriculture & irrigation management", isDarkMode),
          featureItem("Disaster management and early warning systems", isDarkMode),
          featureItem("Industrial & environmental monitoring", isDarkMode),
          featureItem("Smart cities & IoT projects", isDarkMode),
            featureItem("Government & policy-based data reporting", isDarkMode),
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
        Icon(Icons.check_circle, 
            color: isDarkMode ? Colors.tealAccent : Colors.teal, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.white : Colors.black87, 
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWideScreen ? 16 : 13, // responsive size
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

