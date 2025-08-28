import 'package:cloud_sense_webapp/footer.dart';
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
                      "assets/tree.jpg",
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
                                  maxWidth:
                                      isWideScreen ? 600 : double.infinity,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Wind",
                                            style: TextStyle(
                                              fontSize: isWideScreen ? 48 : 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Sensors",
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
                                      "High quality, general purpose, ultrasonic wind sensors",
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
                                        BannerPoint(
                                            "Accurate & Maintenance-Free Wind Monitoring"),
                                        BannerPoint(
                                            "Real-Time Speed & Direction Measurement"),
                                        BannerPoint(
                                            "Rugged, Solid-State Design for All Environments"),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isWideScreen
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Image.asset(
                                      "assets/windsensor.jpg",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                   // Technical Overview
featureItem("Working Principle: Measures wind speed & direction via ultrasonic time-of-flight (ΔToF)", isDarkMode),
featureItem("Transducers: 200 kHz air-coupled piezoelectric, 2–10 cm effective distance", isDarkMode),
featureItem("Electronics: MSP430FR6043 MCU with USS subsystem, 12-bit ADC & TDC", isDarkMode),
featureItem("Power: 3.3–5 V supply, ~50–80 mW active, ultra-low-power sleep modes", isDarkMode),
featureItem("Software: TI USS library for calibration, ADC capture & UART data output", isDarkMode),

                                      const SizedBox(height: 16),
                                      _buildBannerButton(
                                          "DOWNLOAD DATASHEET", Colors.teal),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Image.asset(
                                  "assets/windsensor.jpg",
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 12),
                                Text("Technical Overview",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    )),
                                const SizedBox(height: 10),
                                featureItem("Working Principle: Measures wind speed & direction via ultrasonic time-of-flight (ΔToF)", isDarkMode),
featureItem("Transducers: 200 kHz air-coupled piezoelectric, 2–10 cm effective distance", isDarkMode),
featureItem("Electronics: MSP430FR6043 MCU with USS subsystem, 12-bit ADC & TDC", isDarkMode),
featureItem("Power: 3.3–5 V supply, ~50–80 mW active, ultra-low-power sleep modes", isDarkMode),
featureItem("Software: TI USS library for calibration, ADC capture & UART data output", isDarkMode),
                                const SizedBox(height: 16),
                                _buildBannerButton(
                                    "DOWNLOAD DATASHEET", Colors.teal),
                              ],
                            ),
                    ),
                  ),
                ),
                 const SizedBox(height: 16),
                _build3DSpecsCard(isDarkMode),
                const SizedBox(height: 16),
                    const Footer(), // Add the Footer widget here
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


Widget _build3DSpecsCard(bool isDarkMode) {
  return Card(
    color: isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600; // breakpoint

          if (isWideScreen) {
            // 💻 Laptop/Desktop Layout (Two Images)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Expanded(
  flex: 1,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Flexible(
        child: Image.asset(
          "assets/wind3d.jpg",
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 20),
      Flexible(
        child: Image.asset(
          "assets/wind3d2.jpg",
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    ],
  ),
),

                const SizedBox(width: 40),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("3D Specifications",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.teal.shade800,
                          )),
                      const SizedBox(height: 12),
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
              ],
            );
          } else {
            // 📱 Mobile Layout (One Image)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/wind3d_2.jpg",
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text("3D Specifications",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.teal.shade800,
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
            );
          }
        },
      ),
    ),
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
            featureItem("Non-contact ultrasonic TOF measurement (no moving parts)", isDarkMode),
featureItem("High accuracy ±0.1–0.3 m/s with fast response time", isDarkMode),
featureItem("360° wind direction coverage with 1° resolution", isDarkMode),
featureItem("Low power consumption (50–80 mW) with UART output", isDarkMode),
featureItem("Rugged, solid-state design for all-weather durability", isDarkMode),
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
       featureItem("Weather monitoring stations", isDarkMode),
featureItem("Smart agriculture & precision farming", isDarkMode),
featureItem("IoT-based environmental and air quality sensing", isDarkMode),
featureItem("UAVs & drones for in-flight wind analysis", isDarkMode),
featureItem("Industrial airflow and HVAC monitoring", isDarkMode),]
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

