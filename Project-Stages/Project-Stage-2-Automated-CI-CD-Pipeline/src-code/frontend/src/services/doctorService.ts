import { apiClient } from './api';

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

export interface Department {
  id: string;
  name: string;
  code: string;
  description?: string;
  doctorCount?: number;
  createdAt: string;
}

export interface Doctor {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  specialization: string;
  departmentId: string;
  qualifications: string[];
  experienceYears?: number;
  consultationFee?: number;
  createdAt: string;
  updatedAt: string;
  department: Department;
}

export interface DoctorResponse {
  doctors: Doctor[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface DoctorParams {
  page?: number;
  limit?: number;
  department?: string;
  search?: string;
}

export const doctorService = {
  // Get all doctors with pagination and filtering
  async getDoctors(params?: DoctorParams): Promise<ApiResponse<DoctorResponse>> {
    return apiClient.get('/doctors', { params });
  },

  // Get doctor by ID
  async getDoctorById(id: string): Promise<ApiResponse<Doctor>> {
    return apiClient.get(`/doctors/${id}`);
  },

  // Get doctors by department code
  async getDoctorsByDepartment(departmentCode: string): Promise<ApiResponse<{ doctors: Doctor[]; total: number; department: Department | null }>> {
    return apiClient.get(`/doctors/department/${departmentCode}`);
  },

  // Search doctors
  async searchDoctors(query: string, params?: Omit<DoctorParams, 'search'>): Promise<ApiResponse<DoctorResponse>> {
    return apiClient.get('/doctors', { params: { ...params, search: query } });
  },

  // Get all departments
  async getDepartments(): Promise<ApiResponse<Department[]>> {
    return apiClient.get('/doctors/departments/all');
  },

  // Get API statistics
  async getApiStats(): Promise<ApiResponse<any>> {
    return apiClient.get('/doctors/stats');
  },

  // Health check
  async healthCheck(): Promise<any> {
    return apiClient.get('/../health');
  },
};
