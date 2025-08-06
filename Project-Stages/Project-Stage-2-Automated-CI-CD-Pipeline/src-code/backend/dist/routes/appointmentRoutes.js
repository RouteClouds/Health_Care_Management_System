"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const appointmentController_1 = require("../controllers/appointmentController");
const auth_1 = require("../middleware/auth");
const router = express_1.default.Router();
// GET /api/appointments/availability/:doctorId/:date - Get available time slots (public)
router.get('/availability/:doctorId/:date', appointmentController_1.getAvailableTimeSlots);
// All other appointment routes require authentication
router.use(auth_1.authenticateToken);
// GET /api/appointments - Get all appointments for the authenticated user
router.get('/', appointmentController_1.getAppointments);
// POST /api/appointments - Create a new appointment
router.post('/', appointmentController_1.createAppointment);
// PUT /api/appointments/:id - Update an appointment
router.put('/:id', appointmentController_1.updateAppointment);
// DELETE /api/appointments/:id - Cancel an appointment
router.delete('/:id', appointmentController_1.cancelAppointment);
exports.default = router;
//# sourceMappingURL=appointmentRoutes.js.map