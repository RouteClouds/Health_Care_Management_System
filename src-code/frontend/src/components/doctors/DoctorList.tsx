import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDoctors, useDepartments } from '../../hooks/useDoctors';
import { DoctorCard } from './DoctorCard';
import { DepartmentFilter } from './DepartmentFilter';
import { SearchBar } from './SearchBar';
import { LoadingSpinner } from '../common/LoadingSpinner';
import { ErrorMessage } from '../common/ErrorMessage';
import { Users, Activity } from 'lucide-react';
import type { Doctor } from '../../services/doctorService';

export const DoctorList: React.FC = () => {
  const navigate = useNavigate();
  const [filters, setFilters] = useState({
    page: 1,
    limit: 12,
    department: '',
    search: '',
  });

  const {
    data: doctorsData,
    isLoading: doctorsLoading,
    error: doctorsError,
    refetch: refetchDoctors
  } = useDoctors(filters);

  const {
    data: departmentsData,
    isLoading: departmentsLoading
  } = useDepartments();

  const handleFilterChange = (newFilters: Partial<typeof filters>) => {
    setFilters(prev => ({ ...prev, ...newFilters, page: 1 }));
  };

  const handleDoctorClick = (doctorId: string) => {
    // TODO: Navigate to doctor detail page
    console.log('Navigate to doctor:', doctorId);
  };

  const handleBookAppointment = (doctor: Doctor) => {
    // Navigate to appointments page with selected doctor
    navigate('/appointments', { state: { selectedDoctor: doctor } });
  };

  if (doctorsLoading && !doctorsData) {
    return <LoadingSpinner size="lg" message="Loading doctors..." />;
  }

  if (doctorsError) {
    return (
      <ErrorMessage
        message="Failed to load doctors. Please check if the backend server is running."
        onRetry={refetchDoctors}
      />
    );
  }

  const doctors = doctorsData?.data.doctors || [];
  const departments = departmentsData?.data || [];
  const pagination = doctorsData?.data.pagination;

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center mb-4">
            <Users className="h-8 w-8 text-blue-600 mr-3" />
            <h1 className="text-3xl font-bold text-gray-900">Find a Doctor</h1>
          </div>
          <p className="text-gray-600">
            Browse our network of qualified healthcare professionals across different specialties.
          </p>
        </div>

        {/* Stats */}
        {pagination && (
          <div className="bg-white rounded-lg shadow p-6 mb-8">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <Activity className="h-5 w-5 text-blue-600 mr-2" />
                <span className="text-sm text-gray-600">
                  Showing {doctors.length} of {pagination.total} doctors
                </span>
              </div>
              <div className="text-sm text-gray-500">
                {departments.length} departments available
              </div>
            </div>
          </div>
        )}

        {/* Filters */}
        <div className="bg-white rounded-lg shadow p-6 mb-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <SearchBar
              value={filters.search}
              onChange={(search) => handleFilterChange({ search })}
              placeholder="Search doctors by name or specialization..."
            />
            
            <DepartmentFilter
              departments={departments}
              selectedDepartment={filters.department}
              onChange={(department) => handleFilterChange({ department })}
              isLoading={departmentsLoading}
            />
          </div>
        </div>

        {/* Doctor Grid */}
        {doctors.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-8">
            {doctors.map((doctor) => (
              <DoctorCard
                key={doctor.id}
                doctor={doctor}
                onClick={() => handleDoctorClick(doctor.id)}
                onBookAppointment={handleBookAppointment}
              />
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow p-12 text-center">
            <Users className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No doctors found</h3>
            <p className="text-gray-600">
              {filters.search || filters.department
                ? 'Try adjusting your search criteria or filters.'
                : 'No doctors are currently available.'}
            </p>
          </div>
        )}

        {/* Pagination */}
        {pagination && pagination.totalPages > 1 && (
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <div className="text-sm text-gray-700">
                Page {pagination.page} of {pagination.totalPages}
              </div>
              <div className="flex space-x-2">
                <button
                  onClick={() => handleFilterChange({ page: pagination.page - 1 })}
                  disabled={pagination.page <= 1}
                  className="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                <button
                  onClick={() => handleFilterChange({ page: pagination.page + 1 })}
                  disabled={pagination.page >= pagination.totalPages}
                  className="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
