import React, { useState } from 'react';
import { Calendar, Clock, User, Video, MapPin, MoreVertical, Edit, X, CheckCircle } from 'lucide-react';
import { usePatientAppointments, useCancelAppointment, useRescheduleAppointment } from '../../hooks/useAppointments';
import { LoadingSpinner } from '../common/LoadingSpinner';
import { ErrorMessage } from '../common/ErrorMessage';
import type { Appointment } from '../../types';

interface AppointmentListProps {
  onBookNew?: () => void;
}

export const AppointmentList: React.FC<AppointmentListProps> = ({ onBookNew }) => {
  const [selectedStatus, setSelectedStatus] = useState<string>('all');
  const [showActions, setShowActions] = useState<string | null>(null);

  const {
    data: appointmentsData,
    isLoading,
    error,
    refetch
  } = usePatientAppointments();

  const cancelAppointmentMutation = useCancelAppointment();
  const rescheduleAppointmentMutation = useRescheduleAppointment();

  const appointments = appointmentsData?.data.appointments || [];

  const filteredAppointments = appointments.filter(appointment => {
    if (selectedStatus === 'all') return true;
    return appointment.status === selectedStatus;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'scheduled':
        return 'bg-blue-100 text-blue-800';
      case 'completed':
        return 'bg-green-100 text-green-800';
      case 'cancelled':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'scheduled':
        return <Clock className="w-4 h-4" />;
      case 'completed':
        return <CheckCircle className="w-4 h-4" />;
      case 'cancelled':
        return <X className="w-4 h-4" />;
      default:
        return <Calendar className="w-4 h-4" />;
    }
  };

  const formatDateTime = (dateTime: string) => {
    const date = new Date(dateTime);
    return {
      date: date.toLocaleDateString('en-US', {
        weekday: 'short',
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      }),
      time: date.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
      }),
    };
  };

  const handleCancelAppointment = async (appointmentId: string) => {
    if (window.confirm('Are you sure you want to cancel this appointment?')) {
      try {
        await cancelAppointmentMutation.mutateAsync(appointmentId);
        setShowActions(null);
      } catch (error) {
        // Error handled by mutation hook
      }
    }
  };

  const isUpcoming = (dateTime: string) => {
    return new Date(dateTime) > new Date();
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center py-12">
        <LoadingSpinner size="lg" message="Loading your appointments..." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="py-12">
        <ErrorMessage
          message="Failed to load appointments. Please try again."
          onRetry={refetch}
        />
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">My Appointments</h2>
          <p className="text-gray-600 mt-1">Manage your healthcare appointments</p>
        </div>
        {onBookNew && (
          <button
            onClick={onBookNew}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center"
          >
            <Calendar className="w-4 h-4 mr-2" />
            Book New Appointment
          </button>
        )}
      </div>

      {/* Status Filter */}
      <div className="flex space-x-2 mb-6">
        {[
          { value: 'all', label: 'All' },
          { value: 'scheduled', label: 'Scheduled' },
          { value: 'completed', label: 'Completed' },
          { value: 'cancelled', label: 'Cancelled' },
        ].map((status) => (
          <button
            key={status.value}
            onClick={() => setSelectedStatus(status.value)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              selectedStatus === status.value
                ? 'bg-blue-600 text-white'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            {status.label}
          </button>
        ))}
      </div>

      {/* Appointments List */}
      {filteredAppointments.length === 0 ? (
        <div className="text-center py-12">
          <Calendar className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            {selectedStatus === 'all' ? 'No appointments found' : `No ${selectedStatus} appointments`}
          </h3>
          <p className="text-gray-600 mb-6">
            {selectedStatus === 'all' 
              ? "You haven't booked any appointments yet."
              : `You don't have any ${selectedStatus} appointments.`
            }
          </p>
          {onBookNew && selectedStatus === 'all' && (
            <button
              onClick={onBookNew}
              className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700"
            >
              Book Your First Appointment
            </button>
          )}
        </div>
      ) : (
        <div className="space-y-4">
          {filteredAppointments.map((appointment) => {
            const { date, time } = formatDateTime(appointment.dateTime);
            const upcoming = isUpcoming(appointment.dateTime);
            
            return (
              <div
                key={appointment.id}
                className="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow"
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center mb-3">
                      <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                        <User className="w-6 h-6 text-blue-600" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-gray-900">
                          Dr. {appointment.doctorId} {/* This should be populated from doctor data */}
                        </h3>
                        <p className="text-sm text-gray-600">Specialist</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                      <div className="flex items-center text-sm text-gray-600">
                        <Calendar className="w-4 h-4 mr-2" />
                        {date}
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Clock className="w-4 h-4 mr-2" />
                        {time}
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        {appointment.type === 'telemedicine' ? (
                          <Video className="w-4 h-4 mr-2" />
                        ) : (
                          <MapPin className="w-4 h-4 mr-2" />
                        )}
                        {appointment.type === 'telemedicine' ? 'Video Call' : 'In-Person'}
                      </div>
                    </div>

                    {appointment.notes && (
                      <div className="mb-4">
                        <p className="text-sm text-gray-600">
                          <span className="font-medium">Notes:</span> {appointment.notes}
                        </p>
                      </div>
                    )}

                    <div className="flex items-center">
                      <span
                        className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(
                          appointment.status
                        )}`}
                      >
                        {getStatusIcon(appointment.status)}
                        <span className="ml-1 capitalize">{appointment.status}</span>
                      </span>
                    </div>
                  </div>

                  {/* Actions Menu */}
                  {upcoming && appointment.status === 'scheduled' && (
                    <div className="relative">
                      <button
                        onClick={() => setShowActions(showActions === appointment.id ? null : appointment.id)}
                        className="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100"
                      >
                        <MoreVertical className="w-4 h-4" />
                      </button>

                      {showActions === appointment.id && (
                        <div className="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg border border-gray-200 z-10">
                          <div className="py-1">
                            <button
                              onClick={() => {
                                // TODO: Implement reschedule functionality
                                setShowActions(null);
                              }}
                              className="flex items-center w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                            >
                              <Edit className="w-4 h-4 mr-2" />
                              Reschedule
                            </button>
                            <button
                              onClick={() => handleCancelAppointment(appointment.id)}
                              className="flex items-center w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50"
                              disabled={cancelAppointmentMutation.isPending}
                            >
                              <X className="w-4 h-4 mr-2" />
                              {cancelAppointmentMutation.isPending ? 'Cancelling...' : 'Cancel'}
                            </button>
                          </div>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
