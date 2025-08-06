import { useQuery, useQueryClient } from '@tanstack/react-query';
import { doctorService, DoctorParams } from '../services/doctorService';
import toast from 'react-hot-toast';

// Query keys for React Query
export const doctorKeys = {
  all: ['doctors'] as const,
  lists: () => [...doctorKeys.all, 'list'] as const,
  list: (params?: DoctorParams) => [...doctorKeys.lists(), params] as const,
  details: () => [...doctorKeys.all, 'detail'] as const,
  detail: (id: string) => [...doctorKeys.details(), id] as const,
  departments: ['departments'] as const,
  stats: ['doctors', 'stats'] as const,
};

// Hook to get all doctors with pagination and filtering
export const useDoctors = (params?: DoctorParams) => {
  return useQuery({
    queryKey: doctorKeys.list(params),
    queryFn: () => doctorService.getDoctors(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
    retry: 2,
  });
};

// Hook to get a specific doctor by ID
export const useDoctor = (id: string) => {
  return useQuery({
    queryKey: doctorKeys.detail(id),
    queryFn: () => doctorService.getDoctorById(id),
    enabled: !!id,
    staleTime: 10 * 60 * 1000, // 10 minutes
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to fetch doctor details');
    },
  });
};

// Hook to get all departments
export const useDepartments = () => {
  return useQuery({
    queryKey: doctorKeys.departments,
    queryFn: () => doctorService.getDepartments(),
    staleTime: 30 * 60 * 1000, // 30 minutes
    gcTime: 60 * 60 * 1000, // 1 hour
  });
};

// Hook to get doctors by department
export const useDoctorsByDepartment = (departmentCode: string) => {
  return useQuery({
    queryKey: [...doctorKeys.all, 'department', departmentCode],
    queryFn: () => doctorService.getDoctorsByDepartment(departmentCode),
    enabled: !!departmentCode,
    staleTime: 5 * 60 * 1000, // 5 minutes
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to fetch doctors by department');
    },
  });
};

// Hook to search doctors
export const useSearchDoctors = (query: string, params?: Omit<DoctorParams, 'search'>) => {
  return useQuery({
    queryKey: [...doctorKeys.all, 'search', query, params],
    queryFn: () => doctorService.searchDoctors(query, params),
    enabled: !!query && query.length >= 2, // Only search if query is at least 2 characters
    staleTime: 2 * 60 * 1000, // 2 minutes
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to search doctors');
    },
  });
};

// Hook to get API statistics
export const useApiStats = () => {
  return useQuery({
    queryKey: doctorKeys.stats,
    queryFn: () => doctorService.getApiStats(),
    staleTime: 15 * 60 * 1000, // 15 minutes
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to fetch API statistics');
    },
  });
};

// Hook to check API health
export const useHealthCheck = () => {
  return useQuery({
    queryKey: ['health'],
    queryFn: () => doctorService.healthCheck(),
    staleTime: 1 * 60 * 1000, // 1 minute
    retry: 3,
    onError: (error: any) => {
      toast.error('Backend API is not responding');
    },
  });
};

// Custom hook to invalidate doctor queries
export const useInvalidateDoctors = () => {
  const queryClient = useQueryClient();
  
  return {
    invalidateAll: () => queryClient.invalidateQueries({ queryKey: doctorKeys.all }),
    invalidateLists: () => queryClient.invalidateQueries({ queryKey: doctorKeys.lists() }),
    invalidateDepartments: () => queryClient.invalidateQueries({ queryKey: doctorKeys.departments }),
    invalidateStats: () => queryClient.invalidateQueries({ queryKey: doctorKeys.stats }),
  };
};
