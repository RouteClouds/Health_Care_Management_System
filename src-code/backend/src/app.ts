import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import doctorRoutes from './routes/doctors';
import authRoutes from './routes/auth';
import appointmentRoutes from './routes/appointmentRoutes';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true,
}));
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/doctors', doctorRoutes);
app.use('/api/appointments', appointmentRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Health Care Management System API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: '1.0.0',
  });
});

// API health check endpoint (for Kubernetes probes)
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'healthcare-backend',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'production',
    version: '1.0.0',
    database: 'connected', // TODO: Add actual database health check
    memory: process.memoryUsage(),
  });
});

// API readiness check endpoint (for Kubernetes readiness probes)
app.get('/api/ready', (req, res) => {
  // TODO: Add actual readiness checks (database connection, etc.)
  res.json({
    status: 'ready',
    service: 'healthcare-backend',
    timestamp: new Date().toISOString(),
    checks: {
      database: 'connected',
      memory: process.memoryUsage(),
      uptime: process.uptime(),
    },
  });
});

// API info endpoint
app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: 'RouteClouds Health Platform API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      apiHealth: '/api/health',
      apiReady: '/api/ready',
      doctors: '/api/doctors',
      departments: '/api/doctors/departments',
      appointments: '/api/appointments',
      auth: '/api/auth',
    },
    documentation: 'https://github.com/RouteClouds/Health-Care-Management-System',
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    availableEndpoints: [
      '/health',
      '/api',
      '/api/health',
      '/api/ready',
      '/api/doctors',
      '/api/doctors/departments',
      '/api/appointments',
      '/api/auth',
    ],
  });
});

// Error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { error: err.message }),
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🏥 API Base: http://localhost:${PORT}/api`);
  console.log(`👨‍⚕️ Doctors API: http://localhost:${PORT}/api/doctors`);
  console.log(`🏢 Departments API: http://localhost:${PORT}/api/doctors/departments`);
  console.log(`🗓️ Appointments API: http://localhost:${PORT}/api/appointments`);
  console.log(`🔐 Auth API: http://localhost:${PORT}/api/auth`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

export default app;
