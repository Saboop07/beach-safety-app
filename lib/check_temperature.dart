import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import for date formatting

class CheckTemperature extends StatefulWidget {
  @override
  _CheckTemperatureState createState() => _CheckTemperatureState();
}

class _CheckTemperatureState extends State<CheckTemperature> {
  double? _currentTemperature;
  List<double?> _nextFourDaysTemperatures = List.filled(4, null); // For next 4 days
  List<double?> _hourlyTemperaturesToday = []; // For today's hourly temperatures
  String _city = '';
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  Future<void> _fetchCurrentTemperature() async {
    final apiKey = '08d94f5480f19a801321fda9628cf42b';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentTemperature = data['main']['temp'];
        });
        await _fetchForecastTemperatures();
      } else {
        print('Error fetching temperature: ${response.statusCode}');
        setState(() {
          _currentTemperature = null;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _currentTemperature = null;
      });
    }
  }

  Future<void> _fetchForecastTemperatures() async {
    final apiKey = '08d94f5480f19a801321fda9628cf42b';
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$_city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        for (int i = 0; i < 4; i++) {
          _nextFourDaysTemperatures[i] = data['list'][i * 8]['main']['temp'];
        }
        _hourlyTemperaturesToday.clear();
        for (var entry in data['list']) {
          DateTime forecastTime = DateTime.fromMillisecondsSinceEpoch(entry['dt'] * 1000);
          if (forecastTime.isAfter(DateTime.now().subtract(Duration(hours: 1))) &&
              forecastTime.isBefore(DateTime.now().add(Duration(days: 1)))) {
            _hourlyTemperaturesToday.add(entry['main']['temp']);
          }
        }
      } else {
        print('Error fetching forecast: ${response.statusCode}');
        _nextFourDaysTemperatures.fillRange(0, 4, null);
        _hourlyTemperaturesToday.clear();
      }
    } catch (e) {
      print('Error: $e');
      _nextFourDaysTemperatures.fillRange(0, 4, null);
      _hourlyTemperaturesToday.clear();
    }
  }

  void _searchCity() {
    if (_cityController.text.isNotEmpty) {
      setState(() {
        _city = _cityController.text;
        _currentTemperature = null;
        _nextFourDaysTemperatures.fillRange(0, 4, null);
        _hourlyTemperaturesToday.clear();
      });
      _fetchCurrentTemperature();
    }
  }

  String _formattedDateTime() {
    return DateFormat('EEE, d MMM yyyy').format(DateTime.now());
  }

  String _formattedTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  String _getDayOfWeek(int daysFromNow) {
    DateTime dateTime = DateTime.now().add(Duration(days: daysFromNow));
    return DateFormat('EEEE').format(dateTime);
  }

  void _updateTime() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
        _updateTime();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Check Weather', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/org.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Center(
                child: Column(
                  children: [
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter city name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: Colors.teal),
                          onPressed: _searchCity,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formattedDateTime(),
                          style: TextStyle(fontSize: 30, color: Colors.white70),
                        ),
                        Text(
                          _formattedTime(),
                          style: TextStyle(fontSize: 30, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (_currentTemperature != null)
                      Column(
                        children: [
                          Text(
                            '$_city',
                            style: TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Image.asset(
                            'assets/image_8.png', // Weather icon placeholder
                            width: 100,
                            height: 100,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${_currentTemperature!.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Today\'s Temperatures:',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          for (int i = 0; i < _hourlyTemperaturesToday.length; i++)
                            Text(
                              '${_formattedTimeOfDay(i)}: ${_hourlyTemperaturesToday[i]!.toStringAsFixed(1)}°C',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          SizedBox(height: 20),
                          Text(
                            'Next 4 Days:',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          for (int i = 0; i < 4; i++)
                            Text(
                              '${_getDayOfWeek(i + 1)}: ${_nextFourDaysTemperatures[i] != null ? _nextFourDaysTemperatures[i]!.toStringAsFixed(1) + '°C' : 'Loading...'}',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                        ],
                      )
                    else
                      Text(
                        'Enter a city to get the weather forecast!',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formattedTimeOfDay(int index) {
    DateTime now = DateTime.now();
    DateTime forecastTime = now.add(Duration(hours: index * 3));
    return DateFormat('HH:mm').format(forecastTime);
  }
}
