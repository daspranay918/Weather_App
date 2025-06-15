import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Hourly_forecast_item.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:weather_app/theme_manager.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey",
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw data['message'];
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        //----------------------------->
        leading: IconButton(
    onPressed: () {
      themeNotifier.value = themeNotifier.value == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    },
    icon: Icon(
      themeNotifier.value == ThemeMode.dark
          ? Icons.light_mode
          : Icons.dark_mode,
    ),
  ),
  //------------------------------------>
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
          
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          //  handle the loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator.adaptive());
          }

          // handle the error state
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start, // everything stsrt from the left side of the column
              children: [
                // Main Carts---------------->
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    // color: Colors.black,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp K",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 66,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "$currentSky",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Weather forcast cards------------->
                const SizedBox(height: 20),
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 8),

                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 39; i++)
                //         HourlyForecustItem(
                //           time: data['list'][i + 1]['dt'].toString(),
                //           icon: data['list'][i + 1]['weather'][0]['main'] == 'Clouds' || data['list'][i + 1]['weather'][0]['main'] == 'Rain'? Icons.cloud : Icons.sunny,
                //           tempreture: data['list'][i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky = hourlyForecast['weather'][0]['main'];
                      final hourlyTemp = hourlyForecast['main']['temp'];
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForecustItem(
                        time: DateFormat.j().format(time),
                        tempreture: hourlyTemp.toString(),
                        icon:
                            hourlySky == 'Clouds' || hourlySky == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                      );
                    },
                  ),
                ),
                // additional information------------>
                const SizedBox(height: 20),
                Text(
                  "Additional Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
