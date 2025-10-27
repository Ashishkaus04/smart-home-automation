class AppConfig {
  // MQTT Server Configuration
  // Change these values based on your network environment
  
  // Home Network Configuration
  static const String homeMqttHost = '192.168.1.100';  // Your home router IP
  static const int homeMqttPort = 1883;
  
  // College Network Configuration  
  static const String collegeMqttHost = '10.217.139.106';  // Your college hotspot IP
  static const int collegeMqttPort = 1883;
  
  // Current Environment - Change this to switch between home and college
  static const Environment currentEnvironment = Environment.college; // change to home 
  
  // Get current MQTT host based on environment
  static String get mqttHost {
    switch (currentEnvironment) {
      case Environment.home:
        return homeMqttHost;
      case Environment.college:
        return collegeMqttHost;
    }
  }
  
  // Get current MQTT port based on environment
  static int get mqttPort {
    switch (currentEnvironment) {
      case Environment.home:
        return homeMqttPort;
      case Environment.college:
        return collegeMqttPort;
    }
  }
  
  // Get environment name for display
  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.home:
        return 'Home';
      case Environment.college:
        return 'College';
    }
  }
  
  // Get connection info for display
  static String get connectionInfo {
    return '$environmentName Network - $mqttHost:$mqttPort';
  }
}

enum Environment {
  home,
  college,
}
