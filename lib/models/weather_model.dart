class WeatherData {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String weatherMain;
  final String? description;
  final String? iconCode; // Field for weather condition code

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherMain,
    required this.description,
    required this.iconCode
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      description: json['weather'][0]['description'],
      temperature: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      weatherMain: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}
