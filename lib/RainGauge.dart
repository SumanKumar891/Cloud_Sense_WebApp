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
                  ? [const Color(0xFFC0B9B9), const Color(0xFF7B9FAE)]
                  : [const Color(0xFF7EABA6), const Color(0xFF363A3B)],
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
                      "assets/Rain_GaugeBg.jpg",
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
                                        fontSize: isWideScreen ? 20 : 14,
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
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 250,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Image.asset("assets/Rbase01.png"),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height: 300,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Image.asset("assets/Raingauge02.jpg"),
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
                                      featureItem("Rainwater is collected by a funnel and directed into a balanced tipping bucket mechanism.", isDarkMode),
                                      featureItem("When a bucket fills to a preset volume (e.g., 0.2 mm of rainfall)", isDarkMode),
                                      featureItem("Each tip is detected by a reed switch or magnetic sensor.", isDarkMode),
                                      featureItem("Pulses are recorded and converted into total rainfall measurement.", isDarkMode),
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
                                  height: 160,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Image.asset("assets/Rbase01.png"),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 160,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Image.asset("assets/Raingauge02.jpg"),
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
                                featureItem("Rainwater is collected by a funnel and directed into a balanced tipping bucket mechanism.", isDarkMode),
                                featureItem("When a bucket fills to a preset volume (e.g., 0.2 mm of rainfall)", isDarkMode),
                                featureItem("Each tip is detected by a reed switch or magnetic sensor.", isDarkMode),
                                featureItem("Pulses are recorded and converted into total rainfall measurement.", isDarkMode),
                                const SizedBox(height: 16),
                                _buildBannerButton("DOWNLOAD DATASHEET", Colors.teal),
                              ],
                            ),
                    ),
                  ),
                ),

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
            featureItem("Rainwater is collected by a funnel and directed into a balanced tipping bucket mechanism.", isDarkMode),
            featureItem("When a bucket fills to a preset volume (e.g., 0.2 mm of rainfall), it tips, empties, and positions the other bucket to collect the next sample.", isDarkMode),
            featureItem("Each tip is detected by a reed switch or magnetic sensor.", isDarkMode),
            featureItem("The pulses are recorded and converted into total rainfall.)", isDarkMode),
            featureItem("The design ensures accuracy even under varying rainfall intensities.", isDarkMode),
            featureItem("Minimal moving parts provide long-term reliability with low maintenance.", isDarkMode),
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
            featureItem("Made of ABS material, offering good durability and weather resistance.", isDarkMode),
            featureItem("Available in two diameter options: 159.5 mm and 200 mm.", isDarkMode),
            featureItem("Collection areas: 200 cm² and 314 cm².", isDarkMode),
            featureItem("Resolution: 0.2 mm or 0.5 mm depending on the model.", isDarkMode),
            featureItem("Suitable for both precise and general-purpose rainfall monitoring.", isDarkMode),
            featureItem("Data Output: Number of tips × Resolution = Total Rainfall.", isDarkMode),
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
