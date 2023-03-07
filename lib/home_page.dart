import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;
  var lat;
  var lon;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;
  

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();

    lat = await position!.latitude;
    lon = await position!.longitude;
    print("The latitude is ${lat}");
    print("The longitude is ${lon}");
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=166bcb194eba06e1c073c5d71c2ba7a6";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=166bcb194eba06e1c073c5d71c2ba7a6";
    String api =
        "https://ano4e149gl.execute-api.ap-northeast-1.amazonaws.com/public";
    var weatherResponse = await http.get(Uri.parse(weatherApi));
    var forecastResponse = await http.get(Uri.parse(forecastApi));
    
    //print("The Weather Map's result is : ${weatherResponse.body}");
    //("The Forecast Map's result is : ${forecastResponse.body}");
    //print(" Rayhan ${apiResponse.body}");
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
      
    });
    //var temp = {weatherMap!['main']['temp'] - 273.15};
  }

  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: weatherMap == null
          ? CircularProgressIndicator()
          : Scaffold(
              backgroundColor: Color(0xff010a19),
              body: Container(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          child: Column(
                            children: [
                              Text(
                                "${Jiffy(DateTime.now()).format("MMM do yy, h:mm:ss a")}",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                  "${weatherMap!['name']}, ${weatherMap!['sys']['country']}",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(weatherMap!['weather'][0]
                                    ['main'] ==
                                'Clouds'
                            ? "https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/44dcc5e4-8a09-4509-9618-490a88a13856/icon/1798a2e2-f79a-4ae6-b6b1-194996496889"
                            : weatherMap!['weather'][0]['main'] == 'Clouds'
                                ? "https://png.pngtree.com/png-clipart/20201216/original/pngtree-blue-cute-raining-clouds-png-image_5688747.jpg"
                                : weatherMap!['weather'][0]['main'] ==
                                        'Stromy Weather'
                                    ? "https://icon-library.com/images/stormy-weather-icon/stormy-weather-icon-11.jpg"
                                    : weatherMap!['weather'][0]['main'] ==
                                            'Haze'
                                        ? "https://i.guim.co.uk/img/media/07e3c0fbab9f963e1b4c21a1af0f8aef7d138938/0_147_4788_2873/master/4788.jpg?width=1200&height=900&quality=85&auto=format&fit=crop&s=6a741ee48b7cc04eda068e3b99af87de"
                                        : "https://i.guim.co.uk/img/media/07e3c0fbab9f963e1b4c21a1af0f8aef7d138938/0_147_4788_2873/master/4788.jpg?width=1200&height=900&quality=85&auto=format&fit=crop&s=6a741ee48b7cc04eda068e3b99af87de"),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "${(weatherMap!['main']['temp'] - 273.15).toStringAsFixed(2)}°",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            Text(
                              "Feels like ${(weatherMap!['main']['feels_like'] - 273.15).toStringAsFixed(2)}",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Text(
                              "${weatherMap!['weather'][0]['main']}",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Humidity ${weatherMap!['main']['humidity']} , Pressure ${weatherMap!['main']['pressure']} ",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        "Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)).format("h:mm a")}, Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)).format("h:mm a")}",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 162,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: forecastMap!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(
                                  top: 10,
                                ),
                                margin: EdgeInsets.only(right: 10),
                                width: 100,
                                color: Color(0xff1683f7),
                                child: Column(
                                  children: [
                                    Text(
                                      "${Jiffy("${forecastMap!['list'][index]['dt_txt']}").format("EEE h:mm a")}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(forecastMap!['list']
                                                      [index]['weather'][0]
                                                  ['main'] ==
                                              'Clouds'
                                          ? "https://services.garmin.com/appsLibraryBusinessServices_v0/rest/apps/44dcc5e4-8a09-4509-9618-490a88a13856/icon/1798a2e2-f79a-4ae6-b6b1-194996496889"
                                          : forecastMap!['list'][index]
                                                      ['weather'][0]['main'] ==
                                                  'Clouds'
                                              ? "https://png.pngtree.com/png-clipart/20201216/original/pngtree-blue-cute-raining-clouds-png-image_5688747.jpg"
                                              : forecastMap!['list'][index]
                                                              ['weather'][0]
                                                          ['main'] ==
                                                      'Stromy Weather'
                                                  ? "https://icon-library.com/images/stormy-weather-icon/stormy-weather-icon-11.jpg"
                                                  : forecastMap!['list'][index]
                                                                  ['weather'][0]
                                                              ['main'] ==
                                                          'Haze'
                                                      ? "https://i.guim.co.uk/img/media/07e3c0fbab9f963e1b4c21a1af0f8aef7d138938/0_147_4788_2873/master/4788.jpg?width=1200&height=900&quality=85&auto=format&fit=crop&s=6a741ee48b7cc04eda068e3b99af87de"
                                                      : "https://i.guim.co.uk/img/media/07e3c0fbab9f963e1b4c21a1af0f8aef7d138938/0_147_4788_2873/master/4788.jpg?width=1200&height=900&quality=85&auto=format&fit=crop&s=6a741ee48b7cc04eda068e3b99af87de"),
                                    ),
                                    Text(
                                        "${(forecastMap!['list'][index]['main']['temp_min']).toStringAsFixed(2)} / ${(forecastMap!['list'][index]['main']['temp_max']).toStringAsFixed(2)}",
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
