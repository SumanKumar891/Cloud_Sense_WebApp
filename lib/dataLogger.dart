import 'package:cloud_sense_webapp/download.dart';
import 'package:cloud_sense_webapp/footer.dart';
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
                // ---------- Banner Section ----------
                Stack(
                  children: [
                    Row(
                      children: [
                        // 🔹 Left half: Solid grey background
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: isWideScreen ? 450 : 400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // 🔹 Right half: Datalogger image
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: isWideScreen ? 450 : 400,
                            child: Image.asset(
                              "assets/dataloggerrender.png",
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ],
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
                                    Navigator.of(context)
                                        .pushReplacementNamed("/");
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
                                              color: const Color.fromARGB(
                                                  255, 219, 80, 145),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 6, bottom: 16),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        BannerPoint("30-day Data Backup with GPS"),
                                        BannerPoint(
                                            "4G Dual SIM with Multi-Protocol Support"),
                                        BannerPoint("Rugged IP66 Weatherproof Design"),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildBannerButton(
                                          "Enquire",
                                          Colors.blue,
                                          () {},
                                        ),
                                        _buildBannerButton(
                                          "Download Manual",
                                          Colors.teal,
                                          () {
                                            DownloadManager.downloadFile(
                                              context: context,
                                              sensorKey: "DataLogger",
                                              fileType: "manual",
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isWideScreen
                      ? _buildTabbedSpecs(isDarkMode) 
                      : _buildAccordionSpecs(isDarkMode), 
                ),

                const SizedBox(height: 16),
                const Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  
    // ---------- Wide Screen Tabs ----------
  Widget _buildTabbedSpecs(bool isDarkMode) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WindSensor Technical Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    color: isDarkMode
                        ? Colors.teal.shade800.withOpacity(0.3)
                        : Colors.teal.shade200.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  labelColor:
                      isDarkMode ? Colors.teal.shade200 : Colors.teal.shade700,
                  unselectedLabelColor:
                      isDarkMode ? Colors.white70 : Colors.black87,
                  tabs: const [
                    Tab(text: "WORKING"),
                    Tab(text: "3D SPECS"),
                    Tab(text: "HARDWARE"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: tabController,
                builder: (context, _) {
                  switch (tabController.index) {
                    case 0:
                      return _buildWorkingCard(isDarkMode);
                    case 1:
                      return _build3DSpecsCard(isDarkMode);
                    case 2:
                      return _buildHardwareCard(isDarkMode);
                    default:
                      return Container();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- Small Screen Accordion ----------
  Widget _buildAccordionSpecs(bool isDarkMode) {
    return ExpansionPanelList.radio(
      dividerColor: Colors.grey,
      children: [
        ExpansionPanelRadio(
          value: 1,
          headerBuilder: (context, isExpanded) => ListTile(
            title: Text("WORKING",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.tealAccent : Colors.teal)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildWorkingCard(isDarkMode),
          ),
        ),
        ExpansionPanelRadio(
          value: 2,
          headerBuilder: (context, isExpanded) => ListTile(
            title: Text("3D SPECS",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.tealAccent : Colors.teal)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _build3DSpecsCard(isDarkMode),
          ),
        ),
        ExpansionPanelRadio(
          value: 3,
          headerBuilder: (context, isExpanded) => ListTile(
            title: Text("HARDWARE",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.tealAccent : Colors.teal)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildHardwareCard(isDarkMode),
          ),
        ),
      ],
    );
  }
  // ---------- Cards ----------
  Widget _buildWorkingCard(bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Technical Overview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue.shade800,
                )),
            const SizedBox(height: 10),
            featureItem(
                                    "Connectivity: 4G Dual SIM with GNSS",
                                    isDarkMode),
                                featureItem(
                                    "Data Support: HTTP, HTTPS, MQTT, FTP",
                                    isDarkMode),
                                featureItem(
                                    "Interfaces: ADC, UART, I2C, SPI, RS232, CAN",
                                    isDarkMode),
                                featureItem(
                                    "Enclosure: IP66, waterproof & dustproof",
                                    isDarkMode),
                                featureItem(
                                    "Backup: 30-day onboard data storage",
                                    isDarkMode),
                                featureItem(
                                    "Power Options: Battery / Solar", isDarkMode),
            const SizedBox(height: 16),
            _buildBannerButton("Download Datasheet", Colors.teal, () {}),
          ],
        ),
      ),
    );
  }


Widget _build3DSpecsCard(bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("3D Specifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue.shade800,
                )),
            const SizedBox(height: 10),
            featureItem("Overall Height: 150 mm", isDarkMode),
            featureItem("Top Plate Diameter: 144.69 mm", isDarkMode),
            featureItem("Middle Plate Diameter: 121.20 mm", isDarkMode),
            featureItem("Mounting Hole Circle Diameter: 52 mm", isDarkMode),
            featureItem("Inner Mounting Slot Diameter: 46 mm", isDarkMode),
            featureItem("Support Rod Curvature: R11.50 mm", isDarkMode),
            featureItem("Cylindrical Base Diameter: 52 mm", isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwareCard(bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hardware Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue.shade800,
                )),
            const SizedBox(height: 10),
            featureItem("Processor: ARM Cortex-M4", isDarkMode),
            featureItem("Memory: 256KB Flash, 64KB SRAM", isDarkMode),
            featureItem("Interfaces: UART, I2C, SPI", isDarkMode),
            featureItem("Operating Temp: -40°C to +85°C", isDarkMode),
          ],
        ),
      ),
    );
  }

  static Widget _buildBannerButton(
      String label, Color color, VoidCallback onPressed) {
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
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isWideScreen ? 15 : 12,
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
            featureItem("4G Dual SIM, GNSS enabled for reliable connectivity",
                isDarkMode),
            featureItem("Built-in 30-day data backup with GPS support",
                isDarkMode),
            featureItem(
                "Multiple interfaces: ADC, UART, I2C, SPI, RS232, CAN", isDarkMode),
            featureItem("Supports modern protocols (HTTP, HTTPS, MQTT, FTP)",
                isDarkMode),
            featureItem(
                "Rugged IP66 enclosure for harsh outdoor environments", isDarkMode),
            featureItem("Solar and battery-powered option for remote sites",
                isDarkMode),
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
            featureItem("Disaster management and early warning systems",
                isDarkMode),
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
                fontSize: isWideScreen ? 16 : 13,
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