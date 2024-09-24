import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String city = 'Delhi';
      String country = 'IN';
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city,$country&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(result.body);
      if (int.parse(data['cod']) != 200) {
        throw data['message'];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  final NumberFormat f = NumberFormat('##.#');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];

          final currentTemp =
              f.format(currentWeatherData['main']['temp'] - 273.15);
          final currentSky = currentWeatherData['weather'][0]['main'];
          final pressure = currentWeatherData['main']['pressure'];
          final windSpeed = currentWeatherData['wind']['speed'];
          final humidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //current weather card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$currentTemp °C',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Icon(
                            currentSky == 'Clouds' || currentSky == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                            size: 64,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text('$currentSky'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final hourlyForecastData = data['list'][index + 1];
                      final hourlySky =
                          hourlyForecastData['weather'][0]['main'];
                      final hourlyTemp =
                          '${f.format(hourlyForecastData['main']['temp'] - 273.15)} °C';
                      final time = DateTime.parse(hourlyForecastData['dt_txt']);
                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        temperature: hourlyTemp,
                        icon: hourlySky == 'Clouds' || currentSky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalForecastItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$humidity',
                    ),
                    AdditionalForecastItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '$windSpeed',
                    ),
                    AdditionalForecastItem(
                      icon: Icons.wind_power,
                      label: 'Pressure',
                      value: '$pressure',
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
