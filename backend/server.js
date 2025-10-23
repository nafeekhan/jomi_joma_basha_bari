require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const path = require('path');

// Import routes
const authRoutes = require('./src/routes/auth');
const propertyRoutes = require('./src/routes/properties');
const sceneRoutes = require('./src/routes/scenes');
const roomRoutes = require('./src/routes/rooms');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet({
  contentSecurityPolicy: false, // Disabled for Marzipano to work
  crossOriginEmbedderPolicy: false
}));
app.use(cors({
  origin: process.env.FRONTEND_URL || '*',
  credentials: true
}));
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files (Marzipano viewer, uploaded images)
app.use('/public', express.static(path.join(__dirname, 'public')));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/scenes', sceneRoutes);
app.use('/api/rooms', roomRoutes);

// Serve Marzipano viewer (legacy - single scenes)
app.get('/viewer', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'viewer.html'));
});

// Serve Marzipano viewer with rooms support (multi-viewpoint)
app.get('/viewer-rooms', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'viewer-rooms.html'));
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Real Estate Platform API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      properties: '/api/properties',
      scenes: '/api/scenes',
      viewer: '/viewer?propertyId=<id>',
      health: '/health'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
app.listen(PORT, () => {
  console.log('\n🚀 Real Estate Platform Backend Server');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`📡 Server running on: http://localhost:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📊 Database: ${process.env.DB_NAME || 'real_estate_db'}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('\n📚 Available endpoints:');
  console.log('   • POST   /api/auth/register');
  console.log('   • POST   /api/auth/login');
  console.log('   • GET    /api/auth/me');
  console.log('   • GET    /api/properties');
  console.log('   • GET    /api/properties/:id');
  console.log('   • POST   /api/properties');
  console.log('   • GET    /api/properties/:propertyId/scenes');
  console.log('   • GET    /api/scenes/:sceneId');
  console.log('   • GET    /viewer?propertyId=<id>');
  console.log('   • GET    /health');
  console.log('\n✅ Ready to accept requests!\n');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  app.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

