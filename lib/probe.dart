import 'package:cloud_sense_webapp/footer.dart';
import 'package:flutter/material.dart';

class ProbePage extends StatelessWidget {
  const ProbePage({super.key});

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
                      "assets/probebg.jpg",
                      height: isWideScreen ? 450 : 450,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                    Container(
                      height: isWideScreen ? 450 : 450,
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
                                            text: "Temperature and Humidity ",
                                            style: TextStyle(
                                              fontSize: isWideScreen ? 48 : 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Probe",
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
                                      "Accurate measurements for temperature and humidity.",
                                      style: TextStyle(
                                        fontSize: isWideScreen ? 20 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        BannerPoint("Measures temperature and humidity with high accuracy"),
                                  
                                        BannerPoint("Provides both analog (0–1000 mV) and digital (RS485/Modbus) outputs"),
                                        BannerPoint("Reliable, industrial-grade monitoring with CRC-validated communication"),
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
                
                // 👇 Updated Technical Overview with only ONE image
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.teal.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isWideScreen
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 300,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      // child: Image.asset(" "), // 👈 only one image
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
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          )),
                                      const SizedBox(height: 12),
                                      featureItem("Constructed around nRF52833 MCU (ARM Cortex-M4F, BLE + multiple interfaces)", isDarkMode),
                                      featureItem("PT100 sensor interfaced through MAX31865 (SPI-based RTD converter)", isDarkMode),
                                      featureItem("SHT45 digital sensor provides ±1.0% RH, ±0.1 °C accuracy via I²C", isDarkMode),
                                      featureItem("Two MCP4725 DACs convert digital readings into analog voltage outputs", isDarkMode),
                                      featureItem("RS485 transceiver enables long-distance Modbus RTU communication", isDarkMode),
                                      featureItem("Sensor data scaled into engineering units and mapped to 12-bit DAC outputs", isDarkMode),
                                      featureItem("Output Format: Digital (RS485 Modbus) + Analog (0–1000 mV)", isDarkMode),
                                      const SizedBox(height: 16),
                                      _buildBannerButton("DOWNLOAD DATASHEET", Colors.teal),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    // child: Image.asset(" "), // 👈 only one image
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text("Technical Overview",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    )),
                                const SizedBox(height: 10),
                                featureItem("Constructed around nRF52833 MCU (ARM Cortex-M4F, BLE + multiple interfaces)", isDarkMode),
                                featureItem("PT100 sensor interfaced through MAX31865 (SPI-based RTD converter)", isDarkMode),
                                featureItem("SHT45 digital sensor provides ±1.0% RH, ±0.1 °C accuracy via I²C", isDarkMode),
                                featureItem("Two MCP4725 DACs convert digital readings into analog voltage outputs", isDarkMode),
                                featureItem("RS485 transceiver enables long-distance Modbus RTU communication", isDarkMode),
                                featureItem("Sensor data scaled into engineering units and mapped to 12-bit DAC outputs", isDarkMode),
                                featureItem("Output Format: Digital (RS485 Modbus) + Analog (0–1000 mV)", isDarkMode),
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
            featureItem("High-precision temperature and humidity sensing probe", isDarkMode),
            featureItem("Digital humidity and temperature measurement with SHT45 sensor", isDarkMode),
            featureItem("Dual MCP4725 DAC outputs provide analog voltage signals (0–1000 mV)", isDarkMode),
            featureItem("Robust RS485/Modbus-RTU communication for industrial use", isDarkMode),
            featureItem("Compact, low-power design suitable for embedded and IoT applications", isDarkMode),
            featureItem("Built-in CRC16 validation ensures reliable and error-free data transfer", isDarkMode),
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
            featureItem("Industrial process monitoring (manufacturing, HVAC, food processing)", isDarkMode),
            featureItem("Environmental monitoring (greenhouses, warehouses, cold storage)", isDarkMode),
            featureItem("Agriculture and smart irrigation systems", isDarkMode),
            featureItem("IoT gateways & cloud-connected monitoring systems", isDarkMode),
            featureItem("Research labs and calibration setups for temp-humidity validation", isDarkMode),
            featureItem("Legacy system integration using analog outputs", isDarkMode),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
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
