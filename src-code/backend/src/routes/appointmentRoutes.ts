import express from 'express';
import {
  getAppointments,
  createAppointment,
  updateAppointment,
  cancelAppointment,
  getAvailableTimeSlots,
} from '../controllers/appointmentController';
import { authenticateToken } from '../middleware/auth';

const router = express.Router();

// GET /api/appointments/availability/:doctorId/:date - Get available time slots (public)
router.get('/availability/:doctorId/:date', getAvailableTimeSlots);

// All other appointment routes require authentication
router.use(authenticateToken);

// GET /api/appointments - Get all appointments for the authenticated user
router.get('/', getAppointments);

// POST /api/appointments - Create a new appointment
router.post('/', createAppointment);

// PUT /api/appointments/:id - Update an appointment
router.put('/:id', updateAppointment);

// DELETE /api/appointments/:id - Cancel an appointment
router.delete('/:id', cancelAppointment);

export default router;
