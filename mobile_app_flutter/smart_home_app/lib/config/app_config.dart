class AppConfig {
  // MQTT Server Configuration
  // Change these values based on your network environment
  
  // Home Network Configuration
  static const String homeMqttHost = '';  // PC IP on hotspot
  static const int homeMqttPort = 1883;
  
  // College Network Configuration  
  static const String collegeMqttHost = '';  // Hotspot broker IP
  static const int collegeMqttPort = 1883;
  
  // Public Test Broker (for testing when local broker is not available)
  static const String testMqttHost = 'broker.hivemq.com';  // Public MQTT broker
  static const int testMqttPort = 1883;
  
  // Current Environment - Change this to switch between home, college, or test
  static const Environment currentEnvironment = Environment.college; // using public broker for testing
  
  // Get current MQTT host based on environment
  static String get mqttHost {
    switch (currentEnvironment) {
      case Environment.home:
        return homeMqttHost;
      case Environment.college:
        return collegeMqttHost;
      case Environment.test:
        return testMqttHost;
    }
  }
  
  // Get current MQTT port based on environment
  static int get mqttPort {
    switch (currentEnvironment) {
      case Environment.home:
        return homeMqttPort;
      case Environment.college:
        return collegeMqttPort;
      case Environment.test:
        return testMqttPort;
    }
  }
  
  // Get environment name for display
  static String get environmentName {
    switch (currentEnvironment) {
      case Environment.home:
        return 'Home';
      case Environment.college:
        return 'College';
      case Environment.test:
        return 'Test (Public)';
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
  test,
}
