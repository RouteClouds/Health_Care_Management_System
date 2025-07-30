import { apiClient } from './api';
import type { Appointment } from '../types';

// Appointment API Types
export interface CreateAppointmentRequest {
  doctorId: string;
  dateTime: string;
  type: 'IN_PERSON' | 'TELEMEDICINE';
  notes?: string;
}

export interface UpdateAppointmentRequest {
  dateTime?: string;
  status?: 'SCHEDULED' | 'COMPLETED' | 'CANCELLED' | 'NO_SHOW';
  type?: 'IN_PERSON' | 'TELEMEDICINE';
  notes?: string;
}

export interface AppointmentResponse {
  appointments: Appointment[];
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface AppointmentParams {
  page?: number;
  limit?: number;
  status?: string;
  doctorId?: string;
  patientId?: string;
  startDate?: string;
  endDate?: string;
}

export interface TimeSlot {
  time: string;
  available: boolean;
  doctorId: string;
}

export interface DoctorAvailability {
  doctorId: string;
  date: string;
  timeSlots: TimeSlot[];
}

export const appointmentService = {
  // Get all appointments for current user
  async getAppointments(params?: AppointmentParams): Promise<{ success: boolean; data: AppointmentResponse }> {
    return apiClient.get('/appointments', { params });
  },

  // Get appointment by ID
  async getAppointmentById(id: string): Promise<{ success: boolean; data: Appointment }> {
    return apiClient.get(`/appointments/${id}`);
  },

  // Create new appointment
  async createAppointment(data: CreateAppointmentRequest): Promise<{ success: boolean; data: Appointment; message: string }> {
    return apiClient.post('/appointments', data);
  },

  // Update appointment
  async updateAppointment(id: string, data: UpdateAppointmentRequest): Promise<{ success: boolean; data: Appointment; message: string }> {
    return apiClient.put(`/appointments/${id}`, data);
  },

  // Cancel appointment
  async cancelAppointment(id: string): Promise<{ success: boolean; message: string }> {
    return apiClient.delete(`/appointments/${id}`);
  },

  // Get doctor availability for a specific date
  async getDoctorAvailability(doctorId: string, date: string): Promise<{ success: boolean; data: DoctorAvailability }> {
    return apiClient.get(`/appointments/availability/${doctorId}/${date}`);
  },

  // Get available time slots for a doctor on a specific date
  async getAvailableTimeSlots(doctorId: string, date: string): Promise<{ success: boolean; data: TimeSlot[] }> {
    return apiClient.get(`/appointments/availability/${doctorId}/${date}`);
  },

  // Get appointments for a specific doctor
  async getDoctorAppointments(doctorId: string, params?: AppointmentParams): Promise<{ success: boolean; data: AppointmentResponse }> {
    return apiClient.get(`/appointments/doctor/${doctorId}`, { params });
  },

  // Get patient's appointment history (same as getAppointments)
  async getPatientAppointments(params?: AppointmentParams): Promise<{ success: boolean; data: AppointmentResponse }> {
    return apiClient.get('/appointments', { params });
  },

  // Reschedule appointment (same as update)
  async rescheduleAppointment(id: string, newDateTime: string): Promise<{ success: boolean; data: Appointment; message: string }> {
    return apiClient.put(`/appointments/${id}`, { dateTime: newDateTime });
  },
};
