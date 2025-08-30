import 'package:cloud_sense_webapp/download.dart';
import 'package:cloud_sense_webapp/footer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class ProbePage extends StatelessWidget {
  const ProbePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;
    final isIpadRange = screenWidth > 800 && screenWidth <= 1024;

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
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: isWideScreen ? 450 : 450,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: isWideScreen ? 450 : 450,
                            child: Image.asset(
                              "assets/thprobe.png",
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ).animate().fadeIn(duration: 600.ms).scale(
                                  duration: 800.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          ),
                        ),
                      ],
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
                                    Navigator.of(context)
                                        .pushReplacementNamed("/");
                                  }
                                },
                              ).animate().fadeIn(duration: 500.ms),
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
                                              color: const Color.fromARGB(
                                                  255, 219, 80, 145),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(duration: 700.ms).slideX(),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 6, bottom: 16),
                                      height: 3,
                                      width: isWideScreen ? 270 : 150,
                                      color: Colors.lightBlueAccent,
                                    ).animate().scaleX(
                                          duration: 800.ms,
                                          curve: Curves.easeOut,
                                        ),
                                    Text(
                                      "Accurate measurements for temperature and humidity",
                                      style: TextStyle(
                                        fontSize: isWideScreen ? 20 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ).animate().fadeIn(duration: 900.ms),
                                    const SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        BannerPoint(
                                            "Real-time temperature & humidity sensing for critical applications"),
                                        BannerPoint(
                                            "Provides both analog (0-1000)mV and digital (RS485) output"),
                                        BannerPoint(
                                            "Reliable Industrial grade monitoring with CRC validated communications"),
                                      ],
                                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                       _buildBannerButton(
  "Enquire",
  Colors.blue,
  () async {
    final email = "sharmasejal2701@gmail.com";
    final subject = "Product Enquiry";
    final body = "Hello, I am interested in your product.";

    if (kIsWeb) {
      // 🌐 Web: Open Gmail compose
      final Uri gmailUrl = Uri.parse(
        "https://mail.google.com/mail/?view=cm&fs=1"
        "&to=$email"
        "&su=${Uri.encodeComponent(subject)}"
        "&body=${Uri.encodeComponent(body)}",
      );

      if (await canLaunchUrl(gmailUrl)) {
        await launchUrl(gmailUrl, mode: LaunchMode.externalApplication);
      } else {
        // fallback to mailto if Gmail not available
        final Uri mailtoUri = Uri(
          scheme: 'mailto',
          path: email,
          query: Uri.encodeFull("subject=$subject&body=$body"),
        );
        if (await canLaunchUrl(mailtoUri)) {
          await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open email client")),
          );
        }
      }
    } else {
      // 📱 Mobile/Desktop apps: Use mailto
      final Uri mailtoUri = Uri(
        scheme: 'mailto',
        path: email,
        query: Uri.encodeFull("subject=$subject&body=$body"),
      );

      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open email app")),
        );
      }
    }
  },
),

                                        // _buildBannerButton(
                                        //   "Download Manual",
                                        //   Colors.teal,
                                        //   () {
                                        //     DownloadManager.downloadFile(
                                        //       context: context,
                                        //       sensorKey: "DataLogger",
                                        //       fileType: "manual",
                                        //     );
                                        //   },
                                        // ),
                                      ],
                                    ).animate().fadeIn(duration: 1000.ms),
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

                // ---------- Features & Applications ----------
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isWideScreen
                      ? _buildIpadLayout(isDarkMode)
                      : Column(
                          children: [
                            _buildFeaturesCard(isDarkMode)
                                .animate()
                                .fadeIn(),
                            const SizedBox(height: 16),
                            _buildApplicationsCard(isDarkMode)
                                .animate()
                                .fadeIn(),
                          ],
                        ),
                ),

                // ---------- Specs ----------
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWideScreen ? 1000 : double.infinity,
                      ),
                      child: _buildSpecificationsCard(context, isDarkMode)
                          .animate()
                          .fadeIn()
                          .slideY(begin: 0.2),
                    ),
                  ),
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

  // ---------- iPad Layout for Card Alignment ----------
  Widget _buildIpadLayout(bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final featuresCard = _buildFeaturesCard(isDarkMode)
            .animate()
            .slideX(begin: -0.3)
            .fadeIn();
        final applicationsCard = _buildApplicationsCard(isDarkMode)
            .animate()
            .slideX(begin: 0.3)
            .fadeIn();

        // Get the height of both cards
        final featuresKey = GlobalKey();
        final applicationsKey = GlobalKey();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final featuresBox = featuresKey.currentContext?.findRenderObject() as RenderBox?;
          final applicationsBox = applicationsKey.currentContext?.findRenderObject() as RenderBox?;
          if (featuresBox != null && applicationsBox != null) {
            final featuresHeight = featuresBox.size.height;
            final applicationsHeight = applicationsBox.size.height;
            if (featuresHeight != applicationsHeight) {
              // If heights differ, adjust the smaller card to be centered
              final maxHeight = featuresHeight > applicationsHeight
                  ? featuresHeight
                  : applicationsHeight;
              featuresBox.size = Size(featuresBox.size.width, maxHeight);
              applicationsBox.size = Size(applicationsBox.size.width, maxHeight);
            }
          }
        });

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  key: featuresKey,
                  child: featuresCard,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: SizedBox(
                  key: applicationsKey,
                  child: applicationsCard,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- Specifications Card ----------
  Widget _buildSpecificationsCard(BuildContext context, bool isDarkMode) {
    final List<String> specItems = [
      "Supply Voltage : 5-12 V DC",
      "Range of Temperature : -40 to +60 °C",
      "Range of humidity : 0-100%",
      "Communications Protocol : RS485 & 0-1V (ADC)",
      "Temperature Accuracy : ±0.1°C",
      "Humidity Accuracy: ±1.0% RH",
    ];

    return HoverCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Specifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Use a LayoutBuilder to determine screen width and adjust layout
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isWideScreen = screenWidth > 800;

                if (isWideScreen) {
                  // Two-column layout for wide screens
                  final int splitIndex = (specItems.length / 2).ceil();
                  final List<String> leftColumnItems = specItems.sublist(0, splitIndex);
                  final List<String> rightColumnItems = specItems.sublist(splitIndex);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: leftColumnItems
                              .map((item) => featureItem(item, isDarkMode))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: rightColumnItems
                              .map((item) => featureItem(item, isDarkMode))
                              .toList(),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Single-column layout for mobile
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: specItems
                        .map((item) => featureItem(item, isDarkMode))
                        .toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: _buildBannerButton(
                "Download Datasheet",
                Colors.teal,
                () {
                  DownloadManager.downloadFile(
                    context: context,
                    sensorKey: "TempHumidityProbe",
                    fileType: "datasheet",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(bool isDarkMode) {
    return HoverCard(
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
            featureItem("High precision temperature and humidity sensing probe",
                isDarkMode),
            featureItem("Compact low power design suitable for iot and embedded applications",
                isDarkMode),
            featureItem("Robust RS485/MODBUS RTU communications for industrial use",
                isDarkMode),
            featureItem("CRC validations provide reliable and error free data transfer",
                isDarkMode),
            featureItem(
                "Output provides both analog and digital value",
                isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsCard(bool isDarkMode) {
    return HoverCard(
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
            featureItem("IOT and agriculture irrigation system", isDarkMode),
            featureItem("Healthcare and Medical Facilities", isDarkMode),
            featureItem("Agriculture and Farming", isDarkMode),
            featureItem("Cold Storage and Warehouse", isDarkMode),
            featureItem("Food and Beverage Industry", isDarkMode),
            featureItem("Transportation and Logistics", isDarkMode),
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

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 20 : 12,
                vertical: isWideScreen ? 14 : 10,
              ),
              minimumSize: Size(isWideScreen ? 160 : 100, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 4,
            ),
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward,
                size: 18, color: Colors.white),
            label: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWideScreen ? 15 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            ..scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05),
                duration: 1200.ms, curve: Curves.easeInOut),
        );
      },
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
      ).animate().fadeIn(duration: 400.ms),
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
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        transform: _hovering
            ? (Matrix4.identity()..scale(1.01))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _hovering
              ? (isDarkMode ? Colors.blueGrey.shade700 : Colors.teal.shade50)
              : (isDarkMode ? Colors.grey.shade900 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (_hovering)
              BoxShadow(
                color: isDarkMode ? Colors.black54 : Colors.black26,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: widget.child,
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