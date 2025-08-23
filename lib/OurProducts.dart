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
        backgroundColor: const Color(0xFF083C4A), // theme color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context); // 🔙 back to previous page
          },
        ),
        // title: const Text(
        // "OUR PRODUCTS",
        // style: TextStyle(
        // fontSize: 24,
        // fontWeight: FontWeight.bold,
        // color: Colors.white,
        // ),
        // ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeroSection(),
            SizedBox(height: 40),
            WhyChooseUsSection(),
            SizedBox(height: 0),
            PopularItemsSection(),
            SizedBox(height: 0),
            FooterSection(), // <-- footer now scrolls with content
          ],
        ),
      ),
    );
  }
}


// ================= Hero Section =================
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height sirf desktop pe fix, mobile pe auto
      height: MediaQuery.of(context).size.width > 800 ? 450 : null,
      color: const Color(0xFF083C4A),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;

            return isMobile
                // 📱 Mobile: Heading → Image → Paragraph
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _title(isMobile: true),
                      const SizedBox(height: 16),
                      const RightImageHover(isMobile: true),
                      const SizedBox(height: 16),
                      _paragraph(isMobile: true),
                    ],
                  )
                // 💻 Web: Left text → Right image (same as pehle)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _title(isMobile: false),
                              const SizedBox(height: 16),
                              _paragraph(isMobile: false),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      const Expanded(child: RightImageHover(isMobile: false)),
                    ],
                  );
          },
        ),
      ),
    );
  }

  // ✅ Title
  Widget _title({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.only(left: isMobile ? 0 : 300),
      child: Text(
        "Advanced Weather Station",
        style: TextStyle(
          fontSize: isMobile ? 28 : 46,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: isMobile ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  // ✅ Paragraph
  Widget _paragraph({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.only(left: isMobile ? 0 : 300),
      child: Text(
        "The Advanced Weather Station is a modern, automated system that provides accurate, real-time weather data. "
        "It efficiently monitors rainfall, temperature, humidity, wind speed, and wind direction, helping industries make better decisions and manage operations effectively.",
        style: TextStyle(
          fontSize: isMobile ? 16 : 23,
          color: Colors.white70,
          height: 1.5,
        ),
        textAlign: isMobile ? TextAlign.center : TextAlign.justify,
      ),
    );
  }
}

// ================= Hoverable Right Image =================
class RightImageHover extends StatefulWidget {
  final bool isMobile;
  const RightImageHover({super.key, required this.isMobile});

  @override
  State<RightImageHover> createState() => _RightImageHoverState();
}

class _RightImageHoverState extends State<RightImageHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    double imgHeight = widget.isMobile ? 250 : 1000;

    return Align(
      alignment: Alignment.topCenter,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered && !widget.isMobile ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: imgHeight,
            child: Image.asset(
              "assets/bgremover.png",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ================= Right Curve Clipper =================
// class RightCurveClipper extends CustomClipper<Path> {
// @override
// Path getClip(Size size) {
// Path path = Path();
// path.lineTo(size.width * 0.7, 0);
// path.quadraticBezierTo(
// size.width, size.height / 2,
// size.width * 0.7, size.height,
// );
// path.lineTo(0, size.height);
// path.close();
// return path;
// }

// @override
// bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// ================= Why Choose Us Section =================
class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        "icon": Icons.solar_power,
        "title": "Solar Powered",
        "desc": "Runs on solar energy for efficient, remote operation."
      },
      {
        "icon": Icons.wifi,
        "title": "Wireless Connectivity",
        "desc": "GSM 4G with dual SIM ensures reliable, always-on data transfer."
      },
      {
        "icon": Icons.access_time,
        "title": "Real-Time Monitoring",
        "desc": "Collects multi-sensor data for live climate insights."
      },
      {
        "icon": Icons.cloud,
        "title": "Cloud Integration",
        "desc": "Supports MQTT, HTTP, FTP for AWS IoT, APIs, or govt. servers."
      },
      {
        "icon": Icons.shield,
        "title": "Rugged IP67 Design",
        "desc": "Weatherproof, dustproof, impact-resistant for outdoor use."
      },
      {
        "icon": Icons.system_update,
        "title": "Dual SIM & OTA Updates",
        "desc": "Enhanced connectivity with SMS-based firmware updates."
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 400, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Why Choose US?",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: isMobile ? 2.5 : 1.8,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final f = features[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(f["icon"] as IconData, size: 40, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        f["title"] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        f["desc"] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================= Popular Items Section =================
class PopularItemsSection extends StatelessWidget {
  const PopularItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        "image": "assets/weather_station.jpg",
        "title": "Advanced Weather Station",
        "sku": "AWS001",
        "desc": "Autonomous weather station for educational, agricultural, and environmental monitoring. Collects real-time data on rainfall, temperature, humidity, and solar radiation, powered by solar energy.",
        "features": [
          "Real-time weather monitoring",
          "Solar-powered autonomous operation",
          "Supports multiple sensors"
        ]
      },
      {
        "image": "assets/RainGauge.jpg",
        "title": "Tipping Bucket Rain Gauge",
        "sku": "RBG-TB",
        "desc": "Measures rainfall intensity and total amount with high accuracy.",
        "features": [
          "Durable ABS construction",
          "Resolution: 0.2 mm or 0.5 mm",
          "Collection areas: 200 cm² or 314 cm²"
        ]
      },
      {
        "image": "assets/RadiationShield.jpg",
        "title": "Radiation Shield",
        "sku": "RS-12",
        "desc": "Protects sensors from direct sunlight and rain while allowing airflow.",
        "features": [
          "Durable ABS material",
          "Ventilated multi-plate design",
          "Houses temperature, humidity, and light sensors"
        ]
      },
      {
        "image": "assets/DataLoggerGateway.jpg",
        "title": "Data Logger / Gateway",
        "sku": "DLG-01",
        "desc": "Wireless device for sensor data collection, logging, and cloud transmission.",
        "features": [
          "Bluetooth-enabled long-range communication",
          "Solar or battery powered",
          "Real-time data transmission to cloud/server"
        ]
      },
    ];

    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 300, vertical: 30), // <- changed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Our Products",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.6, // <- changed
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return HoverCard(product: product); // <- updated hover
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================= Hover Card =================
class HoverCard extends StatefulWidget {
  final Map<String, dynamic> product;
  const HoverCard({super.key, required this.product});

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
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black26 : Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.product["image"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${widget.product["title"]} ${widget.product["sku"]}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.product["desc"],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (widget.product["features"] as List<String>)
                    .map((feature) => Row(
                          children: [
                            const Icon(Icons.check,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Footer Section =================
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        color: const Color(0xFF263238),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.email, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text("iot.aihub@gmail.com",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.phone, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text("+91 9876543210",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_on, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text("IIT Ropar, Punjab, India",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}