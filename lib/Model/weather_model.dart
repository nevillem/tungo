class Weather {
  final String location;
  final String icon;
  final double temp;
  final String text;
  const Weather({
    required this.location,
    required this.icon,
    required this.temp,
    required this.text,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: json['city'],
      temp: double.parse(json['temp'].toString()),
      icon: json['icon'],
      text: json['text_note'],
    );
  }
}