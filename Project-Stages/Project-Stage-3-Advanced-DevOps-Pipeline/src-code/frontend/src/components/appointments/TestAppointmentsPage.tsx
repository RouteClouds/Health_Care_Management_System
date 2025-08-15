import React, { useState } from 'react';
import { Calendar, ArrowLeft } from 'lucide-react';
import { WorkingAppointmentList } from './WorkingAppointmentList';

export const TestAppointmentsPage: React.FC = () => {
  const [currentView, setCurrentView] = useState<'list' | 'book'>('list');

  const handleBookNew = () => {
    setCurrentView('book');
  };

  const handleBackToList = () => {
    setCurrentView('list');
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {currentView === 'list' ? (
          <WorkingAppointmentList onBookNew={handleBookNew} />
        ) : (
          <div className="text-center">
            <div className="mb-6">
              <button
                onClick={handleBackToList}
                className="flex items-center text-gray-600 hover:text-gray-900 transition-colors mx-auto"
              >
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back to Appointments
              </button>
            </div>
            
            <Calendar className="w-16 h-16 text-blue-600 mx-auto mb-4" />
            <h1 className="text-3xl font-bold text-gray-900 mb-4">Book New Appointment</h1>
            <p className="text-gray-600 mb-8">Appointment booking form will be here</p>
            
            <div className="bg-white rounded-lg shadow-lg p-8 max-w-md mx-auto">
              <h2 className="text-xl font-semibold text-gray-900 mb-4">Booking Form</h2>
              <p className="text-gray-600 mb-6">
                The appointment booking form is ready to be implemented here.
              </p>
              
              <button 
                onClick={handleBackToList}
                className="w-full bg-gray-100 text-gray-700 py-3 px-6 rounded-lg hover:bg-gray-200 transition-colors"
              >
                Back to Appointments List
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
