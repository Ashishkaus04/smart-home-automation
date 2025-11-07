const express = require('express');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const mqtt = require('mqtt');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.REACT_APP_API_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 5000;
const MQTT_URL = process.env.MQTT_URL || 'mqtt://localhost:1883';

// Middleware
app.use(cors());
app.use(express.json());

// Device state storage
let deviceState = {
  lights: { 
    living_room: false, 
    bedroom: true, 
    kitchen: false, 
    bathroom: false,
    garage: false,
    garden: false
  },
  thermostat: { temperature: 22, target: 24, mode: 'auto' },
  security: { 
    armed: true, 
    doors: { front: true, back: true },
    motion: { living: false, bedroom: false, kitchen: false },
    windows: { living: true, bedroom: true, kitchen: true }
  },
  appliances: { ac: false, fan: true, tv: false, car_charger: false },
  sensors: { motion: false, smoke: false, humidity: 45, light: 75, temperature: 22 }
};

// MQTT client
const mqttClient = mqtt.connect(MQTT_URL);

mqttClient.on('connect', () => {
  console.log(`🔗 Connected to MQTT broker at ${MQTT_URL}`);
  // Subscribe to sensors and device state topics from hardware
  mqttClient.subscribe([
    'home/sensors/#',
    'home/lights/+/state',
    'home/security/doors/+/state',
    'home/security/armed/state',
    'home/appliances/+/state',
    'home/thermostat/+/state'
  ], (err) => {
    if (err) console.error('MQTT subscribe error:', err.message);
  });
});

function safeParse(payload) {
  try { return JSON.parse(payload.toString()); } catch (_) { return payload.toString(); }
}

mqttClient.on('message', (topic, payload) => {
  const data = safeParse(payload);
  // Sensors e.g., home/sensors/humidity
  if (topic.startsWith('home/sensors/')) {
    const key = topic.split('/')[2];
    if (deviceState.sensors.hasOwnProperty(key)) {
      deviceState.sensors[key] = typeof data === 'string' ? Number(data) : data;
      io.emit('sensorUpdate', deviceState.sensors);
    }
    // Also update thermostat temperature if key is 'temperature'
    if (key === 'temperature') {
      deviceState.thermostat.temperature = typeof data === 'string' ? Number(data) : data;
    }
    return;
  }

  // Lights e.g., home/lights/living_room/state
  if (topic.startsWith('home/lights/')) {
    const room = topic.split('/')[2];
    if (deviceState.lights.hasOwnProperty(room)) {
      deviceState.lights[room] = data === true || data === 'ON' || data === '1';
      io.emit('deviceUpdate', { category: 'lights', device: room, state: deviceState.lights[room] });
    }
    return;
  }

  // Security armed
  if (topic === 'home/security/armed/state') {
    deviceState.security.armed = data === true || data === 'ON' || data === '1';
    io.emit('deviceUpdate', { category: 'security', device: 'armed', state: deviceState.security.armed });
    return;
  }

  // Security doors e.g., home/security/doors/front/state
  if (topic.startsWith('home/security/doors/')) {
    const door = topic.split('/')[3];
    if (deviceState.security.doors.hasOwnProperty(door)) {
      deviceState.security.doors[door] = data === true || data === 'LOCKED' || data === '1' || data === 'ON';
      io.emit('deviceUpdate', { category: 'security', device: door, state: deviceState.security.doors[door] });
    }
    return;
  }

  // Security motion sensors e.g., home/security/motion_sensors/living/state
  if (topic.startsWith('home/security/motion_sensors/')) {
    const location = topic.split('/')[3];
    if (deviceState.security.motion.hasOwnProperty(location)) {
      deviceState.security.motion[location] = data === true || data === 'ON' || data === '1';
      io.emit('deviceUpdate', { category: 'security', device: `motion_${location}`, state: deviceState.security.motion[location] });
      // Also update general motion sensor
      deviceState.sensors.motion = Object.values(deviceState.security.motion).some(v => v === true);
    }
    return;
  }

  // Appliances e.g., home/appliances/ac/state
  if (topic.startsWith('home/appliances/')) {
    const appliance = topic.split('/')[2];
    if (deviceState.appliances.hasOwnProperty(appliance)) {
      deviceState.appliances[appliance] = data === true || data === 'ON' || data === '1';
      io.emit('deviceUpdate', { category: 'appliances', device: appliance, state: deviceState.appliances[appliance] });
    }
    return;
  }

  // Thermostat e.g., home/thermostat/temperature/state
  if (topic.startsWith('home/thermostat/')) {
    const field = topic.split('/')[2];
    if (['temperature', 'target', 'mode'].includes(field)) {
      deviceState.thermostat[field] = field === 'mode' ? String(data) : Number(data);
      io.emit('deviceUpdate', { category: 'thermostat', device: field, state: deviceState.thermostat[field] });
    }
  }
});

function mqttPublish(topic, value) {
  const payload = typeof value === 'string' ? value : JSON.stringify(value);
  mqttClient.publish(topic, payload, { qos: 0, retain: false });
}

// Routes
app.get('/', (req, res) => {
  res.json({ 
    message: '🏠 Smart Home API Server',
    status: 'Running',
    version: '1.0.0',
    endpoints: {
      devices: '/api/devices',
      control: '/api/devices/:category/:device',
      sensors: '/api/sensors',
      ml: '/api/ml/prediction'
    }
  });
});

app.get('/api/devices', (req, res) => {
  res.json({
    success: true,
    data: deviceState,
    timestamp: new Date().toISOString()
  });
});

app.post('/api/devices/:category/:device', (req, res) => {
  const { category, device } = req.params;
  const { state } = req.body;
  
  let updated = false;
  // Handle flat categories
  if (deviceState[category] && deviceState[category][device] !== undefined) {
    deviceState[category][device] = state;
    updated = true;
  }
  // Handle nested security doors
  if (!updated && category === 'security' && deviceState.security.doors[device] !== undefined) {
    deviceState.security.doors[device] = state;
    updated = true;
  }

  if (!updated) {
    return res.status(404).json({ success: false, error: 'Device not found' });
  }

  // Emit to websocket clients
  io.emit('deviceUpdate', { category, device, state });

  // Publish to MQTT for hardware to act upon
  if (category === 'lights') {
    mqttPublish(`home/lights/${device}/set`, state ? 'ON' : 'OFF');
  } else if (category === 'appliances') {
    mqttPublish(`home/appliances/${device}/set`, state ? 'ON' : 'OFF');
  } else if (category === 'security' && device === 'armed') {
    mqttPublish('home/security/armed/set', state ? 'ON' : 'OFF');
  } else if (category === 'security') {
    mqttPublish(`home/security/doors/${device}/set`, state ? 'LOCK' : 'UNLOCK');
  } else if (category === 'thermostat') {
    mqttPublish(`home/thermostat/${device}/set`, state);
  }

  res.json({ success: true, message: `${device} updated to ${state}` });
});

app.get('/api/ml/prediction', (req, res) => {
  // Mock ML prediction
  const prediction = {
    energy_consumption: (Math.random() * 50 + 100).toFixed(1),
    cost_estimate: (Math.random() * 20 + 30).toFixed(2),
    optimization_potential: (Math.random() * 25 + 5).toFixed(1),
    recommendations: [
      'Consider adjusting AC temperature by 1°C',
      'Optimize lighting schedule based on usage patterns'
    ]
  };
  res.json({ success: true, data: prediction });
});

// Socket.io for real-time updates
io.on('connection', (socket) => {
  console.log(`🔌 Client connected: ${socket.id}`);
  
  socket.emit('deviceState', deviceState);
  
  socket.on('disconnect', () => {
    console.log(`🔌 Client disconnected: ${socket.id}`);
  });
});

// Optional: Simulated sensor updates can be disabled when hardware is connected
if (process.env.SIMULATE_SENSORS !== 'false') {
  setInterval(() => {
    deviceState.sensors.temperature = (20 + Math.random() * 10).toFixed(1);
    deviceState.sensors.humidity = (40 + Math.random() * 20).toFixed(1);
    deviceState.sensors.light = (Math.random() * 100).toFixed(1);
    io.emit('sensorUpdate', deviceState.sensors);
  }, 5000);
}

server.listen(PORT, () => {
  console.log(`🚀 Smart Home Server running on port ${PORT}`);
  console.log(`📱 Dashboard: http://localhost:3000`);
  console.log(`🔧 API: http://localhost:${PORT}`);
});