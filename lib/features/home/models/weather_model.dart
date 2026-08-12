class WeatherModel {
  final double temperature;
  final String condition;
  final String location;
  final double humidity;
  final int? weatherCode;
  final bool isDay;

  const WeatherModel({
    required this.temperature,
    required this.condition,
    required this.location,
    required this.humidity,
    this.weatherCode,
    this.isDay = true,
  });

  String get iconPath {
    if (weatherCode != null) {
      switch (weatherCode!) {
        case 0:
          return isDay ? 'assets/static/clear-day.svg' : 'assets/static/clear-night.svg';
        case 1:
          return isDay ? 'assets/static/cloudy-1-day.svg' : 'assets/static/cloudy-1-night.svg';
        case 2:
          return isDay ? 'assets/static/cloudy-2-day.svg' : 'assets/static/cloudy-2-night.svg';
        case 3:
          return 'assets/static/cloudy.svg';
        case 45:
        case 48:
          return isDay ? 'assets/static/fog-day.svg' : 'assets/static/fog-night.svg';
        case 51:
        case 53:
        case 55:
          return isDay ? 'assets/static/rainy-1-day.svg' : 'assets/static/rainy-1-night.svg';
        case 61:
        case 63:
        case 65:
          return isDay ? 'assets/static/rainy-2-day.svg' : 'assets/static/rainy-2-night.svg';
        case 71:
        case 73:
        case 75:
          return isDay ? 'assets/static/snowy-1-day.svg' : 'assets/static/snowy-1-night.svg';
        case 80:
        case 81:
        case 82:
          return isDay ? 'assets/static/rainy-3-day.svg' : 'assets/static/rainy-3-night.svg';
        case 85:
        case 86:
          return isDay ? 'assets/static/snowy-2-day.svg' : 'assets/static/snowy-2-night.svg';
        case 95:
          return isDay ? 'assets/static/isolated-thunderstorms-day.svg' : 'assets/static/isolated-thunderstorms-night.svg';
        case 96:
        case 99:
          return 'assets/static/severe-thunderstorm.svg';
      }
    }

    final lower = condition.toLowerCase();
    if (lower.contains('clear')) {
      return isDay ? 'assets/static/clear-day.svg' : 'assets/static/clear-night.svg';
    } else if (lower.contains('sunny')) {
      return 'assets/static/clear-day.svg';
    } else if (lower.contains('overcast')) {
      return 'assets/static/cloudy.svg';
    } else if (lower.contains('thunder')) {
      return 'assets/static/thunderstorms.svg';
    } else if (lower.contains('drizzle')) {
      return isDay ? 'assets/static/rainy-1-day.svg' : 'assets/static/rainy-1-night.svg';
    } else if (lower.contains('rain')) {
      return isDay ? 'assets/static/rainy-2-day.svg' : 'assets/static/rainy-2-night.svg';
    } else if (lower.contains('fog')) {
      return isDay ? 'assets/static/fog-day.svg' : 'assets/static/fog-night.svg';
    } else if (lower.contains('snow')) {
      return isDay ? 'assets/static/snowy-1-day.svg' : 'assets/static/snowy-1-night.svg';
    } else if (lower.contains('haze')) {
      return isDay ? 'assets/static/haze-day.svg' : 'assets/static/haze-night.svg';
    }

    return isDay ? 'assets/static/cloudy-2-day.svg' : 'assets/static/cloudy-2-night.svg';
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      location: json['location'] as String,
      humidity: (json['humidity'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num?)?.toInt(),
      isDay: json['is_day'] == 1 || json['is_day'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'location': location,
      'humidity': humidity,
      'weather_code': weatherCode,
      'is_day': isDay,
    };
  }
}
