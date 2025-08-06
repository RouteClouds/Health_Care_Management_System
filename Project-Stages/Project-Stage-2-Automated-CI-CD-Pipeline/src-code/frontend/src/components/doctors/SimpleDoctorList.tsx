import React, { useEffect, useState } from 'react';
import { User, MapPin, Clock, DollarSign } from 'lucide-react';

interface Doctor {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  specialization: string;
  experienceYears?: number;
  consultationFee?: number;
  department: {
    name: string;
    code: string;
  };
}

export const SimpleDoctorList: React.FC = () => {
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDoctors = async () => {
      try {
        setLoading(true);
        const response = await fetch('http://localhost:3001/api/doctors?page=1&limit=12');
        const data = await response.json();
        
        console.log('SimpleDoctorList API Response:', data);
        
        if (data.success) {
          setDoctors(data.data.doctors);
        } else {
          setError('Failed to fetch doctors');
        }
      } catch (err) {
        console.error('Error fetching doctors:', err);
        setError('Network error');
      } finally {
        setLoading(false);
      }
    };

    fetchDoctors();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading doctors...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <p className="text-red-600">Error: {error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Find a Doctor</h1>
          <p className="text-gray-600">
            Browse our experienced healthcare professionals ({doctors.length} doctors available)
          </p>
        </div>

        {/* Doctors Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {doctors.map((doctor) => (
            <div
              key={doctor.id}
              className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300 p-6 border border-gray-200"
            >
              {/* Doctor Header */}
              <div className="flex items-center mb-4">
                <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                  <User className="w-8 h-8 text-blue-600" />
                </div>
                <div>
                  <h3 className="text-xl font-semibold text-gray-900">
                    Dr. {doctor.firstName} {doctor.lastName}
                  </h3>
                  <p className="text-blue-600 font-medium">{doctor.specialization}</p>
                </div>
              </div>

              {/* Department */}
              <div className="flex items-center mb-3">
                <MapPin className="w-4 h-4 text-gray-400 mr-2" />
                <span className="text-sm text-gray-600">
                  {doctor.department.name} ({doctor.department.code})
                </span>
              </div>

              {/* Experience */}
              {doctor.experienceYears && (
                <div className="flex items-center mb-3">
                  <Clock className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-sm text-gray-600">
                    {doctor.experienceYears} years experience
                  </span>
                </div>
              )}

              {/* Consultation Fee */}
              {doctor.consultationFee && (
                <div className="flex items-center mb-4">
                  <DollarSign className="w-4 h-4 text-gray-400 mr-2" />
                  <span className="text-sm text-gray-600">
                    ${doctor.consultationFee} consultation fee
                  </span>
                </div>
              )}

              {/* Contact Button */}
              <button className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors duration-200">
                Book Appointment
              </button>
            </div>
          ))}
        </div>

        {doctors.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500 text-lg">No doctors found.</p>
          </div>
        )}
      </div>
    </div>
  );
};
