import 'package:flutter/material.dart';
import 'screens/security_screen.dart';
import 'screens/energy_screen.dart';
import 'screens/devices_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/automation_screen.dart';
import 'screens/ai_insights_screen.dart';
import 'services/mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Automation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Smart Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize MQTT once at app start
    MqttService.instance.connect();
  }

  Widget _pageFor(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const DevicesScreen();
      case 2:
        return const SecurityScreen();
      case 3:
        return const EnergyScreen();
      case 4:
        return const AutomationScreen();
      case 5:
      default:
        return const AiInsightsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentTitle;
    switch (_currentIndex) {
      case 0:
        currentTitle = 'Dashboard';
        break;
      case 1:
        currentTitle = 'Devices';
        break;
      case 2:
        currentTitle = 'Security';
        break;
      case 3:
        currentTitle = 'Energy';
        break;
      case 4:
        currentTitle = 'Automation';
        break;
      default:
        currentTitle = 'Insights';
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(currentTitle),
      ),
      body: _pageFor(_currentIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.devices_other_outlined), selectedIcon: Icon(Icons.devices_other), label: 'Devices'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Security'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: 'Energy'),
          NavigationDestination(icon: Icon(Icons.auto_mode_outlined), selectedIcon: Icon(Icons.auto_mode), label: 'Automation'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
        ],
      ),
    );
  }
}
