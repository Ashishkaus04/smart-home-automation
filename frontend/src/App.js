import React, { useState, useEffect, useCallback } from 'react';
import { 
  Home, 
  Lightbulb, 
  Thermometer, 
  Shield, 
  Zap, 
  Wifi, 
  Settings, 
  TrendingUp,
  Clock,
  Battery,
  AlertTriangle,
  CheckCircle,
  Power,
  Fan,
  Camera,
  Lock,
  Smartphone,
  Eye,
  EyeOff,
  Plus,
  Minus,
  Activity,
  BarChart3,
  Users,
  Bell,
  Menu,
  X,
  Moon,
  Sun,
  Volume2,
  VolumeX,
  Tv,
  Coffee,
  Car,
  Flower,
  Wind,
  Droplets,
  MapPin,
  Calendar,
  Timer,
  Signal
} from 'lucide-react';

const SmartHomeApp = () => {
  // State Management
  const [devices, setDevices] = useState({
    lights: { 
      living_room: { on: false, brightness: 80, color: 'warm' },
      bedroom: { on: true, brightness: 60, color: 'cool' },
      kitchen: { on: false, brightness: 100, color: 'bright' },
      bathroom: { on: false, brightness: 70, color: 'warm' },
      garage: { on: false, brightness: 90, color: 'bright' },
      garden: { on: true, brightness: 40, color: 'warm' }
    },
    climate: { 
      temperature: 22, 
      target: 24, 
      humidity: 45,
      mode: 'auto',
      fan_speed: 2,
      ac_on: false,
      heater_on: false
    },
    security: { 
      armed: true, 
      cameras: { front: true, back: true, garage: true },
      doors: { front: true, back: true, garage: false }, 
      windows: { living: true, bedroom: true, kitchen: true },
      motion_sensors: { living: false, bedroom: false, entrance: false }
    },
    appliances: { 
      tv: { on: false, channel: 1, volume: 50 },
      music: { on: false, volume: 30, source: 'spotify' },
      coffee_maker: { on: false, scheduled: false },
      dishwasher: { on: false, program: 'normal' },
      washing_machine: { on: false, program: 'cotton' },
      car_charger: { on: false, charge_level: 85 }
    },
    sensors: { 
      motion: false, 
      smoke: false, 
      gas: false,
      water_leak: false,
      humidity: 45, 
      light: 75,
      air_quality: 'good',
      noise_level: 35,
      uv_index: 3
    }
  });

  const [energyData, setEnergyData] = useState({
    current: 2.4,
    daily: 18.6,
    weekly: 125.8,
    monthly: 487.2,
    prediction: 142.3,
    cost_today: 4.65,
    cost_month: 97.44,
    solar_generated: 12.3,
    grid_usage: 6.3
  });

  const [weatherData, setWeatherData] = useState({
    temperature: 25,
    condition: 'sunny',
    humidity: 60,
    wind_speed: 12,
    uv_index: 6,
    forecast: [
      { day: 'Today', high: 28, low: 20, condition: 'sunny' },
      { day: 'Tomorrow', high: 26, low: 18, condition: 'cloudy' },
      { day: 'Thursday', high: 24, low: 16, condition: 'rainy' }
    ]
  });

  const [mlInsights, setMlInsights] = useState([
    { 
      type: 'optimization', 
      message: 'AC efficiency can be improved by 15% with schedule optimization', 
      priority: 'medium',
      savings: '$12/month'
    },
    { 
      type: 'security', 
      message: 'Unusual activity detected: Front door opened at 2:30 AM', 
      priority: 'high',
      timestamp: '2 hours ago'
    },
    { 
      type: 'energy', 
      message: 'Solar panels generating 20% above average today', 
      priority: 'low',
      impact: 'positive'
    },
    { 
      type: 'maintenance', 
      message: 'Air filter replacement recommended in 2 weeks', 
      priority: 'medium',
      due_date: 'Nov 25, 2024'
    }
  ]);

  const [automationRules, setAutomationRules] = useState([
    { 
      id: 1, 
      name: 'Morning Routine', 
      active: true, 
      trigger: 'Every day at 7:00 AM', 
      actions: ['Turn on bedroom lights', 'Start coffee maker', 'Set AC to 24°C'],
      last_run: '2024-11-08 07:00'
    },
    { 
      id: 2, 
      name: 'Away Mode', 
      active: true, 
      trigger: 'No motion detected for 30 minutes', 
      actions: ['Turn off all lights', 'Set AC to eco mode', 'Arm security system'],
      last_run: '2024-11-07 14:30'
    },
    { 
      id: 3, 
      name: 'Sleep Mode', 
      active: false, 
      trigger: 'Every day at 11:00 PM', 
      actions: ['Dim all lights to 20%', 'Lock all doors', 'Set AC to 26°C'],
      last_run: 'Never'
    },
    { 
      id: 4, 
      name: 'Security Alert', 
      active: true, 
      trigger: 'Motion detected when away', 
      actions: ['Turn on all lights', 'Send notification', 'Record cameras'],
      last_run: 'Never'
    }
  ]);

  const [notifications, setNotifications] = useState([
    { id: 1, message: 'Front door unlocked', time: '5 min ago', type: 'security' },
    { id: 2, message: 'Energy usage 15% below average', time: '1 hour ago', type: 'energy' },
    { id: 3, message: 'Dishwasher cycle completed', time: '2 hours ago', type: 'appliance' }
  ]);

  const [currentTime, setCurrentTime] = useState(new Date());
  const [activeTab, setActiveTab] = useState('dashboard');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [darkMode, setDarkMode] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState('connected');

  // Real-time updates
  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  // Simulate real-time sensor updates
  useEffect(() => {
    const sensorInterval = setInterval(() => {
      setDevices(prev => ({
        ...prev,
        sensors: {
          ...prev.sensors,
          humidity: Math.max(30, Math.min(70, prev.sensors.humidity + (Math.random() - 0.5) * 2)),
          light: Math.max(0, Math.min(100, prev.sensors.light + (Math.random() - 0.5) * 5)),
          noise_level: Math.max(20, Math.min(80, prev.sensors.noise_level + (Math.random() - 0.5) * 3))
        }
      }));
      
      setEnergyData(prev => ({
        ...prev,
        current: Math.max(0.5, Math.min(5.0, prev.current + (Math.random() - 0.5) * 0.2))
      }));
    }, 3000);

    return () => clearInterval(sensorInterval);
  }, []);

  // Device control functions
  const toggleLight = useCallback((room) => {
    setDevices(prev => ({
      ...prev,
      lights: {
        ...prev.lights,
        [room]: {
          ...prev.lights[room],
          on: !prev.lights[room].on
        }
      }
    }));
  }, []);

  const adjustLightBrightness = useCallback((room, change) => {
    setDevices(prev => ({
      ...prev,
      lights: {
        ...prev.lights,
        [room]: {
          ...prev.lights[room],
          brightness: Math.max(0, Math.min(100, prev.lights[room].brightness + change))
        }
      }
    }));
  }, []);

  const adjustThermostat = useCallback((change) => {
    setDevices(prev => ({
      ...prev,
      climate: {
        ...prev.climate,
        target: Math.max(16, Math.min(30, prev.climate.target + change))
      }
    }));
  }, []);

  const toggleAppliance = useCallback((appliance, property = 'on') => {
    setDevices(prev => ({
      ...prev,
      appliances: {
        ...prev.appliances,
        [appliance]: {
          ...prev.appliances[appliance],
          [property]: !prev.appliances[appliance][property]
        }
      }
    }));
  }, []);

  const toggleAutomationRule = useCallback((ruleId) => {
    setAutomationRules(prev =>
      prev.map(rule =>
        rule.id === ruleId ? { ...rule, active: !rule.active } : rule
      )
    );
  }, []);

  const dismissNotification = useCallback((id) => {
    setNotifications(prev => prev.filter(notif => notif.id !== id));
  }, []);

  // Utility functions
  const getPriorityColor = (priority) => {
    switch(priority) {
      case 'high': return 'text-red-600 bg-red-100 border-red-200';
      case 'medium': return 'text-yellow-600 bg-yellow-100 border-yellow-200';
      case 'low': return 'text-green-600 bg-green-100 border-green-200';
      default: return 'text-gray-600 bg-gray-100 border-gray-200';
    }
  };

  const getWeatherIcon = (condition) => {
    switch(condition) {
      case 'sunny': return <Sun className="w-6 h-6 text-yellow-500" />;
      case 'cloudy': return <Cloud className="w-6 h-6 text-gray-500" />;
      case 'rainy': return <Droplets className="w-6 h-6 text-blue-500" />;
      default: return <Sun className="w-6 h-6 text-yellow-500" />;
    }
  };

  const formatTime = (date) => {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const formatDate = (date) => {
    return date.toLocaleDateString([], { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
  };

  // Navigation component
  const Sidebar = () => (
    <div className={`${sidebarOpen ? 'translate-x-0' : '-translate-x-full'} fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0`}>
      <div className="flex items-center justify-between h-16 px-6 border-b">
        <div className="flex items-center">
          <Home className="w-8 h-8 text-blue-600" />
          <span className="ml-2 text-xl font-bold">SmartHome</span>
        </div>
        <button 
          onClick={() => setSidebarOpen(false)}
          className="lg:hidden"
        >
          <X className="w-6 h-6" />
        </button>
      </div>
      
      <nav className="mt-6">
        {[
          { id: 'dashboard', name: 'Dashboard', icon: Home },
          { id: 'devices', name: 'Devices', icon: Smartphone },
          { id: 'security', name: 'Security', icon: Shield },
          { id: 'energy', name: 'Energy', icon: Zap },
          { id: 'automation', name: 'Automation', icon: Settings },
          { id: 'insights', name: 'AI Insights', icon: TrendingUp }
        ].map(item => (
          <button
            key={item.id}
            onClick={() => {
              setActiveTab(item.id);
              setSidebarOpen(false);
            }}
            className={`w-full flex items-center px-6 py-3 text-left hover:bg-blue-50 transition-colors ${
              activeTab === item.id ? 'bg-blue-100 text-blue-600 border-r-2 border-blue-600' : 'text-gray-700'
            }`}
          >
            <item.icon className="w-5 h-5 mr-3" />
            {item.name}
          </button>
        ))}
      </nav>
    </div>
  );

  // Dashboard Components
  const DashboardView = () => (
    <div className="space-y-6">
      {/* Status Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Energy Usage</p>
              <p className="text-2xl font-bold text-blue-600">{energyData.current} kW</p>
            </div>
            <div className="bg-blue-100 p-3 rounded-xl">
              <Zap className="w-6 h-6 text-blue-600" />
            </div>
          </div>
          <p className="text-sm text-gray-500 mt-2">
            ${energyData.cost_today.toFixed(2)} today
          </p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Temperature</p>
              <p className="text-2xl font-bold text-orange-600">{devices.climate.temperature}°C</p>
            </div>
            <div className="bg-orange-100 p-3 rounded-xl">
              <Thermometer className="w-6 h-6 text-orange-600" />
            </div>
          </div>
          <p className="text-sm text-gray-500 mt-2">
            Target: {devices.climate.target}°C
          </p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Security</p>
              <p className="text-2xl font-bold text-green-600">
                {devices.security.armed ? 'ARMED' : 'DISARMED'}
              </p>
            </div>
            <div className="bg-green-100 p-3 rounded-xl">
              <Shield className="w-6 h-6 text-green-600" />
            </div>
          </div>
          <p className="text-sm text-gray-500 mt-2">
            All sensors active
          </p>
        </div>

        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Connected Devices</p>
              <p className="text-2xl font-bold text-purple-600">24/26</p>
            </div>
            <div className="bg-purple-100 p-3 rounded-xl">
              <Wifi className="w-6 h-6 text-purple-600" />
            </div>
          </div>
          <p className="text-sm text-gray-500 mt-2">
            2 devices offline
          </p>
        </div>
      </div>

      {/* Quick Controls */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Lighting Quick Control */}
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Lightbulb className="w-5 h-5 mr-2 text-yellow-600" />
            Quick Lighting
          </h3>
          <div className="grid grid-cols-2 gap-3">
            {Object.entries(devices.lights).slice(0, 4).map(([room, light]) => (
              <button
                key={room}
                onClick={() => toggleLight(room)}
                className={`p-3 rounded-xl transition-all text-left ${
                  light.on 
                    ? 'bg-yellow-100 text-yellow-800 border border-yellow-300' 
                    : 'bg-gray-100 text-gray-600 border border-gray-200'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-medium capitalize text-sm">
                      {room.replace('_', ' ')}
                    </div>
                    <div className="text-xs opacity-70">
                      {light.on ? `${light.brightness}%` : 'OFF'}
                    </div>
                  </div>
                  <Lightbulb className={`w-4 h-4 ${light.on ? 'text-yellow-600' : 'text-gray-400'}`} />
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Climate Control */}
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Thermometer className="w-5 h-5 mr-2 text-blue-600" />
            Climate Control
          </h3>
          <div className="flex items-center justify-between mb-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">{devices.climate.temperature}°C</div>
              <div className="text-sm text-gray-600">Current</div>
            </div>
            <div className="flex items-center space-x-3">
              <button
                onClick={() => adjustThermostat(-1)}
                className="bg-blue-100 text-blue-600 p-2 rounded-full hover:bg-blue-200 transition-colors"
              >
                <Minus className="w-4 h-4" />
              </button>
              <div className="text-center">
                <div className="text-xl font-bold">{devices.climate.target}°C</div>
                <div className="text-sm text-gray-600">Target</div>
              </div>
              <button
                onClick={() => adjustThermostat(1)}
                className="bg-blue-100 text-blue-600 p-2 rounded-full hover:bg-blue-200 transition-colors"
              >
                <Plus className="w-4 h-4" />
              </button>
            </div>
            <div className="flex flex-col space-y-2">
              <button
                onClick={() => toggleAppliance('ac', 'on')}
                className={`p-2 rounded-lg transition-colors ${
                  devices.climate.ac_on ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-400'
                }`}
              >
                <Fan className="w-5 h-5" />
              </button>
            </div>
          </div>
          <div className="flex items-center justify-between text-sm text-gray-600">
            <span>Humidity: {devices.sensors.humidity.toFixed(0)}%</span>
            <span>Mode: {devices.climate.mode}</span>
          </div>
        </div>
      </div>

      {/* Recent Activity & Weather */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Activity className="w-5 h-5 mr-2 text-indigo-600" />
            Recent Activity
          </h3>
          <div className="space-y-3">
            {notifications.slice(0, 5).map(notification => (
              <div key={notification.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center">
                  <div className={`w-2 h-2 rounded-full mr-3 ${
                    notification.type === 'security' ? 'bg-red-500' : 
                    notification.type === 'energy' ? 'bg-green-500' : 'bg-blue-500'
                  }`} />
                  <div>
                    <div className="text-sm font-medium">{notification.message}</div>
                    <div className="text-xs text-gray-500">{notification.time}</div>
                  </div>
                </div>
                <button
                  onClick={() => dismissNotification(notification.id)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Sun className="w-5 h-5 mr-2 text-yellow-600" />
            Weather
          </h3>
          <div className="text-center mb-4">
            <div className="flex items-center justify-center mb-2">
              {getWeatherIcon(weatherData.condition)}
            </div>
            <div className="text-3xl font-bold">{weatherData.temperature}°C</div>
            <div className="text-sm text-gray-600 capitalize">{weatherData.condition}</div>
          </div>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-600">Humidity</span>
              <span className="font-medium">{weatherData.humidity}%</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Wind</span>
              <span className="font-medium">{weatherData.wind_speed} km/h</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">UV Index</span>
              <span className="font-medium">{weatherData.uv_index}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  // Devices View
  const DevicesView = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Lighting Control */}
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold flex items-center">
              <Lightbulb className="w-6 h-6 text-yellow-600 mr-2" />
              Lighting System
            </h2>
            <div className="text-sm text-gray-500">
              {Object.values(devices.lights).filter(light => light.on).length}/{Object.keys(devices.lights).length} ON
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {Object.entries(devices.lights).map(([room, light]) => (
              <div key={room} className={`p-4 rounded-xl border transition-all ${
                light.on ? 'bg-yellow-50 border-yellow-300' : 'bg-gray-50 border-gray-200'
              }`}>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center">
                    <Lightbulb className={`w-5 h-5 mr-2 ${light.on ? 'text-yellow-600' : 'text-gray-400'}`} />
                    <span className="font-medium capitalize">{room.replace('_', ' ')}</span>
                  </div>
                  <button
                    onClick={() => toggleLight(room)}
                    className={`w-10 h-6 rounded-full transition-colors ${
                      light.on ? 'bg-yellow-500' : 'bg-gray-300'
                    }`}
                  >
                    <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                      light.on ? 'translate-x-5' : 'translate-x-1'
                    }`} />
                  </button>
                </div>
                {light.on && (
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-gray-600">Brightness</span>
                      <span className="text-sm font-medium">{light.brightness}%</span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => adjustLightBrightness(room, -10)}
                        className="p-1 bg-gray-200 rounded hover:bg-gray-300"
                      >
                        <Minus className="w-3 h-3" />
                      </button>
                      <div className="flex-1 bg-gray-200 rounded-full h-2">
                        <div 
                          className="bg-yellow-500 h-2 rounded-full transition-all"
                          style={{ width: `${light.brightness}%` }}
                        />
                      </div>
                      <button
                        onClick={() => adjustLightBrightness(room, 10)}
                        className="p-1 bg-gray-200 rounded hover:bg-gray-300"
                      >
                        <Plus className="w-3 h-3" />
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Appliances Control */}
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold flex items-center">
              <Power className="w-6 h-6 text-purple-600 mr-2" />
              Smart Appliances
            </h2>
          </div>
          <div className="space-y-4">
            {[
              { key: 'tv', name: 'Smart TV', icon: Tv, extra: `Ch. ${devices.appliances.tv.channel}` },
              { key: 'music', name: 'Music System', icon: Volume2, extra: `Vol. ${devices.appliances.music.volume}%` },
              { key: 'coffee_maker', name: 'Coffee Maker', icon: Coffee, extra: devices.appliances.coffee_maker.scheduled ? 'Scheduled' : '' },
              { key: 'car_charger', name: 'Car Charger', icon: Car, extra: `${devices.appliances.car_charger.charge_level}%` }
            ].map(appliance => (
              <div key={appliance.key} className="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                <div className="flex items-center">
                  <appliance.icon className={`w-5 h-5 mr-3 ${
                    devices.appliances[appliance.key].on ? 'text-purple-600' : 'text-gray-400'
                  }`} />
                  <div>
                    <div className="font-medium">{appliance.name}</div>
                    {appliance.extra && (
                      <div className="text-sm text-gray-500">{appliance.extra}</div>
                    )}
                  </div>
                </div>
                <button
                  onClick={() => toggleAppliance(appliance.key)}
                  className={`w-12 h-6 rounded-full transition-colors ${
                    devices.appliances[appliance.key].on ? 'bg-purple-500' : 'bg-gray-300'
                  }`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                    devices.appliances[appliance.key].on ? 'translate-x-7' : 'translate-x-1'
                  }`} />
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );

  // Energy View
  const EnergyView = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {[
          { label: 'Current Usage', value: `${energyData.current} kW`, color: 'blue', icon: Zap },
          { label: 'Daily Cost', value: `$${energyData.cost_today}`, color: 'green', icon: Battery },
          { label: 'Solar Generated', value: `${energyData.solar_generated} kWh`, color: 'yellow', icon: Sun },
          { label: 'Grid Usage', value: `${energyData.grid_usage} kWh`, color: 'purple', icon: Activity }
        ].map(item => (
          <div key={item.label} className="bg-white rounded-2xl shadow-sm p-6 border">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">{item.label}</p>
                <p className={`text-2xl font-bold text-${item.color}-600`}>{item.value}</p>
              </div>
              <div className={`bg-${item.color}-100 p-3 rounded-xl`}>
                <item.icon className={`w-6 h-6 text-${item.color}-600`} />
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Energy Usage Chart */}
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-6 flex items-center">
            <BarChart3 className="w-5 h-5 mr-2 text-blue-600" />
            Energy Usage Trends
          </h3>
          <div className="space-y-4">
            {[
              { period: 'Today', usage: energyData.daily, target: 20, color: 'blue' },
              { period: 'This Week', usage: energyData.weekly, target: 140, color: 'green' },
              { period: 'This Month', usage: energyData.monthly, target: 600, color: 'purple' }
            ].map(item => (
              <div key={item.period}>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium">{item.period}</span>
                  <span className="text-sm text-gray-600">{item.usage} / {item.target} kWh</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div 
                    className={`bg-${item.color}-500 h-3 rounded-full transition-all duration-500`}
                    style={{ width: `${Math.min((item.usage / item.target) * 100, 100)}%` }}
                  />
                </div>
                <div className="flex justify-between text-xs text-gray-500 mt-1">
                  <span>{((item.usage / item.target) * 100).toFixed(1)}% of target</span>
                  <span className={item.usage > item.target ? 'text-red-500' : 'text-green-500'}>
                    {item.usage > item.target ? 'Over budget' : 'On track'}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Energy Saving Tips */}
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-6 flex items-center">
            <TrendingUp className="w-5 h-5 mr-2 text-green-600" />
            AI Energy Recommendations
          </h3>
          <div className="space-y-4">
            {[
              { 
                tip: 'Optimize AC schedule', 
                savings: '$12/month', 
                impact: 'High',
                description: 'Adjust temperature 2°C higher during day hours'
              },
              { 
                tip: 'LED lighting upgrade', 
                savings: '$8/month', 
                impact: 'Medium',
                description: 'Replace remaining incandescent bulbs'
              },
              { 
                tip: 'Smart power strips', 
                savings: '$5/month', 
                impact: 'Low',
                description: 'Eliminate phantom loads from electronics'
              }
            ].map((tip, index) => (
              <div key={index} className="p-4 bg-green-50 rounded-xl border border-green-200">
                <div className="flex justify-between items-start mb-2">
                  <h4 className="font-medium text-green-800">{tip.tip}</h4>
                  <span className="text-sm font-bold text-green-600">{tip.savings}</span>
                </div>
                <p className="text-sm text-green-700 mb-2">{tip.description}</p>
                <div className="flex justify-between items-center">
                  <span className={`text-xs px-2 py-1 rounded-full ${
                    tip.impact === 'High' ? 'bg-red-100 text-red-700' :
                    tip.impact === 'Medium' ? 'bg-yellow-100 text-yellow-700' :
                    'bg-blue-100 text-blue-700'
                  }`}>
                    {tip.impact} Impact
                  </span>
                  <button className="text-sm text-green-600 hover:text-green-800 font-medium">
                    Apply →
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );

  // Security View
  const SecurityView = () => (
    <div className="space-y-6">
      {/* Security Status */}
      <div className="bg-white rounded-2xl shadow-sm p-6 border">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold flex items-center">
            <Shield className="w-6 h-6 text-green-600 mr-2" />
            Security System
          </h2>
          <div className={`px-4 py-2 rounded-full text-sm font-medium ${
            devices.security.armed 
              ? 'bg-green-100 text-green-700 border border-green-300' 
              : 'bg-red-100 text-red-700 border border-red-300'
          }`}>
            <div className="flex items-center">
              <div className={`w-2 h-2 rounded-full mr-2 ${
                devices.security.armed ? 'bg-green-500' : 'bg-red-500'
              }`} />
              {devices.security.armed ? 'SYSTEM ARMED' : 'SYSTEM DISARMED'}
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Cameras */}
          <div className="space-y-4">
            <h3 className="font-semibold text-gray-800 flex items-center">
              <Camera className="w-4 h-4 mr-2" />
              Security Cameras
            </h3>
            {Object.entries(devices.security.cameras).map(([location, active]) => (
              <div key={location} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center">
                  <Camera className={`w-4 h-4 mr-2 ${active ? 'text-green-600' : 'text-gray-400'}`} />
                  <span className="capitalize">{location}</span>
                </div>
                <div className="flex items-center">
                  <div className={`w-2 h-2 rounded-full mr-2 ${active ? 'bg-green-500' : 'bg-red-500'}`} />
                  <span className="text-sm text-gray-600">{active ? 'Active' : 'Offline'}</span>
                </div>
              </div>
            ))}
          </div>

          {/* Doors & Windows */}
          <div className="space-y-4">
            <h3 className="font-semibold text-gray-800 flex items-center">
              <Lock className="w-4 h-4 mr-2" />
              Access Points
            </h3>
            {Object.entries(devices.security.doors).map(([door, locked]) => (
              <div key={door} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center">
                  <Lock className={`w-4 h-4 mr-2 ${locked ? 'text-green-600' : 'text-red-600'}`} />
                  <span className="capitalize">{door} Door</span>
                </div>
                <span className={`text-sm px-2 py-1 rounded ${
                  locked ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                }`}>
                  {locked ? 'Locked' : 'Unlocked'}
                </span>
              </div>
            ))}
            {Object.entries(devices.security.windows).map(([window, closed]) => (
              <div key={window} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center">
                  <Eye className={`w-4 h-4 mr-2 ${closed ? 'text-green-600' : 'text-orange-600'}`} />
                  <span className="capitalize">{window} Window</span>
                </div>
                <span className={`text-sm px-2 py-1 rounded ${
                  closed ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'
                }`}>
                  {closed ? 'Secure' : 'Open'}
                </span>
              </div>
            ))}
          </div>

          {/* Sensors */}
          <div className="space-y-4">
            <h3 className="font-semibold text-gray-800 flex items-center">
              <Activity className="w-4 h-4 mr-2" />
              Motion Sensors
            </h3>
            {Object.entries(devices.security.motion_sensors).map(([sensor, active]) => (
              <div key={sensor} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <div className="flex items-center">
                  <Activity className={`w-4 h-4 mr-2 ${active ? 'text-orange-600' : 'text-green-600'}`} />
                  <span className="capitalize">{sensor}</span>
                </div>
                <div className="flex items-center">
                  <div className={`w-2 h-2 rounded-full mr-2 ${active ? 'bg-orange-500' : 'bg-green-500'}`} />
                  <span className="text-sm text-gray-600">{active ? 'Motion' : 'Clear'}</span>
                </div>
              </div>
            ))}
            
            {/* Environmental Sensors */}
            <div className="pt-2 border-t">
              {[
                { name: 'Smoke Detector', value: devices.sensors.smoke, type: 'boolean', danger: true },
                { name: 'Gas Sensor', value: devices.sensors.gas, type: 'boolean', danger: true },
                { name: 'Water Leak', value: devices.sensors.water_leak, type: 'boolean', danger: true }
              ].map(sensor => (
                <div key={sensor.name} className="flex items-center justify-between p-2">
                  <span className="text-sm">{sensor.name}</span>
                  <div className="flex items-center">
                    <div className={`w-2 h-2 rounded-full mr-2 ${
                      sensor.value ? 'bg-red-500 animate-pulse' : 'bg-green-500'
                    }`} />
                    <span className={`text-xs px-2 py-1 rounded ${
                      sensor.value 
                        ? 'bg-red-100 text-red-700 font-medium' 
                        : 'bg-green-100 text-green-700'
                    }`}>
                      {sensor.value ? 'ALERT' : 'Normal'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  // Automation View
  const AutomationView = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-2xl shadow-sm p-6 border">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold flex items-center">
            <Settings className="w-6 h-6 text-indigo-600 mr-2" />
            Automation Rules
          </h2>
          <button className="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 transition-colors flex items-center">
            <Plus className="w-4 h-4 mr-2" />
            Add Rule
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {automationRules.map((rule) => (
            <div key={rule.id} className={`p-6 rounded-xl border-2 transition-all ${
              rule.active 
                ? 'bg-indigo-50 border-indigo-200' 
                : 'bg-gray-50 border-gray-200'
            }`}>
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <h3 className="font-semibold text-lg mb-1">{rule.name}</h3>
                  <p className="text-sm text-gray-600 mb-3">{rule.trigger}</p>
                  <div className="space-y-1">
                    <p className="text-sm font-medium text-gray-700">Actions:</p>
                    {rule.actions.map((action, index) => (
                      <div key={index} className="text-sm text-gray-600 flex items-center">
                        <CheckCircle className="w-3 h-3 mr-2 text-green-500" />
                        {action}
                      </div>
                    ))}
                  </div>
                </div>
                <button
                  onClick={() => toggleAutomationRule(rule.id)}
                  className={`w-12 h-6 rounded-full transition-colors ${
                    rule.active ? 'bg-indigo-500' : 'bg-gray-300'
                  }`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full transition-transform ${
                    rule.active ? 'translate-x-7' : 'translate-x-1'
                  }`} />
                </button>
              </div>
              <div className="flex items-center justify-between text-xs text-gray-500 pt-3 border-t">
                <span>Last run: {rule.last_run}</span>
                <span className={`px-2 py-1 rounded-full ${
                  rule.active ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'
                }`}>
                  {rule.active ? 'Active' : 'Inactive'}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Schedule Overview */}
      <div className="bg-white rounded-2xl shadow-sm p-6 border">
        <h3 className="text-lg font-semibold mb-6 flex items-center">
          <Clock className="w-5 h-5 mr-2 text-blue-600" />
          Today's Schedule
        </h3>
        <div className="space-y-3">
          {[
            { time: '06:30', event: 'Morning routine starts', type: 'routine' },
            { time: '07:00', event: 'Coffee maker activation', type: 'appliance' },
            { time: '08:00', event: 'Away mode (if no motion)', type: 'security' },
            { time: '17:30', event: 'Welcome home routine', type: 'routine' },
            { time: '22:00', event: 'Night mode preparation', type: 'routine' },
            { time: '23:00', event: 'Sleep mode activation', type: 'routine' }
          ].map((item, index) => (
            <div key={index} className="flex items-center p-3 bg-gray-50 rounded-lg">
              <div className="w-16 text-sm font-mono text-gray-600">{item.time}</div>
              <div className={`w-3 h-3 rounded-full mr-3 ${
                item.type === 'routine' ? 'bg-blue-500' :
                item.type === 'appliance' ? 'bg-purple-500' :
                'bg-green-500'
              }`} />
              <div className="flex-1">
                <span className="text-sm font-medium">{item.event}</span>
              </div>
              <div className={`text-xs px-2 py-1 rounded-full capitalize ${
                item.type === 'routine' ? 'bg-blue-100 text-blue-700' :
                item.type === 'appliance' ? 'bg-purple-100 text-purple-700' :
                'bg-green-100 text-green-700'
              }`}>
                {item.type}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  // AI Insights View
  const InsightsView = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-2xl shadow-sm p-6 border">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold flex items-center">
            <TrendingUp className="w-6 h-6 text-purple-600 mr-2" />
            AI Insights & Recommendations
          </h2>
          <div className="text-sm text-gray-500">
            Last updated: {formatTime(currentTime)}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {mlInsights.map((insight, index) => (
            <div key={index} className={`p-6 rounded-xl border-2 ${getPriorityColor(insight.priority)}`}>
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center">
                  {insight.type === 'optimization' && <Zap className="w-5 h-5 mr-2" />}
                  {insight.type === 'security' && <Shield className="w-5 h-5 mr-2" />}
                  {insight.type === 'energy' && <Battery className="w-5 h-5 mr-2" />}
                  {insight.type === 'maintenance' && <Settings className="w-5 h-5 mr-2" />}
                  <span className="text-sm font-semibold capitalize">{insight.type}</span>
                </div>
                <span className={`text-xs px-2 py-1 rounded-full font-medium capitalize ${
                  insight.priority === 'high' ? 'bg-red-100 text-red-700' :
                  insight.priority === 'medium' ? 'bg-yellow-100 text-yellow-700' :
                  'bg-green-100 text-green-700'
                }`}>
                  {insight.priority}
                </span>
              </div>
              
              <p className="text-sm font-medium mb-3">{insight.message}</p>
              
              <div className="space-y-2 text-xs">
                {insight.savings && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Potential Savings:</span>
                    <span className="font-medium text-green-600">{insight.savings}</span>
                  </div>
                )}
                {insight.timestamp && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Detected:</span>
                    <span className="font-medium">{insight.timestamp}</span>
                  </div>
                )}
                {insight.due_date && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Due Date:</span>
                    <span className="font-medium">{insight.due_date}</span>
                  </div>
                )}
                {insight.impact && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Impact:</span>
                    <span className={`font-medium ${insight.impact === 'positive' ? 'text-green-600' : 'text-red-600'}`}>
                      {insight.impact}
                    </span>
                  </div>
                )}
              </div>
              
              <div className="flex space-x-2 mt-4">
                <button className="flex-1 py-2 px-3 bg-white border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors">
                  Dismiss
                </button>
                <button className="flex-1 py-2 px-3 bg-purple-600 text-white rounded-lg text-sm font-medium hover:bg-purple-700 transition-colors">
                  Apply
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ML Model Performance */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <BarChart3 className="w-5 h-5 mr-2 text-blue-600" />
            Model Performance
          </h3>
          <div className="space-y-4">
            {[
              { model: 'Energy Prediction', accuracy: 94, status: 'Excellent' },
              { model: 'Pattern Recognition', accuracy: 87, status: 'Good' },
              { model: 'Anomaly Detection', accuracy: 92, status: 'Excellent' },
              { model: 'Optimization Engine', accuracy: 89, status: 'Good' }
            ].map((item, index) => (
              <div key={index}>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium">{item.model}</span>
                  <span className="text-sm text-gray-600">{item.accuracy}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className={`h-2 rounded-full transition-all duration-500 ${
                      item.accuracy >= 90 ? 'bg-green-500' :
                      item.accuracy >= 80 ? 'bg-yellow-500' : 'bg-red-500'
                    }`}
                    style={{ width: `${item.accuracy}%` }}
                  />
                </div>
                <div className="flex justify-between items-center mt-1">
                  <span className={`text-xs px-2 py-1 rounded-full ${
                    item.status === 'Excellent' ? 'bg-green-100 text-green-700' :
                    item.status === 'Good' ? 'bg-yellow-100 text-yellow-700' :
                    'bg-red-100 text-red-700'
                  }`}>
                    {item.status}
                  </span>
                  <span className="text-xs text-gray-500">Last trained: 2 days ago</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl shadow-sm p-6 border">
          <h3 className="text-lg font-semibold mb-4 flex items-center">
            <Activity className="w-5 h-5 mr-2 text-green-600" />
            Learning Progress
          </h3>
          <div className="space-y-4">
            <div className="text-center p-4 bg-green-50 rounded-xl">
              <div className="text-3xl font-bold text-green-600">2,847</div>
              <div className="text-sm text-green-700">Data Points Collected</div>
            </div>
            <div className="text-center p-4 bg-blue-50 rounded-xl">
              <div className="text-3xl font-bold text-blue-600">156</div>
              <div className="text-sm text-blue-700">Patterns Identified</div>
            </div>
            <div className="text-center p-4 bg-purple-50 rounded-xl">
              <div className="text-3xl font-bold text-purple-600">43</div>
              <div className="text-sm text-purple-700">Optimizations Applied</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  // Main render function
  const renderActiveView = () => {
    switch(activeTab) {
      case 'dashboard': return <DashboardView />;
      case 'devices': return <DevicesView />;
      case 'security': return <SecurityView />;
      case 'energy': return <EnergyView />;
      case 'automation': return <AutomationView />;
      case 'insights': return <InsightsView />;
      default: return <DashboardView />;
    }
  };

  return (
    <div className={`min-h-screen ${darkMode ? 'dark bg-gray-900' : 'bg-gradient-to-br from-blue-50 to-indigo-100'}`}>
      <div className="flex h-screen overflow-hidden">
        {/* Sidebar */}
        <Sidebar />
        
        {/* Sidebar overlay for mobile */}
        {sidebarOpen && (
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
            onClick={() => setSidebarOpen(false)}
          />
        )}
        
        {/* Main content */}
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* Header */}
          <header className="bg-white shadow-sm border-b px-6 py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <button
                  onClick={() => setSidebarOpen(true)}
                  className="lg:hidden p-2 rounded-lg hover:bg-gray-100"
                >
                  <Menu className="w-6 h-6" />
                </button>
                <div>
                  <h1 className="text-2xl font-bold text-gray-900">
                    {activeTab.charAt(0).toUpperCase() + activeTab.slice(1)}
                  </h1>
                  <p className="text-sm text-gray-600">{formatDate(currentTime)}</p>
                </div>
              </div>
              
              <div className="flex items-center space-x-4">
                {/* Connection Status */}
                <div className="flex items-center space-x-2">
                  <div className={`w-2 h-2 rounded-full ${
                    connectionStatus === 'connected' ? 'bg-green-500' :
                    connectionStatus === 'connecting' ? 'bg-yellow-500 animate-pulse' :
                    'bg-red-500'
                  }`} />
                  <span className="text-sm text-gray-600 capitalize">{connectionStatus}</span>
                </div>
                
                {/* Notifications */}
                <button className="relative p-2 rounded-lg hover:bg-gray-100">
                  <Bell className="w-5 h-5 text-gray-600" />
                  {notifications.length > 0 && (
                    <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                      {notifications.length}
                    </span>
                  )}
                </button>
                
                {/* Dark Mode Toggle */}
                <button
                  onClick={() => setDarkMode(!darkMode)}
                  className="p-2 rounded-lg hover:bg-gray-100"
                >
                  {darkMode ? <Sun className="w-5 h-5 text-gray-600" /> : <Moon className="w-5 h-5 text-gray-600" />}
                </button>
                
                {/* Current Time */}
                <div className="text-right">
                  <div className="text-lg font-semibold text-gray-900">
                    {formatTime(currentTime)}
                  </div>
                  <div className="text-sm text-gray-600">
                    {currentTime.toLocaleDateString([], { month: 'short', day: 'numeric' })}
                  </div>
                </div>
              </div>
            </div>
          </header>
          
          {/* Main content area */}
          <main className="flex-1 overflow-auto p-6">
            {renderActiveView()}
          </main>
        </div>
      </div>
    </div>
  );
};

export default SmartHomeApp;