import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class WeatherForecastPage extends StatefulWidget {
  final String deviceName;
  final String sequentialName;

  const WeatherForecastPage({
    required this.deviceName,
    required this.sequentialName,
    Key? key,
  }) : super(key: key);

  @override
  _WeatherForecastPageState createState() => _WeatherForecastPageState();
}

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  final String tomorrowApiKey = 'LJNygvkcVfaz1Z1Wni5qALsqKSZ5hzbw';

  List<Map<String, dynamic>> forecastResults = [];
  bool _isForecastLoading = false;
  String _forecastError = '';
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');

  final Map<int, Map<String, dynamic>> weatherCodeMap = {
    1000: {
      'desc': 'Clear',
      'icon': Icons.wb_sunny,
      'gradient': [Colors.orange, Colors.yellow]
    },
    1001: {
      'desc': 'Cloudy',
      'icon': Icons.cloud,
      'gradient': [Colors.grey, Colors.blueGrey]
    },
    1100: {
      'desc': 'Mostly Clear',
      'icon': Icons.wb_cloudy,
      'gradient': [Colors.yellow, Colors.lightBlue]
    },
    1101: {
      'desc': 'Partly Cloudy',
      'icon': Icons.cloud_queue,
      'gradient': [Colors.lightBlue, Colors.white]
    },
    1102: {
      'desc': 'Mostly Cloudy',
      'icon': Icons.cloud_outlined,
      'gradient': [Colors.grey, Colors.white]
    },
    2000: {
      'desc': 'Fog',
      'icon': Icons.blur_on,
      'gradient': [Colors.grey, Colors.grey]
    },
    2100: {
      'desc': 'Light Fog',
      'icon': Icons.blur_linear,
      'gradient': [Colors.grey, Colors.white]
    },
    3000: {
      'desc': 'Light Wind',
      'icon': Icons.air,
      'gradient': [Colors.lightBlue, Colors.cyan]
    },
    3001: {
      'desc': 'Wind',
      'icon': Icons.air_rounded,
      'gradient': [Colors.blue, Colors.cyan]
    },
    3002: {
      'desc': 'Strong Wind',
      'icon': Icons.air_rounded,
      'gradient': [Colors.blueGrey, Colors.blue]
    },
    4000: {
      'desc': 'Drizzle',
      'icon': Icons.grain,
      'gradient': [Colors.blue, Colors.lightBlue]
    },
    4001: {
      'desc': 'Rain',
      'icon': Icons.beach_access,
      'gradient': [Colors.blue, Colors.blueGrey]
    },
    4200: {
      'desc': 'Light Rain',
      'icon': Icons.grain,
      'gradient': [
        const Color.fromARGB(255, 34, 165, 226),
        const Color.fromARGB(255, 90, 169, 234)
      ]
    },
    4201: {
      'desc': 'Heavy Rain',
      'icon': Icons.invert_colors,
      'gradient': [Colors.blueGrey, Colors.blue]
    },
    5000: {
      'desc': 'Snow',
      'icon': Icons.ac_unit,
      'gradient': [Colors.white, Colors.lightBlue]
    },
    5001: {
      'desc': 'Flurries',
      'icon': Icons.ac_unit,
      'gradient': [Colors.white, Colors.grey]
    },
    5100: {
      'desc': 'Light Snow',
      'icon': Icons.ac_unit,
      'gradient': [Colors.white, Colors.lightBlue]
    },
    5101: {
      'desc': 'Heavy Snow',
      'icon': Icons.ac_unit,
      'gradient': [Colors.white, Colors.blueGrey]
    },
    6000: {
      'desc': 'Freezing Drizzle',
      'icon': Icons.ac_unit,
      'gradient': [Colors.lightBlue, Colors.grey]
    },
    6001: {
      'desc': 'Freezing Rain',
      'icon': Icons.ac_unit,
      'gradient': [Colors.blue, Colors.grey]
    },
    6200: {
      'desc': 'Light Freezing Rain',
      'icon': Icons.ac_unit,
      'gradient': [Colors.lightBlue, Colors.white]
    },
    6201: {
      'desc': 'Heavy Freezing Rain',
      'icon': Icons.ac_unit,
      'gradient': [Colors.blueGrey, Colors.white]
    },
    7000: {
      'desc': 'Ice Pellets',
      'icon': Icons.ac_unit,
      'gradient': [Colors.grey, Colors.white]
    },
    7101: {
      'desc': 'Heavy Ice Pellets',
      'icon': Icons.ac_unit,
      'gradient': [Colors.grey, Colors.blueGrey]
    },
    7102: {
      'desc': 'Light Ice Pellets',
      'icon': Icons.ac_unit,
      'gradient': [Colors.grey, Colors.white]
    },
    8000: {
      'desc': 'Thunderstorm',
      'icon': Icons.flash_on,
      'gradient': [Colors.purple, Colors.blueGrey]
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchWeatherForecast();
  }

  Future<Map<String, String>> getGeoData(double? lat, double? lon) async {
    if (lat == null || lon == null) {
      return {
        'place': 'Unknown',
        'state': 'Unknown',
        'country': 'Unknown',
      };
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isEmpty) {
        throw Exception('No placemarks found');
      }

      final place = placemarks.first;

      return {
        'place': place.locality ?? place.subAdministrativeArea ?? 'Unknown',
        'state': place.administrativeArea ?? 'Unknown',
        'country': place.country ?? 'Unknown',
      };
    } catch (e) {
      print('Failed to get placemark: $e');
      return {
        'place': 'Unknown',
        'state': 'Unknown',
        'country': 'Unknown',
      };
    }
  }

  Future<void> _fetchWeatherForecast() async {
    setState(() {
      _isForecastLoading = true;
      _forecastError = '';
      forecastResults.clear();
    });

    try {
      final endDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final startDate = DateFormat('dd-MM-yyyy')
          .format(DateTime.now().subtract(const Duration(days: 180)));

      final deviceIdRaw = widget.deviceName.replaceAll(RegExp(r'[^0-9]'), '');
      final numericId = int.tryParse(deviceIdRaw) ?? -1;

      if (numericId == -1) {
        throw Exception(
            'Invalid numeric device ID from "${widget.deviceName}"');
      }

      final awsApiUrl =
          'https://wf3uh3yhn7.execute-api.us-east-1.amazonaws.com/default/Awadh_Jio_Data_Api_func?Device_ID=$numericId&start_date=$startDate&end_date=$endDate';

      final awsResponse = await http.get(Uri.parse(awsApiUrl));
      if (awsResponse.statusCode != 200) {
        throw Exception('AWS API failed: ${awsResponse.statusCode}');
      }

      final awsJson = jsonDecode(awsResponse.body);
      final List<dynamic> dataList = awsJson['items'] ?? [];

      if (dataList.isEmpty) {
        throw Exception('No data found for Device $numericId');
      }

      final firstSensor = dataList.firstWhere(
        (sensor) =>
            double.tryParse(sensor['Latitude'].toString()) != 0 &&
            double.tryParse(sensor['Longitude'].toString()) != 0,
        orElse: () => throw Exception('No valid lat/lon found'),
      );

      final deviceId = firstSensor['Device_ID'].toString();
      final lat = double.tryParse(firstSensor['Latitude'].toString());
      final lon = double.tryParse(firstSensor['Longitude'].toString());
      final imei = firstSensor['IMEI_Number'].toString();

      if (lat == null || lon == null) {
        throw Exception('Invalid lat/lon values');
      }

      final forecast = await _fetchForecastForLocation(lat, lon);
      final geo = await getGeoData(lat, lon);

      setState(() {
        forecastResults.add({
          'sensor': {
            'deviceId': deviceId,
            'lat': lat,
            'lon': lon,
            'IMEI_Number': imei,
            'place': geo['place'],
            'state': geo['state'],
            'country': geo['country'],
          },
          'forecast': forecast,
        });
        _isForecastLoading = false;
      });
    } catch (e) {
      setState(() {
        _forecastError = e.toString();
        _isForecastLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchForecastForLocation(
      double lat, double lon) async {
    final url =
        'https://api.tomorrow.io/v4/weather/forecast?location=$lat,$lon&timesteps=1h&units=metric&apikey=$tomorrowApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      print('Error response: ${response.body}');
      throw Exception(
          'Tomorrow.io fetch failed: ${response.statusCode} - ${response.body}');
    }
    return jsonDecode(response.body);
  }

  String formatDisplayDate(String date) {
    final today = DateTime.now().toLocal();
    final tomorrow = today.add(const Duration(days: 1));
    final parsedDate = DateTime.parse(date);
    final dateFormat = DateFormat('dd MMM');

    if (date == today.toIso8601String().substring(0, 10)) {
      return '${dateFormat.format(parsedDate)}  Today';
    } else if (date == tomorrow.toIso8601String().substring(0, 10)) {
      return '${dateFormat.format(parsedDate)}  Tomorrow';
    } else {
      return '${dateFormat.format(parsedDate)}  ${DateFormat('E').format(parsedDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isForecastLoading || forecastResults.isEmpty
                ? [
                    Colors.blue.shade300, // Softer blue for loading
                    Colors.blue.shade100,
                  ]
                : () {
                    // Use the same 'current' forecast entry as the UI
                    final forecastList =
                        forecastResults[0]['forecast']['timelines']['hourly'];
                    final now = DateTime.now().toUtc();
                    final roundedNow =
                        DateTime.utc(now.year, now.month, now.day, now.hour)
                            .add(Duration(hours: now.minute >= 30 ? 1 : 0));
                    final filteredForecast = forecastList.where((item) {
                      final forecastTime = DateTime.parse(item['time']).toUtc();
                      return forecastTime.isAfter(roundedNow);
                    }).toList();
                    final current = filteredForecast.isNotEmpty
                        ? filteredForecast[0]
                        : forecastList.last;
                    final weatherCode = current['values']['weatherCode'];
                    return weatherCodeMap[weatherCode]?['gradient'] ??
                        [Colors.blue.shade300, Colors.blue.shade100];
                  }(),
          ),
        ),
        child: SafeArea(
          child: _isForecastLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _forecastError.isNotEmpty
                  ? Center(
                      child: Text(
                        'Error: $_forecastError',
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  : forecastResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No forecast data available.',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            final sensor = forecastResults[index]['sensor'];
                            final forecastList = forecastResults[index]
                                ['forecast']['timelines']['hourly'];
                            final now = DateTime.now()
                                .toUtc(); // Use UTC for consistency with forecast
                            print(
                                'Current time (UTC): ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
                            print(
                                'Current time (local IST): ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now.toLocal())}');

                            // Sort and filter forecast as UTC
                            forecastList.sort((a, b) {
                              final aTime = DateTime.parse(a['time']).toUtc();
                              final bTime = DateTime.parse(b['time']).toUtc();
                              return aTime.compareTo(bTime);
                            });

                            print('Raw Forecast count: ${forecastList.length}');
                            forecastList.forEach((item) {
                              final forecastTime =
                                  DateTime.parse(item['time']).toUtc();
                              print('Raw Forecast time (UTC): $forecastTime');
                            });

                            // Round now to the nearest hour (since timesteps are hourly)
                            final roundedNow = DateTime.utc(
                                    now.year, now.month, now.day, now.hour)
                                .add(Duration(hours: now.minute >= 30 ? 1 : 0));

                            final filteredForecast = forecastList.where((item) {
                              final forecastTime =
                                  DateTime.parse(item['time']).toUtc();
                              final isAfter = forecastTime.isAfter(roundedNow);
                              return isAfter;
                            }).toList();

                            print(
                                'Filtered Forecast count: ${filteredForecast.length}');
                            filteredForecast.forEach((item) {
                              final forecastTime =
                                  DateTime.parse(item['time']).toUtc();
                              print(
                                  'Filtered Forecast time (UTC): $forecastTime');
                            });

                            // Use the first filtered entry for display, convert to local for UI
                            final current = filteredForecast.isNotEmpty
                                ? filteredForecast[0]
                                : forecastList.last;
                            final currentTime = formatter.format(
                                DateTime.parse(current['time'])
                                    .toUtc()
                                    .toLocal());
                            final temp = current['values']['temperature'];
                            final weatherCode =
                                current['values']['weatherCode'];
                            final weatherInfo = weatherCodeMap[weatherCode] ??
                                {
                                  'desc': 'Unknown',
                                  'icon': Icons.help_outline,
                                  'gradient': [Colors.grey, Colors.white]
                                };

                            final place = sensor['place'] ?? 'Unknown';
                            final state = sensor['state'] ?? '';
                            final country = sensor['country'] ?? '';

                            Map<String, List<dynamic>> groupedForecast = {};
                            print(
                                'Before grouping - Filtered Forecast times (UTC): [${filteredForecast.map((item) => DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(item['time']).toUtc())).join(', ')}]');
                            for (var item in filteredForecast) {
                              final date = DateTime.parse(item['time'])
                                  .toUtc()
                                  .toLocal()
                                  .toIso8601String()
                                  .substring(0, 10);
                              groupedForecast
                                  .putIfAbsent(date, () => [])
                                  .add(item);
                            }

                            print(
                                'Grouped Forecast contents: ${groupedForecast.entries.map((e) => '${e.key}: [${e.value.map((i) => DateFormat('HH:mm').format(DateTime.parse(i['time']).toUtc().toLocal())).join(', ')}]').join(', ')}');

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.sequentialName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            widget.deviceName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.refresh,
                                                color: Colors.white),
                                            onPressed: _fetchWeatherForecast,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_back,
                                                color: Colors.white),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: IntrinsicWidth(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      elevation: 5,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              place != 'Unknown' &&
                                                      state != 'Unknown' &&
                                                      country != 'Unknown'
                                                  ? '$place, $state, $country'
                                                  : 'Lat: ${sensor['lat']}, Lon: ${sensor['lon']}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(weatherInfo['icon'],
                                                    size: MediaQuery.of(context)
                                                                .size
                                                                .width <
                                                            800
                                                        ? 40
                                                        : 50,
                                                    color: Colors.blueAccent),
                                                const SizedBox(width: 16),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '$temp°C',
                                                      style: const TextStyle(
                                                        fontSize: 40,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      weatherInfo['desc'],
                                                      style: const TextStyle(
                                                        fontSize: 30,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...groupedForecast.entries.map((entry) {
                                  final date = entry.key;
                                  final items = entry.value;
                                  final isToday = date ==
                                      DateTime.now()
                                          .toLocal()
                                          .toIso8601String()
                                          .substring(0, 10);

                                  if (isToday) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        elevation: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '📅 ${formatDisplayDate(date)}',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                height: 120,
                                                child: ListView.separated(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: items.length,
                                                  separatorBuilder: (context,
                                                          _) =>
                                                      const SizedBox(width: 12),
                                                  itemBuilder: (context, i) {
                                                    final item = items[i];
                                                    final time = DateFormat(
                                                            'HH:mm')
                                                        .format(DateTime.parse(
                                                                item['time'])
                                                            .toUtc()
                                                            .toLocal());
                                                    final temp = item['values']
                                                        ['temperature'];
                                                    final code = item['values']
                                                        ['weatherCode'];
                                                    final info =
                                                        weatherCodeMap[code] ??
                                                            {
                                                              'desc': 'Unknown',
                                                              'icon': Icons
                                                                  .help_outline,
                                                              'gradient': [
                                                                Colors.grey,
                                                                Colors.white
                                                              ]
                                                            };

                                                    return Container(
                                                      width: 90,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            time,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Icon(info['icon'],
                                                              size: 24,
                                                              color: Colors
                                                                  .blueAccent),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            '$temp°C',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            info['desc'],
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }).toList(),
                                // Single card for all non-today dates
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final screenWidth = constraints.maxWidth;
                                      final isSmallScreen = screenWidth < 400;

                                      // Dynamic sizes
                                      final cardPadding =
                                          screenWidth * 0.02; // ~4% padding
                                      final titleFontSize =
                                          isSmallScreen ? 10.0 : 18.0;
                                      final tempFontSize =
                                          isSmallScreen ? 10.0 : 18.0;
                                      final timeFontSize =
                                          isSmallScreen ? 9.0 : 12.0;
                                      final itemWidth = screenWidth *
                                          0.10; // ~12% of screen width for hourly items

                                      return Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        elevation: 5,
                                        child: Padding(
                                          padding: EdgeInsets.all(cardPadding),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: groupedForecast.entries
                                                .where((entry) =>
                                                    entry.key !=
                                                    DateTime.now()
                                                        .toLocal()
                                                        .toIso8601String()
                                                        .substring(0, 10))
                                                .map((entry) {
                                              final date = entry.key;
                                              final items = entry.value;

                                              // Temperature calculations
                                              final temperatures = items
                                                  .map((item) => item['values']
                                                      ['temperature'])
                                                  .whereType<double>();
                                              final minTemp = temperatures
                                                      .isNotEmpty
                                                  ? temperatures.reduce(
                                                      (a, b) => a < b ? a : b)
                                                  : 0.0;
                                              final maxTemp = temperatures
                                                      .isNotEmpty
                                                  ? temperatures.reduce(
                                                      (a, b) => a > b ? a : b)
                                                  : 0.0;

                                              // Dominant weather code
                                              final dominantCode = items
                                                  .map((item) => item['values']
                                                      ['weatherCode'])
                                                  .reduce((a, b) => items
                                                              .where((i) =>
                                                                  i['values'][
                                                                      'weatherCode'] ==
                                                                  a)
                                                              .length >=
                                                          items
                                                              .where((i) =>
                                                                  i['values']
                                                                      ['weatherCode'] ==
                                                                  b)
                                                              .length
                                                      ? a
                                                      : b);

                                              final weatherInfo =
                                                  weatherCodeMap[
                                                          dominantCode] ??
                                                      {
                                                        'desc': 'Unknown',
                                                        'icon':
                                                            Icons.help_outline,
                                                        'gradient': [
                                                          Colors.grey,
                                                          Colors.white
                                                        ],
                                                      };

                                              return Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '📅 ${formatDisplayDate(date)}',
                                                        style: TextStyle(
                                                          fontSize:
                                                              titleFontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            '$minTemp° / $maxTemp°',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  tempFontSize,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Icon(
                                                            weatherInfo['icon']
                                                                as IconData,
                                                            color: Colors
                                                                .blueAccent,
                                                            size: isSmallScreen
                                                                ? 14.0
                                                                : 26.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  children: [
                                                    SizedBox(
                                                      height: 80,
                                                      child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: items.length,
                                                        separatorBuilder:
                                                            (context, _) =>
                                                                const SizedBox(
                                                                    width: 12),
                                                        itemBuilder:
                                                            (context, i) {
                                                          final item = items[i];
                                                          final time = DateFormat(
                                                                  'HH:mm')
                                                              .format(DateTime
                                                                      .parse(item[
                                                                          'time'])
                                                                  .toLocal());
                                                          final temp = item[
                                                                  'values']
                                                              ['temperature'];
                                                          final code = item[
                                                                  'values']
                                                              ['weatherCode'];
                                                          final info =
                                                              weatherCodeMap[
                                                                      code] ??
                                                                  {
                                                                    'desc':
                                                                        'Unknown',
                                                                    'icon': Icons
                                                                        .help_outline,
                                                                    'gradient':
                                                                        [
                                                                      Colors
                                                                          .grey,
                                                                      Colors
                                                                          .white
                                                                    ],
                                                                  };

                                                          return Container(
                                                            width: itemWidth.clamp(
                                                                50,
                                                                80), // Prevent too small/large
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  time,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        timeFontSize,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Icon(
                                                                  info['icon'],
                                                                  size: 20,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                ),
                                                                const SizedBox(
                                                                    height: 4),
                                                                Text(
                                                                  '$temp°C',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        timeFontSize,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
