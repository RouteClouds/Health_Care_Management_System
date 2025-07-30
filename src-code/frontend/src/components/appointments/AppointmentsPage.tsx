import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import { Calendar, Plus, ArrowLeft } from 'lucide-react';
import { AppointmentList } from './AppointmentList';
import { AppointmentBookingForm } from './AppointmentBookingForm';
import type { Doctor } from '../../services/doctorService';

interface AppointmentsPageProps {
  selectedDoctor?: Doctor;
}

export const AppointmentsPage: React.FC<AppointmentsPageProps> = ({ selectedDoctor: propSelectedDoctor }) => {
  const location = useLocation();
  const [selectedDoctor, setSelectedDoctor] = useState<Doctor | undefined>(propSelectedDoctor);

  useEffect(() => {
    // Check if doctor was passed via navigation state
    if (location.state?.selectedDoctor) {
      setSelectedDoctor(location.state.selectedDoctor);
    }
  }, [location.state]);
  const [currentView, setCurrentView] = useState<'list' | 'book'>(
    selectedDoctor ? 'book' : 'list'
  );

  const handleBookNew = () => {
    setCurrentView('book');
  };

  // If a doctor was selected, start with booking view
  useEffect(() => {
    if (selectedDoctor) {
      setCurrentView('book');
    }
  }, [selectedDoctor]);

  const handleBookingSuccess = () => {
    setCurrentView('list');
  };

  const handleBookingCancel = () => {
    setCurrentView('list');
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {currentView === 'list' ? (
          <AppointmentList onBookNew={handleBookNew} />
        ) : (
          <div>
            {/* Back Button */}
            <div className="mb-6">
              <button
                onClick={() => setCurrentView('list')}
                className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
              >
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back to Appointments
              </button>
            </div>

            <AppointmentBookingForm
              selectedDoctor={selectedDoctor}
              onSuccess={handleBookingSuccess}
              onCancel={handleBookingCancel}
            />
          </div>
        )}
      </div>
    </div>
  );
};
