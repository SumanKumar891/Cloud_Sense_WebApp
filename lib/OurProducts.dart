import 'package:cloud_sense_webapp/HomePage.dart';
import 'package:cloud_sense_webapp/dataLogger.dart';
import 'package:cloud_sense_webapp/windSensors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assuming ThemeProvider uses provider package

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // theme color
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context); // 🔙 back to previous page
          },
        ),

        centerTitle: true,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // ✅ lets HeroSection draw behind AppBar
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeroSection(),
            SizedBox(height: 40),
            SizedBox(height: 0), // Reduced from any potential default spacing
            PopularItemsSection(),
            SizedBox(height:0),
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.width > 800 ? 450 : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.isDarkMode
              ? [
                  const Color.fromARGB(255, 57, 57, 57),
                  const Color.fromARGB(255, 2, 54, 76),
                ]
              : [
                  const Color.fromARGB(255, 191, 242, 237),
                  const Color.fromARGB(255, 79, 106, 112),
                ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = MediaQuery.of(context).size.width < 800;

            return isSmallScreen
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _title(context),
                      const SizedBox(height: 16),
                      RightImageHover(),
                      const SizedBox(height: 16),
                      _paragraph(context),
                    ],
                  )
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
                              _title(context),
                              const SizedBox(height: 16),
                              _paragraph(context),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(child: RightImageHover()),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    bool isTabletScreen = MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width < 1200;

    return Padding(
      padding: EdgeInsets.only(
        left: isSmallScreen
            ? 0
            : (isTabletScreen ? 100 : 250), // Reduced padding for tablets
      ),
      child: Text(
        "Advanced Weather Station",
        style: TextStyle(
          fontSize: isSmallScreen
              ? 28
              : (isTabletScreen ? 32 : 38), // Adjusted for tablet
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        textAlign: isSmallScreen ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _paragraph(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    bool isTabletScreen = MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width < 1200;

    return Padding(
      padding: EdgeInsets.only(
        left: isSmallScreen
            ? 0
            : (isTabletScreen ? 100 : 250), // Reduced padding for tablets
      ),
      child: Text(
        "A modern, automated system that provides accurate, real-time weather data. "
        "It efficiently monitors rainfall, temperature, humidity, wind speed, and wind direction, helping industries make better decisions and manage operations effectively.",
        style: TextStyle(
          fontSize: isSmallScreen
              ? 16
              : (isTabletScreen
                  ? 18
                  : 20), // Smaller font for < 800, larger for ≥ 800
          color: isDarkMode ? Colors.white : Colors.black,
          height: 1.5,
        ),
        textAlign: isSmallScreen ? TextAlign.justify : TextAlign.justify,
      ),
    );
  }
}

// ================= Hoverable Right Image =================
class RightImageHover extends StatefulWidget {
  const RightImageHover({super.key});

  @override
  State<RightImageHover> createState() => _RightImageHoverState();
}

class _RightImageHoverState extends State<RightImageHover> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    double imgHeight = isSmallScreen
        ? 250
        : 1000; // Smaller height for < 800, larger for ≥ 800

    return Align(
      alignment: Alignment.topCenter,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered && !isSmallScreen ? 1.05 : 1.0,
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

// ================= Popular Items Section =================
class PopularItemsSection extends StatelessWidget {
  const PopularItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        "image": "assets/RainGauge.jpg",
        "title": "ARTH Sensor",
        "sku": "",
        "desc": "",
        "features": ["", "", ""]
      },
      {
        "image": "assets/RainGauge.jpg",
        "title": "ARTH Sensor Probe",
        "sku": "",
        "desc": "",
        "features": ["", "", ""]
      },
      {
        "image": "assets/RainGauge.jpg",
        "title": "Rain Gauge",
        "sku": "",
        "desc": "Measures rainfall intensity and total amount with high accuracy.",
        "features": [
          "Durable ABS construction",
          "Resolution: 0.2 mm or 0.5 mm",
          "Collection areas: 200 cm² or 314 cm²"
        ]
      },
      {
        "image": "assets/RadiationShield.jpg",
        "title": "Wind Speed",
        "sku": "",
        "desc": "Protects sensors from direct sunlight and rain while allowing airflow.",
        "features": [
          "Durable ABS material",
          "Ventilated multi-plate design",
          "Houses temperature, humidity, and light sensors"
        ]
      },
      {
        "image": "assets/DataLoggerGateway.jpg",
        "title": "Data Logger",
        "sku": "",
        "desc": "Wireless device for sensor data collection, logging, and cloud transmission.",
        "features": [
          "Bluetooth-enabled long-range communication",
          "Solar or battery powered",
          "Real-time data transmission to cloud/server"
        ]
      },
      {
        "image": "assets/weather_station.jpg",
        "title": "Gateway",
        "sku": "",
        "desc":
            "",
        "features": [
          "Real-time weather monitoring",
          "Solar-powered autonomous operation",
          "Supports multiple sensors"
        ]
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1300;

        int crossAxisCount = constraints.maxWidth < 800 ? 2 : 3;

        double childAspectRatio;
        if (constraints.maxWidth < 800) {
          childAspectRatio = 0.40;
        } else if (constraints.maxWidth < 1200) {
          childAspectRatio = 0.75;
        } else {
          childAspectRatio = 0.65;
        }

        return Container(
          color: Colors.grey[100],
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : (isTablet ? 60 : 300),
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Our Products",
                style: TextStyle(
                  fontSize: isMobile ? 28 : (isTablet ? 32 : 40),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return HoverCard(
                      product: product, isMobile: isMobile, isTablet: isTablet);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


// ================= Hover Card with Slide Down Details =================
class HoverCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isMobile;
  final bool isTablet;
  const HoverCard(
      {super.key,
      required this.product,
      required this.isMobile,
      required this.isTablet});

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
        padding: EdgeInsets.all(widget.isMobile ? 4 : (widget.isTablet ? 6 : 6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with animated size
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isHovered
                  ? (widget.isMobile ? 120.0 : (widget.isTablet ? 150.0 : 180.0))
                  : (widget.isMobile ? 150.0 : (widget.isTablet ? 180.0 : 200.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        widget.product["image"],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.black54),
                          shape: WidgetStateProperty.all(const CircleBorder()),
                        ),
                        onPressed: () {
                          if (widget.product["title"] == "Data Logger") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DataLoggerPage()),
                            );
                          } else if (widget.product["title"] == "Wind Speed") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UltrasonicSensorPage()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Text details always visible
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.product["title"]} ${widget.product["sku"]}",
                    style: TextStyle(
                      fontSize: widget.isMobile
                          ? 14
                          : (widget.isTablet ? 15 : 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product["desc"],
                    style: TextStyle(
                      fontSize: widget.isMobile
                          ? 12
                          : (widget.isTablet ? 13 : 14),
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (widget.product["features"] as List<String>)
                        .map((feature) => Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  size: widget.isMobile
                                      ? 14
                                      : (widget.isTablet ? 15 : 16),
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: widget.isMobile
                                          ? 12
                                          : (widget.isTablet ? 13 : 14),
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.isDarkMode
                ? [
                    const Color.fromARGB(255, 57, 57, 57),
                    const Color.fromARGB(255, 2, 54, 76),
                  ]
                : [
                    const Color.fromARGB(255, 191, 242, 237),
                    const Color.fromARGB(255, 79, 106, 112),
                  ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email,
                    color: isDarkMode ? Colors.white : Colors.black, size: 18),
                const SizedBox(width: 8),
                Text("iot.aihub@gmail.com",
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone,
                    color: isDarkMode ? Colors.white : Colors.black, size: 18),
                const SizedBox(width: 8),
                Text("+91 9876543210",
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on,
                    color: isDarkMode ? Colors.white : Colors.black, size: 18),
                const SizedBox(width: 8),
                Text("IIT Ropar, Punjab, India",
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
