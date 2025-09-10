const express = require('express');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
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

// Middleware
app.use(cors());
app.use(express.json());

// Device state storage
let deviceState = {
  lights: { living_room: false, bedroom: true, kitchen: false, bathroom: false },
  thermostat: { temperature: 22, target: 24, mode: 'auto' },
  security: { armed: true, doors: { front: true, back: true }},
  appliances: { ac: false, fan: true, tv: false },
  sensors: { motion: false, smoke: false, humidity: 45, light: 75 }
};

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
  
  if (deviceState[category] && deviceState[category][device] !== undefined) {
    deviceState[category][device] = state;
    io.emit('deviceUpdate', { category, device, state });
    res.json({ success: true, message: `${device} updated to ${state}` });
  } else {
    res.status(404).json({ success: false, error: 'Device not found' });
  }
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

// Simulate sensor updates
setInterval(() => {
  deviceState.sensors.temperature = (20 + Math.random() * 10).toFixed(1);
  deviceState.sensors.humidity = (40 + Math.random() * 20).toFixed(1);
  deviceState.sensors.light = (Math.random() * 100).toFixed(1);
  
  io.emit('sensorUpdate', deviceState.sensors);
}, 5000);

server.listen(PORT, () => {
  console.log(`🚀 Smart Home Server running on port ${PORT}`);
  console.log(`📱 Dashboard: http://localhost:3000`);
  console.log(`🔧 API: http://localhost:${PORT}`);
});