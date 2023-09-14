import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forecast_weather/resources/app_constants.dart';
import 'package:forecast_weather/models/weather_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? lat;
  String? long;
  String? locationMessage;
  WeatherData? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location Services are disabled';
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          lat = '${position.latitude}';
          long = '${position.longitude}';
          locationMessage = '${placemarks[0].locality}';
        });
      }
    } catch (e) {
      print('Error fetching city name: $e');
    }

    // Make the API call to OpenWeatherMap
    final apiKey =
        'ab1a9c99bb351378f3faca8e8dc2c9c7';
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));
    final responseBody = response.body;

    if (response.statusCode == 200) {
      final weatherDataResponse =
          WeatherData.fromJson(json.decode(responseBody));
      debugPrint("HEREREREERER" + responseBody.toString());
      setState(() {
        weatherData = weatherDataResponse;
        isLoading = false;
      });
    } else {
      // Handle the API error, e.g., print an error message
      print('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  String getIconUrl(String? code) {
    switch (code) {
      case '01d':
        return 'https://openweathermap.org/img/wn/01d.png';
      case '01n':
        return 'https://openweathermap.org/img/wn/01n.png';
      case '02d':
        return 'https://openweathermap.org/img/wn/02d.png';
      case '02n':
        return 'https://openweathermap.org/img/wn/02n.png';
      case '03d':
        return 'https://openweathermap.org/img/wn/03d.png';
      case '03n':
        return 'https://openweathermap.org/img/wn/03n.png';
      case '04d':
        return 'https://openweathermap.org/img/wn/04d.png';
      case '04n':
        return 'https://openweathermap.org/img/wn/04n.png';
      case '09d':
        return 'https://openweathermap.org/img/wn/09d.png';
      case '09n':
        return 'https://openweathermap.org/img/wn/09n.png';
      case '10d':
        return 'https://openweathermap.org/img/wn/10d.png';
      case '10n':
        return 'https://openweathermap.org/img/wn/10n.png';
      case '11d':
        return 'https://openweathermap.org/img/wn/11d.png';
      case '11n':
        return 'https://openweathermap.org/img/wn/11n.png';
      case '13d':
        return 'https://openweathermap.org/img/wn/13d.png';
      case '13n':
        return 'https://openweathermap.org/img/wn/13n.png';
      case '50d':
        return 'https://openweathermap.org/img/wn/50d.png';
      case '50n':
        return 'https://openweathermap.org/img/wn/50n.png';
      default:
        return 'https://openweathermap.org/img/wn/unknown.png'; // Default icon for unknown conditions
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: AppConstants.sizedBoxMedium,
              ),
              _buildHeader(),
              SizedBox(
                height: AppConstants.sizedBoxMedium,
              ),
              _buildCityContainer(),
              SizedBox(
                height: AppConstants.sizedBoxMedium,
              ),
              if (weatherData != null)
                WeatherDataWidget(weatherData: weatherData!)
              else
                ShimmerLoadingPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildCityContainer() {
    return Container(
            padding: EdgeInsets.symmetric(
              vertical: AppConstants.mediumPadding,
            ),
            width: double.maxFinite,
            margin: EdgeInsets.symmetric(
              horizontal: AppConstants.mediumMargin,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.gradientOne,
                  AppConstants.gradientTwo,
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: Center(
              child: Text(
                locationMessage ?? '',
                style: TextStyle(
                  color: AppConstants.cityNameColor,
                  fontSize: AppConstants.cityNameSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }

  Row _buildHeader() {
    return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppConstants.appLogo,
                height: AppConstants.appLogoHeight,
                width: AppConstants.appLogoWidth,
              ),
              SizedBox(
                width: AppConstants.sizedBoxSmall,
              ),
              Text(
                "Weather Wizard",
                style: TextStyle(
                  color: AppConstants.appNameColor,
                  fontSize: AppConstants.appNameSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
  }

  Widget WeatherDataWidget({required WeatherData weatherData}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.mediumMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: AppConstants.sizedBoxMedium,
          ),
          _buildWeatherWidget(weatherData),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          _buildTemperatureWidget(weatherData),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          _buildHimidityWidget(weatherData),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          _buildWindSpeedWidget(weatherData),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          _buildConditionWidget(weatherData),
        ],
      ),
    );
  }

  Row _buildConditionWidget(WeatherData weatherData) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (weatherData.iconCode != null)
              Image.network(
                getIconUrl(weatherData.iconCode),
                height: AppConstants.imageHeight,
                width: AppConstants.imageWidth,
                fit: BoxFit.cover,
              )
            else
              Image.asset(
                AppConstants.cloud,
                height: AppConstants.imageHeight,
                width: AppConstants.imageWidth,
              ),
            SizedBox(
              width: AppConstants.sizedBoxMedium,
            ),
            Expanded(
              child: Text(
                'Condition : ${weatherData.description}',
                style: TextStyle(
                  color: AppConstants.textColorPrimary,
                  fontSize: AppConstants.textSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
  }

  Row _buildWindSpeedWidget(WeatherData weatherData) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              AppConstants.windSpeed,
              height: AppConstants.imageHeight,
              width: AppConstants.imageWidth,
            ),
            SizedBox(
              width: AppConstants.sizedBoxMedium,
            ),
            Text(
              'Wind Speed : ${weatherData.windSpeed.toStringAsFixed(2)} m/s',
              style: TextStyle(
                color: AppConstants.textColorPrimary,
                fontSize: AppConstants.textSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
  }

  Row _buildHimidityWidget(WeatherData weatherData) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              AppConstants.humidity,
              height: AppConstants.imageHeight,
              width: AppConstants.imageWidth,
            ),
            SizedBox(
              width: AppConstants.sizedBoxMedium,
            ),
            Text(
              'Humidity : ${weatherData.humidity}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.textColorPrimary,
                fontSize: AppConstants.textSize,
              ),
            ),
          ],
        );
  }

  Row _buildTemperatureWidget(WeatherData weatherData) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              AppConstants.temperature,
              height: AppConstants.imageHeight,
              width: AppConstants.imageWidth,
            ),
            SizedBox(
              width: AppConstants.sizedBoxMedium,
            ),
            Text(
              'Temperature : ${weatherData.temperature.toStringAsFixed(2)}°K',
              style: TextStyle(
                color: AppConstants.textColorPrimary,
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.textSize,
              ),
            ),
          ],
        );
  }

  Row _buildWeatherWidget(WeatherData weatherData) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              AppConstants.cloud,
              height: AppConstants.imageHeight,
              width: AppConstants.imageWidth,
            ),
            SizedBox(
              width: AppConstants.sizedBoxMedium,
            ),
            Text(
              'Weather : ${weatherData.weatherMain}',
              style: TextStyle(
                color: AppConstants.textColorPrimary,
                fontSize: AppConstants.textSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
  }

  Widget ShimmerLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppConstants.greyColor,
      highlightColor: AppConstants.secondaryColor,
      child: _buildContainer(),
    );
  }

  Container _buildContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppConstants.mediumMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: AppConstants.sizedBoxMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                AppConstants.cloud,
                height: AppConstants.imageHeight,
                width: AppConstants.imageWidth,
              ),
              SizedBox(
                width: AppConstants.sizedBoxMedium,
              ),
              Container(
                width: AppConstants.largeWidth, // Adjust the width as needed
                height: AppConstants.smallHeight,
                color: AppConstants
                    .secondaryColor, // You can use any background color here
              ),
            ],
          ),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                AppConstants.temperature,
                height: AppConstants.imageHeight,
                width: AppConstants.imageWidth,
              ),
              SizedBox(
                width: AppConstants.sizedBoxMedium,
              ),
              Container(
                width: AppConstants.XlargeWidth, // Adjust the width as needed
                height: AppConstants.smallHeight,
                color: AppConstants
                    .secondaryColor, // You can use any background color here
              ),
            ],
          ),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                AppConstants.humidity,
                height: AppConstants.imageHeight,
                width: AppConstants.imageWidth,
              ),
              SizedBox(
                width: AppConstants.sizedBoxMedium,
              ),
              Container(
                width: AppConstants.XlargeWidth, // Adjust the width as needed
                height: AppConstants.smallHeight,
                color: AppConstants
                    .secondaryColor, // You can use any background color here
              ),
            ],
          ),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                AppConstants.windSpeed,
                height: AppConstants.imageHeight,
                width: AppConstants.imageWidth,
              ),
              SizedBox(
                width: AppConstants.sizedBoxMedium,
              ),
              Container(
                width: AppConstants.XlargeWidth, // Adjust the width as needed
                height: AppConstants.smallHeight,
                color: AppConstants
                    .secondaryColor, // You can use any background color here
              ),
            ],
          ),
          SizedBox(
            height: AppConstants.sizedBoxLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                AppConstants.cloud,
                height: AppConstants.imageHeight,
                width: AppConstants.imageWidth,
              ),
              SizedBox(
                width: AppConstants.sizedBoxMedium,
              ),
              Expanded(
                child: Container(
                  height: AppConstants.smallHeight,
                  color: AppConstants
                      .secondaryColor, // You can use any background color here
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
