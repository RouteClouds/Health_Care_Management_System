"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const dotenv_1 = __importDefault(require("dotenv"));
const doctors_1 = __importDefault(require("./routes/doctors"));
const auth_1 = __importDefault(require("./routes/auth"));
const appointmentRoutes_1 = __importDefault(require("./routes/appointmentRoutes"));
// Load environment variables
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3001;
// Middleware
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)({
    origin: process.env.FRONTEND_URL || 'http://localhost:5173',
    credentials: true,
}));
app.use((0, morgan_1.default)('combined'));
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Routes
app.use('/api/auth', auth_1.default);
app.use('/api/doctors', doctors_1.default);
app.use('/api/appointments', appointmentRoutes_1.default);
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
// API info endpoint
app.get('/api', (req, res) => {
    res.json({
        success: true,
        message: 'RouteClouds Health Platform API',
        version: '1.0.0',
        endpoints: {
            health: '/health',
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
            '/api/doctors',
            '/api/doctors/departments',
            '/api/appointments',
            '/api/auth',
        ],
    });
});
// Error handler
app.use((err, req, res, next) => {
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
exports.default = app;
//# sourceMappingURL=app.js.map