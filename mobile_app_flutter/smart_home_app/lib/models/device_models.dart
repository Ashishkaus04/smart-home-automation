class DeviceState {
  final Map<String, bool> lights;
  final Thermostat thermostat;
  final Security security;
  final Map<String, bool> appliances;
  final Sensors sensors;

  DeviceState({
    required this.lights,
    required this.thermostat,
    required this.security,
    required this.appliances,
    required this.sensors,
  });

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    return DeviceState(
      lights: (json['lights'] as Map).map((k, v) => MapEntry(k.toString(), v as bool)),
      thermostat: Thermostat.fromJson(json['thermostat'] as Map<String, dynamic>),
      security: Security.fromJson(json['security'] as Map<String, dynamic>),
      appliances: (json['appliances'] as Map).map((k, v) => MapEntry(k.toString(), v as bool)),
      sensors: Sensors.fromJson(json['sensors'] as Map<String, dynamic>),
    );
  }
}

class Thermostat {
  final num temperature;
  final num target;
  final String mode;

  Thermostat({required this.temperature, required this.target, required this.mode});

  factory Thermostat.fromJson(Map<String, dynamic> json) {
    return Thermostat(
      temperature: num.parse(json['temperature'].toString()),
      target: num.parse(json['target'].toString()),
      mode: json['mode']?.toString() ?? 'auto',
    );
  }
}

class Security {
  final bool armed;
  final Map<String, bool> doors;

  Security({required this.armed, required this.doors});

  factory Security.fromJson(Map<String, dynamic> json) {
    return Security(
      armed: json['armed'] as bool,
      doors: (json['doors'] as Map).map((k, v) => MapEntry(k.toString(), v as bool)),
    );
  }
}

class Sensors {
  final bool motion;
  final bool smoke;
  final num humidity;
  final num light;

  Sensors({
    required this.motion,
    required this.smoke,
    required this.humidity,
    required this.light,
  });

  factory Sensors.fromJson(Map<String, dynamic> json) {
    return Sensors(
      motion: json['motion'] as bool,
      smoke: json['smoke'] as bool,
      humidity: num.parse(json['humidity'].toString()),
      light: num.parse(json['light'].toString()),
    );
  }
}


