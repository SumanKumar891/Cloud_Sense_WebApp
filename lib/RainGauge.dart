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
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeroSection(),
            SizedBox(height: 40),
            FeaturesApplicationsSection(), // 👈 New Section here
            SizedBox(height: 40),
            SizedBox(height: 0),
            SizedBox(height: 0),
            FooterSection(),
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
    bool isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Container(
      height: MediaQuery.of(context).size.width > 800 ? 500 : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 👇 background image
          Image.asset(
            "assets/RainGaugeBg.jpg",
            fit: BoxFit.cover,
          ),

          // 👇 dark overlay
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // 👇 actual content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
            child: isSmallScreen
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _title(),
                      const SizedBox(height: 16),
                      _subtitle(),
                      const SizedBox(height: 16),
                      _bullets(),
                      const SizedBox(height: 24),
                      _buttons(),
                      const SizedBox(height: 24),
                      // _rightImage(),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _title(),
                              const SizedBox(height: 16),
                              _subtitle(),
                              const SizedBox(height: 16),
                              _bullets(),
                              const SizedBox(height: 24),
                              _buttons(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Expanded(
                      //   flex: 4,
                      //   child: _rightImage(),
                      // ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: "Rain ",
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: "Gauge",
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subtitle() {
    return const Text(
      "Type: Tipping Bucket Rain Gauge",
      style: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _bullets() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• Rainwater is collected by a funnel and directed into a balanced tipping bucket mechanism.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "• When a bucket fills to a preset volume (e.g., 0.2 mm of rainfall), it tips and empties automatically.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "• Each tip is detected by a reed switch or magnetic sensor.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "• Pulses are recorded and converted into total rainfall measurement.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buttons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 240, 238, 238),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          ),
          child: const Text("ENQUIRE"),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          ),
          child: const Text("DATASHEETS"),
        ),
      ],
    );
  }

  // Widget _rightImage() {
  //   return Center(
  //     child: Image.asset(
  //       "assets/product1.png", // 👈 ek hi product image
  //       height: 280,
  //     ),
  //   );
  // }
}

// ================= Features & Applications Section =================
class FeaturesApplicationsSection extends StatelessWidget {
  const FeaturesApplicationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 900;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: isSmallScreen
          ? Column(
              children: [
                _buildCard(
                    "Working Principle",
                    [
                      "Rainwater is collected by a funnel and directed into a balanced tipping bucket mechanism.",
                      "When a bucket fills to a preset volume (e.g., 0.2 mm of rainfall), it tips, empties, and positions the other bucket to collect the next sample.",
                      "Each tip is detected by a reed switch or magnetic sensor.",
                      "The pulses are recorded and converted into total rainfall.",
                      "The design ensures accuracy even under varying rainfall intensities.",
                      "Minimal moving parts provide long-term reliability with low maintenance.",
                    ],
                    isDarkMode),
                const SizedBox(height: 20),
                _buildCard(
                    "Specifications",
                    [
                      "Made of ABS material, offering good durability and weather resistance.",
                      "Available in two diameter options: 159.5 mm and 200 mm.",
                      "Collection areas: 200 cm² and 314 cm².",
                      "Resolution: 0.2 mm or 0.5 mm depending on the model.",
                      "Suitable for both precise and general-purpose rainfall monitoring.",
                      "Data Output: Number of tips × Resolution = Total Rainfall.",
                    ],
                    isDarkMode),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCard(
                      "Working Principle",
                      [
                        "Rainwater is collected by a funnel and directed into a balanced tipping bucket mechanism.",
                        "When a bucket fills (e.g., 0.2 mm rain), it tips, empties, and resets for the next sample.",
                        "Each tip is detected by a reed switch or magnetic sensor.",
                        "The pulses are recorded and converted into total rainfall.",
                        "The design ensures accuracy even under varying rainfall intensities.",
                        "Minimal moving parts provide long-term reliability with low maintenance.",
                      ],
                      isDarkMode),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCard(
                      "Specifications",
                      [
                        "Made of ABS material, offering good durability and weather resistance.",
                        "Available in two diameter options: 159.5 mm and 200 mm.",
                        "Collection areas: 200 cm² and 314 cm².",
                        "Resolution: 0.2 mm or 0.5 mm depending on the model.",
                        "Suitable for both precise and general-purpose rainfall monitoring.",
                        "Data Output: Number of tips × Resolution = Total Rainfall.",
                      ],
                      isDarkMode),
                ),
              ],
            ),
    );
  }

  Widget _buildCard(String title, List<String> items, bool isDarkMode) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: Colors.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item,
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                      ),
                    ],
                  ),
                )),
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
