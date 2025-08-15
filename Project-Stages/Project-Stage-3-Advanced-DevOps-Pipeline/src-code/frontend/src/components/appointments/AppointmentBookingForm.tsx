import React, { useState, useEffect } from 'react';
import { Calendar, Clock, User, Video, MapPin, FileText, CheckCircle } from 'lucide-react';
import { useCreateAppointment, useAvailableTimeSlots } from '../../hooks/useAppointments';
import { useDoctors } from '../../hooks/useDoctors';
import { LoadingSpinner } from '../common/LoadingSpinner';
import type { Doctor } from '../../services/doctorService';

interface AppointmentBookingFormProps {
  selectedDoctor?: Doctor;
  onSuccess?: () => void;
  onCancel?: () => void;
}

export const AppointmentBookingForm: React.FC<AppointmentBookingFormProps> = ({
  selectedDoctor,
  onSuccess,
  onCancel,
}) => {
  const [formData, setFormData] = useState({
    doctorId: selectedDoctor?.id || '',
    date: '',
    time: '',
    type: 'IN_PERSON' as 'IN_PERSON' | 'TELEMEDICINE',
    notes: '',
  });

  const [step, setStep] = useState(1);
  const [selectedDate, setSelectedDate] = useState('');

  const { data: doctorsData, isLoading: doctorsLoading } = useDoctors({ limit: 50 });
  const { data: timeSlotsData, isLoading: timeSlotsLoading } = useAvailableTimeSlots(
    formData.doctorId,
    selectedDate
  );
  const createAppointmentMutation = useCreateAppointment();

  const doctors = doctorsData?.data.doctors || [];
  const timeSlots = timeSlotsData?.data || generateDefaultTimeSlots();

  // Generate next 30 days for date selection (excluding weekends)
  const generateAvailableDates = () => {
    const dates = [];
    const today = new Date();

    for (let i = 1; i <= 30; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);

      // Skip weekends (can be customized based on doctor availability)
      if (date.getDay() !== 0 && date.getDay() !== 6) {
        dates.push({
          value: date.toISOString().split('T')[0],
          label: date.toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
          }),
        });
      }
    }

    return dates;
  };

  // Generate default time slots (9 AM to 5 PM, excluding lunch 12-1 PM)
  const generateDefaultTimeSlots = () => {
    const slots = [];
    const times = [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'
    ];

    return times.map(time => ({
      time,
      available: true,
      doctorId: formData.doctorId
    }));
  };

  const availableDates = generateAvailableDates();

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    
    if (field === 'date') {
      setSelectedDate(value);
      setFormData(prev => ({ ...prev, time: '' })); // Reset time when date changes
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.doctorId || !formData.date || !formData.time) {
      return;
    }

    const dateTime = `${formData.date}T${formData.time}:00`;
    
    try {
      await createAppointmentMutation.mutateAsync({
        doctorId: formData.doctorId,
        dateTime,
        type: formData.type,
        notes: formData.notes,
      });
      
      onSuccess?.();
    } catch (error) {
      // Error is handled by the mutation hook
    }
  };

  const selectedDoctorData = doctors.find(d => d.id === formData.doctorId) || selectedDoctor;

  const renderStepIndicator = () => (
    <div className="flex items-center justify-center mb-8">
      {[1, 2, 3].map((stepNumber) => (
        <div key={stepNumber} className="flex items-center">
          <div
            className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium ${
              step >= stepNumber
                ? 'bg-blue-600 text-white'
                : 'bg-gray-200 text-gray-600'
            }`}
          >
            {step > stepNumber ? <CheckCircle className="w-4 h-4" /> : stepNumber}
          </div>
          {stepNumber < 3 && (
            <div
              className={`w-16 h-1 mx-2 ${
                step > stepNumber ? 'bg-blue-600' : 'bg-gray-200'
              }`}
            />
          )}
        </div>
      ))}
    </div>
  );

  const renderStep1 = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
          <User className="w-5 h-5 mr-2 text-blue-600" />
          Select Doctor
        </h3>
        
        {selectedDoctor ? (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                <User className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <h4 className="font-semibold text-gray-900">
                  Dr. {selectedDoctor.firstName} {selectedDoctor.lastName}
                </h4>
                <p className="text-sm text-gray-600">{selectedDoctor.specialization}</p>
                <p className="text-sm text-gray-600">{selectedDoctor.department.name}</p>
              </div>
            </div>
          </div>
        ) : (
          <div>
            {doctorsLoading ? (
              <LoadingSpinner size="sm" message="Loading doctors..." />
            ) : (
              <select
                value={formData.doctorId}
                onChange={(e) => handleInputChange('doctorId', e.target.value)}
                className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                required
              >
                <option value="">Select a doctor</option>
                {doctors.map((doctor) => (
                  <option key={doctor.id} value={doctor.id}>
                    Dr. {doctor.firstName} {doctor.lastName} - {doctor.specialization}
                  </option>
                ))}
              </select>
            )}
          </div>
        )}
      </div>

      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
          <Video className="w-5 h-5 mr-2 text-blue-600" />
          Appointment Type
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label className="flex items-center p-4 border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50">
            <input
              type="radio"
              name="type"
              value="IN_PERSON"
              checked={formData.type === 'IN_PERSON'}
              onChange={(e) => handleInputChange('type', e.target.value)}
              className="mr-3"
            />
            <MapPin className="w-5 h-5 mr-2 text-gray-600" />
            <div>
              <div className="font-medium">In-Person</div>
              <div className="text-sm text-gray-600">Visit the clinic</div>
            </div>
          </label>
          
          <label className="flex items-center p-4 border border-gray-300 rounded-lg cursor-pointer hover:bg-gray-50">
            <input
              type="radio"
              name="type"
              value="TELEMEDICINE"
              checked={formData.type === 'TELEMEDICINE'}
              onChange={(e) => handleInputChange('type', e.target.value)}
              className="mr-3"
            />
            <Video className="w-5 h-5 mr-2 text-gray-600" />
            <div>
              <div className="font-medium">Telemedicine</div>
              <div className="text-sm text-gray-600">Video consultation</div>
            </div>
          </label>
        </div>
      </div>
    </div>
  );

  const renderStep2 = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
          <Calendar className="w-5 h-5 mr-2 text-blue-600" />
          Select Date
        </h3>
        <select
          value={formData.date}
          onChange={(e) => handleInputChange('date', e.target.value)}
          className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          required
        >
          <option value="">Select a date</option>
          {availableDates.map((date) => (
            <option key={date.value} value={date.value}>
              {date.label}
            </option>
          ))}
        </select>
      </div>

      {formData.date && (
        <div>
          <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <Clock className="w-5 h-5 mr-2 text-blue-600" />
            Select Time
          </h3>
          
          {timeSlotsLoading ? (
            <LoadingSpinner size="sm" message="Loading available times..." />
          ) : (
            <div className="grid grid-cols-3 md:grid-cols-4 gap-3">
              {timeSlots.length > 0 ? (
                timeSlots
                  .filter(slot => slot.available)
                  .map((slot) => (
                    <button
                      key={slot.time}
                      type="button"
                      onClick={() => handleInputChange('time', slot.time)}
                      className={`p-3 text-sm font-medium rounded-lg border transition-colors ${
                        formData.time === slot.time
                          ? 'bg-blue-600 text-white border-blue-600'
                          : 'bg-white text-gray-700 border-gray-300 hover:bg-blue-50 hover:border-blue-300'
                      }`}
                    >
                      {slot.time}
                    </button>
                  ))
              ) : (
                <div className="col-span-full text-center py-8 text-gray-500">
                  No available time slots for this date
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );

  const renderStep3 = () => (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
          <FileText className="w-5 h-5 mr-2 text-blue-600" />
          Additional Notes (Optional)
        </h3>
        <textarea
          value={formData.notes}
          onChange={(e) => handleInputChange('notes', e.target.value)}
          placeholder="Please describe your symptoms or reason for the appointment..."
          rows={4}
          className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        />
      </div>

      {/* Appointment Summary */}
      <div className="bg-gray-50 rounded-lg p-6">
        <h4 className="font-semibold text-gray-900 mb-4">Appointment Summary</h4>
        <div className="space-y-3">
          <div className="flex justify-between">
            <span className="text-gray-600">Doctor:</span>
            <span className="font-medium">
              Dr. {selectedDoctorData?.firstName} {selectedDoctorData?.lastName}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Specialization:</span>
            <span className="font-medium">{selectedDoctorData?.specialization}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Date:</span>
            <span className="font-medium">
              {formData.date && new Date(formData.date).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric',
              })}
            </span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Time:</span>
            <span className="font-medium">{formData.time}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Type:</span>
            <span className="font-medium capitalize">{formData.type}</span>
          </div>
          {selectedDoctorData?.consultationFee && (
            <div className="flex justify-between border-t pt-3">
              <span className="text-gray-600">Consultation Fee:</span>
              <span className="font-semibold text-green-600">
                ${selectedDoctorData.consultationFee}
              </span>
            </div>
          )}
        </div>
      </div>
    </div>
  );

  const canProceedToNextStep = () => {
    switch (step) {
      case 1:
        return formData.doctorId && formData.type;
      case 2:
        return formData.date && formData.time;
      case 3:
        return true;
      default:
        return false;
    }
  };

  return (
    <div className="max-w-2xl mx-auto bg-white rounded-lg shadow-lg p-6">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 text-center">Book Appointment</h2>
        <p className="text-gray-600 text-center mt-2">Schedule your consultation with our healthcare professionals</p>
      </div>

      {renderStepIndicator()}

      <form onSubmit={handleSubmit}>
        {step === 1 && renderStep1()}
        {step === 2 && renderStep2()}
        {step === 3 && renderStep3()}

        <div className="flex justify-between mt-8">
          <div>
            {step > 1 && (
              <button
                type="button"
                onClick={() => setStep(step - 1)}
                className="px-6 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Previous
              </button>
            )}
          </div>

          <div className="flex space-x-3">
            {onCancel && (
              <button
                type="button"
                onClick={onCancel}
                className="px-6 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                Cancel
              </button>
            )}
            
            {step < 3 ? (
              <button
                type="button"
                onClick={() => setStep(step + 1)}
                disabled={!canProceedToNextStep()}
                className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
              >
                Next
              </button>
            ) : (
              <button
                type="submit"
                disabled={createAppointmentMutation.isPending || !canProceedToNextStep()}
                className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center"
              >
                {createAppointmentMutation.isPending ? (
                  <>
                    <LoadingSpinner size="sm" />
                    <span className="ml-2">Booking...</span>
                  </>
                ) : (
                  'Book Appointment'
                )}
              </button>
            )}
          </div>
        </div>
      </form>
    </div>
  );
};
