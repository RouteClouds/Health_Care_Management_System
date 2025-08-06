import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'react-hot-toast';
import { appointmentService, type CreateAppointmentRequest, type UpdateAppointmentRequest, type AppointmentParams } from '../services/appointmentService';

// Query keys for appointments
export const appointmentKeys = {
  all: ['appointments'] as const,
  lists: () => [...appointmentKeys.all, 'list'] as const,
  list: (params?: AppointmentParams) => [...appointmentKeys.lists(), params] as const,
  details: () => [...appointmentKeys.all, 'detail'] as const,
  detail: (id: string) => [...appointmentKeys.details(), id] as const,
  availability: (doctorId: string, date: string) => ['appointments', 'availability', doctorId, date] as const,
  timeSlots: (doctorId: string, date: string) => ['appointments', 'timeslots', doctorId, date] as const,
  doctorAppointments: (doctorId: string) => ['appointments', 'doctor', doctorId] as const,
  patientHistory: () => ['appointments', 'patient', 'history'] as const,
};

// Hook to get appointments
export const useAppointments = (params?: AppointmentParams) => {
  return useQuery({
    queryKey: appointmentKeys.list(params),
    queryFn: () => appointmentService.getAppointments(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000, // 10 minutes
  });
};

// Hook to get appointment by ID
export const useAppointment = (id: string) => {
  return useQuery({
    queryKey: appointmentKeys.detail(id),
    queryFn: () => appointmentService.getAppointmentById(id),
    enabled: !!id,
    staleTime: 5 * 60 * 1000,
  });
};

// Hook to get doctor availability
export const useDoctorAvailability = (doctorId: string, date: string) => {
  return useQuery({
    queryKey: appointmentKeys.availability(doctorId, date),
    queryFn: () => appointmentService.getDoctorAvailability(doctorId, date),
    enabled: !!doctorId && !!date,
    staleTime: 2 * 60 * 1000, // 2 minutes
  });
};

// Hook to get available time slots
export const useAvailableTimeSlots = (doctorId: string, date: string) => {
  return useQuery({
    queryKey: appointmentKeys.timeSlots(doctorId, date),
    queryFn: () => appointmentService.getAvailableTimeSlots(doctorId, date),
    enabled: !!doctorId && !!date,
    staleTime: 1 * 60 * 1000, // 1 minute
  });
};

// Hook to get patient appointment history
export const usePatientAppointments = (params?: AppointmentParams) => {
  return useQuery({
    queryKey: appointmentKeys.patientHistory(),
    queryFn: () => appointmentService.getPatientAppointments(params),
    staleTime: 5 * 60 * 1000,
  });
};

// Hook to create appointment
export const useCreateAppointment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateAppointmentRequest) => appointmentService.createAppointment(data),
    onSuccess: (response) => {
      // Invalidate and refetch appointment queries
      queryClient.invalidateQueries({ queryKey: appointmentKeys.all });
      toast.success(response.message || 'Appointment booked successfully!');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to book appointment');
    },
  });
};

// Hook to update appointment
export const useUpdateAppointment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateAppointmentRequest }) => 
      appointmentService.updateAppointment(id, data),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: appointmentKeys.all });
      toast.success(response.message || 'Appointment updated successfully!');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to update appointment');
    },
  });
};

// Hook to cancel appointment
export const useCancelAppointment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => appointmentService.cancelAppointment(id),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: appointmentKeys.all });
      toast.success(response.message || 'Appointment cancelled successfully!');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to cancel appointment');
    },
  });
};

// Hook to reschedule appointment
export const useRescheduleAppointment = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, newDateTime }: { id: string; newDateTime: string }) => 
      appointmentService.rescheduleAppointment(id, newDateTime),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: appointmentKeys.all });
      toast.success(response.message || 'Appointment rescheduled successfully!');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to reschedule appointment');
    },
  });
};
