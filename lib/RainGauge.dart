import 'package:cloud_sense_webapp/footer.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

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
                      "assets/raingaugebg.jpg",
                      height: isWideScreen ? 450 : 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                    Container(
                      height: isWideScreen ? 450 : 350,
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
                                            text: "Rain ",
                                            style: TextStyle(
                                              fontSize: isWideScreen ? 48 : 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Gauge",
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
                                      "Type: Tipping Bucket Rain Gauge",
                                      style: TextStyle(
                                        fontSize: isWideScreen ? 20 : 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        BannerPoint("Collects rain via funnel mechanism"),
                                        BannerPoint("Each tip equals preset rainfall volume"),
                                        BannerPoint("Pulse recorded & converted to rainfall"),
                                        BannerPoint("Accurate & low maintenance"),
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

                // 👇 Updated Technical Overview with 2 images
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
                                      // 👇 Images grouped together
                                      // 👇 Images grouped together (right aligned)
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Align(
                                          alignment: Alignment.center, // 👈 right align
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min, // 👈 images jitna space utna hi lenge
                                            children: [
                                              SizedBox(
                                                height: 260,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Image.asset("assets/rbase.png"),
                                                ),
                                              ),
                                              const SizedBox(width: 8), // 👈 optional: dono images ke beech thoda gap
                                              SizedBox(
                                                height: 260,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Image.asset("assets/rain.jpg"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // 👇 Text Section (bilkul chipka diya)
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Technical Overview",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            featureItem("Made of ABS material, offering durability and weather resistance", isDarkMode),
                                            featureItem("Available in two diameter options: 159.5 mm and 200 mm", isDarkMode),
                                            featureItem("Collection areas: 200 cm² and 314 cm²", isDarkMode),
                                            featureItem("Resolution: 0.2 mm or 0.5 mm depending on the model", isDarkMode),
                                            featureItem("Equipped with reed switch or magnetic sensor for tip detection", isDarkMode),
                                            featureItem("Data Output: Number of tips × Resolution = Total Rainfall", isDarkMode),
                                            featureItem("Suitable for both precise and general-purpose rainfall monitoring", isDarkMode),
                                            const SizedBox(height: 16),
                                            _buildBannerButton("DOWNLOAD DATASHEET", Colors.teal),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )

                                // 👇 Mobile layout
                                : Column(
                                    children: [
                                      SizedBox(
                                        height: 160,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset("assets/rbase.png"),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 160,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset("assets/rain.jpg"),
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
                                      featureItem("Made of ABS material, offering durability and weather resistance", isDarkMode),
                                      featureItem("Available in two diameter options: 159.5 mm and 200 mm", isDarkMode),
                                      featureItem("Collection areas: 200 cm² and 314 cm²", isDarkMode),
                                      featureItem("Resolution: 0.2 mm or 0.5 mm depending on the model", isDarkMode),
                                      featureItem("Equipped with reed switch or magnetic sensor for tip detection", isDarkMode),
                                      featureItem("Data Output: Number of tips × Resolution = Total Rainfall", isDarkMode),
                                      featureItem("Suitable for both precise and general-purpose rainfall monitoring", isDarkMode),
                                      const SizedBox(height: 16),
                                      _buildBannerButton("DOWNLOAD DATASHEET", Colors.teal),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                              // 👇 Updated Technical Overview with 3 images
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
                                      // 👇 Images grouped together (3 images - no overflow)
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Align(
                                          alignment: Alignment.centerRight, // 👈 thoda right aligned
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: SizedBox(
                                                  height: 260,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Image.asset("assets/RainGaugeCylinder.jpg"),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: SizedBox(
                                                  height: 260,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Image.asset("assets/RainGaugeSeeSaw.jpg"),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: SizedBox(
                                                  height: 260,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Image.asset("assets/RainGaugeBase.jpg"), // 👈 new 3rd image
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),


                                      // 👇 Text Section
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15), // 👈 left side se 24px push
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "3D Specifications",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode ? Colors.white : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                          DefaultTabController(
  length: 3,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TabBar(
        labelColor: Colors.teal,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.teal,
        tabs: [
          Tab(text: "Cylinder"),
          Tab(text: "See-Saw"),
          Tab(text: "Base"),
        ],
      ),
      SizedBox(
        height: 280, // fixed height for content
        child: TabBarView(
          children: [
            // Cylinder Tab
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  featureItem("Overall height: 301.50 mm", isDarkMode),
                  featureItem("Outer diameter (OD): Ø159.50 mm", isDarkMode),
                  featureItem("Top/cover plate OD: Ø163.50 mm", isDarkMode),
                  featureItem("Central bore (lower view): Ø39.72 mm", isDarkMode),
                  featureItem("Small side/boss hole: Ø32.57 mm", isDarkMode),
                  featureItem("Drill/through hole: Ø4.20 mm", isDarkMode),
                ],
              ),
            ),

            // See-Saw Tab
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  featureItem("Arc/chord length (bucket profile): ≈100.01 mm", isDarkMode),
                  featureItem("Bucket height (profile): ≈51.05 mm", isDarkMode),
                  featureItem("Block height: ≈34.00 mm", isDarkMode),
                  featureItem("Block width: ≈24.76 mm", isDarkMode),
                  featureItem("Pin/feature spacing: ≈20.04 mm", isDarkMode),
                  featureItem("Pin/shaft diameter: ≈5.20 mm", isDarkMode),
                ],
              ),
            ),

            // Base Tab
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  featureItem("Base outer radius: R81.75 (OD Ø163.50 mm)", isDarkMode),
                  featureItem("Boss/post spacing: 57.00 mm", isDarkMode),
                  featureItem("Post height: 52.00 mm", isDarkMode),
                  featureItem("Fillet radius on ribs: R10.00", isDarkMode),
                  featureItem("Feature span across base: 96.10 mm", isDarkMode),
                  featureItem("Boss diameter: Ø14.80 mm", isDarkMode),
                  featureItem("Slot length (typ.): 33.00 mm", isDarkMode),
                  featureItem("Lower platform width: 113.75 mm", isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

                                            
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )

                                // 👇 Mobile layout with 3 images
                                : Column(
                                    children: [
                                      SizedBox(
                                        height: 160,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset("assets/RainGaugeCylinder.jpg"),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 160,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset("assets/RainGaugeSeeSaw.jpg"),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 160,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset("assets/RainGaugeBase.jpg"), // 👈 new 3rd image
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "3D Specifications",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                     Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ExpansionTile(
      title: Text("Cylinder (Collector Body)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          )),
      children: [
        featureItem("Overall height: 301.50 mm", isDarkMode),
        featureItem("Outer diameter (OD): Ø159.50 mm", isDarkMode),
        featureItem("Top/cover plate OD: Ø163.50 mm", isDarkMode),
        featureItem("Central bore (lower view): Ø39.72 mm", isDarkMode),
        featureItem("Small side/boss hole: Ø32.57 mm", isDarkMode),
        featureItem("Drill/through hole: Ø4.20 mm", isDarkMode),
      ],
    ),
    ExpansionTile(
      title: Text("See-Saw (Tipping Bucket Assembly)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          )),
      children: [
        featureItem("Arc/chord length (bucket profile): ≈100.01 mm", isDarkMode),
        featureItem("Bucket height (profile): ≈51.05 mm", isDarkMode),
        featureItem("Block height: ≈34.00 mm", isDarkMode),
        featureItem("Block width: ≈24.76 mm", isDarkMode),
        featureItem("Pin/feature spacing: ≈20.04 mm", isDarkMode),
        featureItem("Pin/shaft diameter: ≈5.20 mm", isDarkMode),
      ],
    ),
    ExpansionTile(
      title: Text("Base (Electronics/Mechanism Mount)",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          )),
      children: [
        featureItem("Base outer radius: R81.75 (OD Ø163.50 mm)", isDarkMode),
        featureItem("Boss/post spacing: 57.00 mm", isDarkMode),
        featureItem("Post height: 52.00 mm", isDarkMode),
        featureItem("Fillet radius on ribs: R10.00", isDarkMode),
        featureItem("Feature span across base: 96.10 mm", isDarkMode),
        featureItem("Boss diameter: Ø14.80 mm", isDarkMode),
        featureItem("Slot length (typ.): 33.00 mm", isDarkMode),
        featureItem("Lower platform width: 113.75 mm", isDarkMode),
      ],
    ),
  ],
)

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
            featureItem("Balanced tipping bucket mechanism ensures high accuracy", isDarkMode),
            featureItem("Minimal moving parts → long-term reliability with low maintenance", isDarkMode),
            featureItem("Reed switch / magnetic sensor for precise detection", isDarkMode),
            featureItem("Accurate even under varying rainfall intensities.)", isDarkMode),
            featureItem("Durable ABS body with weather resistance", isDarkMode),
            featureItem("Easy integration with data loggers and weather stations for automated rainfall recording", isDarkMode),
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
            featureItem("Meteorological stations for rainfall monitoring", isDarkMode),
            featureItem("Agriculture & irrigation planning", isDarkMode),
            featureItem("Flood forecasting & hydrological studies", isDarkMode),
            featureItem("Environmental monitoring & climate research", isDarkMode),
            featureItem("Urban stormwater management", isDarkMode),
            featureItem("Suitable for both precise scientific research and general-purpose field monitoring", isDarkMode),
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