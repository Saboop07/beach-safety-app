import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'other_beaches_screen.dart'; // Import the other beaches screen

class CheckBeaches extends StatefulWidget {
  @override
  _CheckBeachesState createState() => _CheckBeachesState();
}

class _CheckBeachesState extends State<CheckBeaches> {
  final TextEditingController _cityController = TextEditingController();
  String? _beachData;
  Map<String, double> currentValues = {};
  Map<String, String> observationTimes = {};
  bool _isLoading = false;

  bool _isSafeBeach = false;

  final List<WaterParameter> parameters = [
    WaterParameter('currentspeed', 0.5, 1.5, 'm/s'),
    WaterParameter('temperature', 23, 32, '°C'),
    WaterParameter('salinity', 25, 38, 'psu'),
    WaterParameter('dissolvedoxygen', 1.5, 5, 'mg/l'),
    WaterParameter('pH', 7.4, 8.3, ''),
    WaterParameter('turbidity', 0.0001, 50, 'NTU'),
    WaterParameter('CDOM', 0.0001, 10, 'ppb'),
    WaterParameter('scattering', 0.001, 1, 'm-1'),
    WaterParameter('phycocyanin', 0, 2, 'μg/l'),
    WaterParameter('phycoerythrin', 0, 2, 'μg/l'),
  ];

  String _formattedDateTime() {
    return DateFormat('EEE, d MMM yyyy').format(DateTime.now());
  }

  String _formattedTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  Future<void> _fetchBeachData() async {
    const apiKey = '446d183e64e64e8eb4bca1407ab02a89';
    const url = 'https://gemini.incois.gov.in/incoisapi/rest/tsunami';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$url?authKey=$apiKey'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _beachData = data.toString();
        });
      }
    } catch (e) {
      setState(() {
        _beachData = null; // Clear the beach data on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWaterData(String beachName) async {
    final stationName = beachName.split(',').last.trim().toLowerCase();

    try {
      final fetchedValues = <String, double>{};
      final fetchedTimes = <String, String>{};

      bool isSafe = true; // Assume the beach is safe by default

      for (var parameter in parameters) {
        final url = Uri.parse(
            'https://gemini.incois.gov.in/OceanDataAPI/api/wqns/$stationName/${parameter.name}');
        final response = await http.get(url, headers: {
          'Authorization': '446d183e64e64e8eb4bca1407ab02a89',
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['observationTime'] != null &&
              data[parameter.name] != null &&
              data['observationTime'] is List &&
              data[parameter.name] is List &&
              data['observationTime'].isNotEmpty &&
              data[parameter.name].isNotEmpty) {
            fetchedTimes[parameter.name] = data['observationTime'][0];

            final rawValue = data[parameter.name][0];
            if (rawValue is String) {
              fetchedValues[parameter.name] = double.parse(rawValue);
            } else if (rawValue is num) {
              fetchedValues[parameter.name] = rawValue.toDouble();
            }

            // Check if the parameter value is safe
            if (!parameter.isSafe(fetchedValues[parameter.name]!)) {
              isSafe = false; // If any parameter is unsafe, mark the beach as unsafe
            }
          }
        }
      }

      setState(() {
        currentValues = fetchedValues;
        observationTimes = fetchedTimes;
        _isSafeBeach = isSafe;
      });
    } catch (e) {
      // Handle errors
    }
  }

  Widget buildWaterStatus() {
    return currentValues.isEmpty
        ? Center(child: Text("No water data available."))
        : Column(
      children: parameters.map((param) {
        final value = currentValues[param.name];
        final time = observationTimes[param.name];
        final isSafe = value != null && param.isSafe(value);
        final color = isSafe ? Colors.green : Colors.red;

        return Card(
          color: color.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Icon(
              isSafe ? Icons.check_circle : Icons.warning,
              color: color,
            ),
            title: Text(
              param.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (value != null)
                  Text(
                      'Value: ${value.toStringAsFixed(2)} ${param.unit}'),
                if (time != null) Text('Observation Time: $time'),
              ],
            ),
            trailing: Text(
              isSafe ? 'Safe' : 'Unsafe',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Check Beaches', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      // Input field for Beach name
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20.0),
                        child: TextField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter beach name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search, color: Colors.teal),
                              onPressed: () {
                                _fetchBeachData();
                                _fetchWaterData(_cityController.text);
                              },
                            ),
                          ),
                        ),
                      ),
                      // Date and time
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formattedDateTime(),
                              style: TextStyle(fontSize: 20, color: Colors.white70),
                            ),
                            Text(
                              _formattedTime(),
                              style: TextStyle(fontSize: 20, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Display the "Beach is Safe" button above the results
                      if (_isSafeBeach)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 40.0), // Larger size
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text('Beach is Safe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      // Display the fetched beach data only if available
                      _isLoading
                          ? CircularProgressIndicator()
                          : _beachData != null
                          ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _beachData!,
                          style: TextStyle(
                              fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                          : Text(
                        'Enter a beach name and press search to get details.',
                        style: TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                      SizedBox(height: 20),
                      buildWaterStatus(),
                      SizedBox(height: 20),
                      // Buttons for specific beaches (Kochi, Vizag)
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _cityController.text = 'Kochi';
                              _fetchBeachData();
                              _fetchWaterData('Kochi');
                            },
                            child: Text('Kochi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent, // Blue color
                              padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 40.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _cityController.text = 'Vizag';
                              _fetchBeachData();
                              _fetchWaterData('Vizag');
                            },
                            child: Text('Vizag'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent, // Orange color
                              padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 40.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtherBeachesScreen()),
                  );
                },
                child: Text('Explore Other Beaches'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterParameter {
  final String name;
  final double min;
  final double max;
  final String unit;

  WaterParameter(this.name, this.min, this.max, this.unit);

  bool isSafe(double value) {
    return value >= min && value <= max;
  }
}
