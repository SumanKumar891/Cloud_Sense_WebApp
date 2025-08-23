import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          elevation: 4,
        ),
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 🔹 Bada aur bold title jo tumne mangwaya tha
        title: const Text(
          "OUR PRODUCTS",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/5.jpg",
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _leftContent(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _leftContent()),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                "assets/5.jpg",
                                fit: BoxFit.cover,
                                height: 600,
                              ),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 40),
                // ⚠ Footer has been moved to bottomNavigationBar so remove it from body
              ],
            ),
          );
        },
      ),

      // ✅ Footer fixed to bottom of screen (sticky)
      bottomNavigationBar: const FooterSection(),
    );
  }

  // 🔹 Left side content extract kiya
  Widget _leftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HoverCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Advanced Weather Station",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "A modern, automated system providing accurate real-time weather data. "
                  "Equipped with AI-based forecasting and seamless connectivity, "
                  "it helps monitor rainfall, temperature, humidity, wind speed, and direction.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Features & Benefits
        HoverCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Features & Benefits",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                featureItem("Solar Powered",
                    "Runs on solar energy for efficient, remote operation."),
                featureItem("Wireless Connectivity",
                    "GSM 4G with dual SIM ensures reliable, always-on data transfer."),
                featureItem("Real-Time Monitoring",
                    "Collects multi-sensor data for live climate insights."),
                featureItem("Cloud Integration",
                    "Supports MQTT, HTTP, FTP for AWS IoT, APIs, or govt. servers."),
                featureItem("Low Power Backup",
                    "30-day battery backup ensures uninterrupted operation."),
                featureItem("Rugged IP67 Design",
                    "Weatherproof, dustproof, impact-resistant for outdoor use."),
                featureItem("Dual SIM & OTA Updates",
                    "Enhanced connectivity with SMS-based firmware updates."),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Setup Components
        HoverCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Setup Components",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                bulletItem("Tipping Bucket Rain Gauge"),
                bulletItem(
                    "Temperature, Humidity, LUX & Pressure Shield (BME680, VEML7700)"),
                bulletItem("Data Logger with GSM, solar power & backup"),
                bulletItem("Solar Panel"),
                bulletItem("Wind Speed & Direction Sensors"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Feature item reusable widget
  static Widget featureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$title – $description",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Bullet item reusable widget
  static Widget bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final Widget child;
  const HoverCard({super.key, required this.child});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Card(
          elevation: _isHovered ? 10 : 4,
          shadowColor: Colors.blue.withOpacity(0.4),
          clipBehavior: Clip.antiAlias,
          child: widget.child,
        ),
      ),
    );
  }
}

// 🔹 FooterSection widget: centered vertical list (Email, Phone, Address)
//    Use this as bottomNavigationBar: bottomNavigationBar: const FooterSection()
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // SafeArea ensures footer stays above system nav (on mobile)
      child: Container(
        width: double.infinity,
        color: const Color(0xFF263238), // dark background
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min, // only as tall as content
          crossAxisAlignment: CrossAxisAlignment.center, // center horizontally
          children: [
            // Email (centered)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.email, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  "iot.aihub@gmail.com",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Phone (centered)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.phone, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  "+91 9876543210",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Address (centered)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_on, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  "IIT Ropar, Punjab, India",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
