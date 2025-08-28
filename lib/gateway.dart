import 'package:flutter/material.dart';
import 'package:cloud_sense_webapp/footer.dart';

class GatewayPage extends StatelessWidget {
  const GatewayPage({super.key});

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
                  ? [
                      const Color.fromARGB(255, 57, 57, 57),
                      const Color.fromARGB(255, 2, 54, 76),
                    ]
                  : [
                      const Color.fromARGB(255, 191, 242, 237),
                      const Color.fromARGB(255, 79, 106, 112),
                    ],
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
                      "assets/gatewaybg.jpg",
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
                            Colors.black.withOpacity(0.6)
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
                        text: "Gate",
                        style: TextStyle(
                          fontSize: isWideScreen ? 48 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      TextSpan(
                        text: "way",
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
                  "Next-Gen BLE Gateway for Industrial IoT Applications",
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
                    BannerPoint("Seamless IoT Data Aggregation"),
                    BannerPoint("Reliable Long-Range BLE Connectivity"),
                    BannerPoint("Scalable Gateway for 100+ Sensor Nodes"),
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
                                      "assets/gateway.jpg",
                                      height: 400,
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
                                    

    featureItem("Core Processing Unit: Nordic nRF5340 Dual-Core SoC", isDarkMode),
    subFeatureItem("Application Core: Arm Cortex-M33 @128 MHz", isDarkMode),
    subFeatureItem("Network Core: Arm Cortex-M33 @64 MHz", isDarkMode),

    featureItem("Memory: 1 MB Flash, 512 KB RAM", isDarkMode),

    featureItem("Radio Subsystem", isDarkMode),
    subFeatureItem("Bluetooth 5.3 compliant", isDarkMode),
    subFeatureItem("Frequency: 2.4 GHz ISM band (GFSK modulation)", isDarkMode),
    subFeatureItem("Transmit Power: Up to +8 dBm", isDarkMode),
    subFeatureItem("Receiver Sensitivity: -95 dBm", isDarkMode),

    featureItem("Connectivity Options: LAN, Wi-Fi, 4G", isDarkMode),
    featureItem("Scalability: Connects 100+ BLE sensor nodes", isDarkMode),
    featureItem("Design: IP67-rated, compact industrial PCB with low power consumption", isDarkMode),
  


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
                                  "assets/gateway.jpg",
                                  height: 260,
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
                            featureItem("Core Processing Unit: Nordic nRF5340 Dual-Core SoC", isDarkMode),
    subFeatureItem("Application Core: Arm Cortex-M33 @128 MHz", isDarkMode),
    subFeatureItem("Network Core: Arm Cortex-M33 @64 MHz", isDarkMode),

    featureItem("Memory: 1 MB Flash, 512 KB RAM", isDarkMode),

    featureItem("Radio Subsystem", isDarkMode),
    subFeatureItem("Bluetooth 5.3 compliant", isDarkMode),
    subFeatureItem("Frequency: 2.4 GHz ISM band (GFSK modulation)", isDarkMode),
    subFeatureItem("Transmit Power: Up to +8 dBm", isDarkMode),
    subFeatureItem("Receiver Sensitivity: -95 dBm", isDarkMode),

    featureItem("Connectivity Options: LAN, Wi-Fi, 4G", isDarkMode),
    featureItem("Scalability: Connects 100+ BLE sensor nodes", isDarkMode),
    featureItem("Design: IP67-rated, compact industrial PCB with low power consumption", isDarkMode),
                                        
                                const SizedBox(height: 16),
                                _buildBannerButton("DOWNLOAD DATASHEET", Colors.teal),
                              ],
                            ),
                    ),
                  ),
                ),
                const Footer(),
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
           featureItem("Dual-Core nRF5340 SoC for optimized processing", isDarkMode),
    featureItem("Bluetooth 5.3 with configurable +8 dBm transmit power", isDarkMode),
    featureItem("Real-time monitoring with up to 1 KM range", isDarkMode),
    featureItem("Supports 100+ connected BLE sensor nodes", isDarkMode),
    featureItem("Firmware Over-the-Air (FOTA) support", isDarkMode),
    featureItem("Rugged IP67 compact design for industrial environments", isDarkMode),
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
           featureItem("Smart agriculture & precision farming", isDarkMode),
    featureItem("Industrial equipment health monitoring", isDarkMode),
    featureItem("Environmental and air quality sensing", isDarkMode),
    featureItem("Smart building automation & energy management", isDarkMode),
    featureItem("Logistics and asset tracking", isDarkMode),
    featureItem("Healthcare wearable data collection", isDarkMode),
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
Widget subFeatureItem(String text, bool isDarkMode) {
  return Padding(
    padding: const EdgeInsets.only(left: 32, top: 2, bottom: 2),
    child: Row(
      children: [
        Icon(Icons.circle,
            size: 10, color: isDarkMode ? Colors.tealAccent : Colors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
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

