
import 'package:cloud_sense_webapp/HomePage.dart';
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
          icon: Icon(Icons.arrow_back,  color: isDarkMode ? Colors.white : Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context); // 🔙 back to previous page
          },
        ),
       
        centerTitle: true,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,  // ✅ lets HeroSection draw behind AppBar
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeroSection(),
            SizedBox(height: 40),
            WhyChooseUsSection(),
            SizedBox(height: 0), // Reduced from any potential default spacing
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
    return Padding(
      padding: EdgeInsets.only(left: isSmallScreen ? 0 : 250),
      child: Text(
        "Advanced Weather Station",
        style: TextStyle(
          fontSize: isSmallScreen ? 28 : 38, // Smaller font for < 800, larger for ≥ 800
          fontWeight: FontWeight.bold,
          color:  isDarkMode ? Colors.white : Colors.black,
        ),
        textAlign: isSmallScreen ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  Widget _paragraph(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    return Padding(
      padding: EdgeInsets.only(left: isSmallScreen ? 0 : 250),
      child: Text(
        "The Advanced Weather Station is a modern, automated system that provides accurate, real-time weather data. "
        "It efficiently monitors rainfall, temperature, humidity, wind speed, and wind direction, helping industries make better decisions and manage operations effectively.",
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : 20, // Smaller font for < 800, larger for ≥ 800
          color:  isDarkMode ? Colors.white : Colors.black,
          height: 1.5,
        ),
        textAlign: isSmallScreen ? TextAlign.center : TextAlign.justify,
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
    double imgHeight = isSmallScreen ? 250 : 1000; // Smaller height for < 800, larger for ≥ 800

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



// ================= Why Choose Us Section =================
class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        bool isMobile = constraints.maxWidth < 800;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 100, // smaller padding on mobile
            vertical: 20, // Reduced from 40 to 20
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Why Choose Us?",
                style: TextStyle(
                  fontSize: isMobile ? 26 : 35, // responsive font size
                  fontWeight: FontWeight.bold,
                  color:  isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Features
              isMobile
                  ? Column(
                      children: features.map((f) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(f["icon"] as IconData,
                                  size: 50, color: Colors.blue),
                              const SizedBox(height: 12),
                              Text(
                                f["title"] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                f["desc"] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        final f = features[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(f["icon"] as IconData,
                                size: 50, color: Colors.blue),
                            const SizedBox(height: 12),
                            Text(
                              f["title"] as String,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:  isDarkMode ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              f["desc"] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        );
      },
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
        "desc":
            "Autonomous weather station for educational, agricultural, and environmental monitoring. Collects real-time data on rainfall, temperature, humidity, and solar radiation, powered by solar energy.",
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
        "desc":
            "Measures rainfall intensity and total amount with high accuracy.",
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
        "desc":
            "Protects sensors from direct sunlight and rain while allowing airflow.",
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
        "desc":
            "Wireless device for sensor data collection, logging, and cloud transmission.",
        "features": [
          "Bluetooth-enabled long-range communication",
          "Solar or battery powered",
          "Real-time data transmission to cloud/server"
        ]
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        bool isMobile = constraints.maxWidth < 600;
        bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1300; // Extended to include 1280

        int crossAxisCount = 4;
        if (isMobile) {
          crossAxisCount = 1;
        } else if (isTablet) {
          crossAxisCount = 2; // Increased to 3 for better tablet layout at 1280
        }

        return Container(
          color: Colors.grey[100],
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : (isTablet ? 60 : 120),
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Our Products",
                style: TextStyle(
                  fontSize: isMobile ? 28 : (isTablet ? 32 : 40), // Adjusted for tablet
                  fontWeight: FontWeight.bold,
                  color:   Colors.black ,
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
                  childAspectRatio: isMobile ? 0.9 : (isTablet ? 0.8 : 0.65), // Adjusted for tablet
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return HoverCard(product: product, isMobile: isMobile, isTablet: isTablet);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================= Hover Card =================
class HoverCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isMobile;
  final bool isTablet;
  const HoverCard({super.key, required this.product, required this.isMobile, required this.isTablet});

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
          padding: EdgeInsets.all(widget.isMobile ? 6 : (widget.isTablet ? 8 : 12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: widget.isMobile ? 1.8 : (widget.isTablet ? 1.5 : 1.3), // Adjusted for tablet
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.product["image"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${widget.product["title"]} ${widget.product["sku"]}",
                style: TextStyle(
                  fontSize: widget.isMobile ? 14 : (widget.isTablet ? 15 : 16), // Adjusted for tablet
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product["desc"],
                style: TextStyle(
                  fontSize: widget.isMobile ? 12 : (widget.isTablet ? 13 : 14), // Adjusted for tablet
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
                              size: widget.isMobile ? 14 : (widget.isTablet ? 15 : 16), // Adjusted for tablet
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: widget.isMobile ? 12 : (widget.isTablet ? 13 : 14), // Adjusted for tablet
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
                Icon(Icons.email, color:  isDarkMode ? Colors.white : Colors.black, size: 18),
                const SizedBox(width: 8),
                Text("iot.aihub@gmail.com",
                    style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone, color:  isDarkMode ? Colors.white : Colors.black, size: 18),
                const SizedBox(width: 8),
                Text("+91 9876543210",
                    style: TextStyle(color:  isDarkMode ? Colors.white : Colors.black, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color:  isDarkMode ? Colors.white : Colors.black, size: 18),
                const SizedBox(width: 8),
                Text("IIT Ropar, Punjab, India",
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
