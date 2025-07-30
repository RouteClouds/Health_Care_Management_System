import React from 'react';
import { Doctor } from '../../services/doctorService';
import { User, MapPin, Clock, DollarSign, Award, Calendar } from 'lucide-react';

interface DoctorCardProps {
  doctor: Doctor;
  onClick?: () => void;
  onBookAppointment?: (doctor: Doctor) => void;
}

export const DoctorCard: React.FC<DoctorCardProps> = ({ doctor, onClick, onBookAppointment }) => {
  return (
    <div 
      className="bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300 p-6 cursor-pointer border border-gray-200"
      onClick={onClick}
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
        <MapPin className="w-4 h-4 text-gray-500 mr-2" />
        <span className="text-gray-700">
          {doctor.department.name} ({doctor.department.code})
        </span>
      </div>

      {/* Experience */}
      {doctor.experienceYears && (
        <div className="flex items-center mb-3">
          <Clock className="w-4 h-4 text-gray-500 mr-2" />
          <span className="text-gray-700">
            {doctor.experienceYears} years of experience
          </span>
        </div>
      )}

      {/* Consultation Fee */}
      {doctor.consultationFee && (
        <div className="flex items-center mb-3">
          <DollarSign className="w-4 h-4 text-gray-500 mr-2" />
          <span className="text-gray-700">
            ${doctor.consultationFee} consultation fee
          </span>
        </div>
      )}

      {/* Qualifications */}
      {doctor.qualifications && doctor.qualifications.length > 0 && (
        <div className="mb-4">
          <div className="flex items-center mb-2">
            <Award className="w-4 h-4 text-gray-500 mr-2" />
            <span className="text-sm font-medium text-gray-700">Qualifications:</span>
          </div>
          <div className="flex flex-wrap gap-1">
            {doctor.qualifications.map((qualification, index) => (
              <span
                key={index}
                className="inline-block bg-gray-100 text-gray-700 text-xs px-2 py-1 rounded-full"
              >
                {qualification}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* Action Buttons */}
      <div className="mt-4 pt-4 border-t border-gray-200">
        <div className="flex space-x-2">
          <button
            onClick={(e) => {
              e.stopPropagation();
              onClick?.();
            }}
            className="flex-1 bg-gray-100 text-gray-700 py-2 px-4 rounded-md hover:bg-gray-200 transition-colors duration-200 font-medium"
          >
            View Profile
          </button>
          {onBookAppointment && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                onBookAppointment(doctor);
              }}
              className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition-colors duration-200 font-medium flex items-center justify-center"
            >
              <Calendar className="w-4 h-4 mr-1" />
              Book
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
