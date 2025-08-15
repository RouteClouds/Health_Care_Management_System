import React from 'react';
import { Department } from '../../services/doctorService';
import { Filter } from 'lucide-react';

interface DepartmentFilterProps {
  departments: Department[];
  selectedDepartment: string;
  onChange: (departmentCode: string) => void;
  isLoading?: boolean;
}

export const DepartmentFilter: React.FC<DepartmentFilterProps> = ({
  departments,
  selectedDepartment,
  onChange,
  isLoading = false,
}) => {
  return (
    <div className="relative">
      <div className="flex items-center">
        <Filter className="w-4 h-4 text-gray-500 mr-2" />
        <label htmlFor="department-filter" className="text-sm font-medium text-gray-700 mr-3">
          Filter by Department:
        </label>
      </div>
      
      <select
        id="department-filter"
        value={selectedDepartment}
        onChange={(e) => onChange(e.target.value)}
        disabled={isLoading}
        className="mt-2 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm disabled:bg-gray-100 disabled:cursor-not-allowed"
      >
        <option value="">All Departments</option>
        {departments.map((department) => (
          <option key={department.id} value={department.code}>
            {department.name} ({department.doctorCount} doctor{department.doctorCount !== 1 ? 's' : ''})
          </option>
        ))}
      </select>
      
      {isLoading && (
        <div className="absolute right-3 top-9">
          <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600"></div>
        </div>
      )}
    </div>
  );
};
