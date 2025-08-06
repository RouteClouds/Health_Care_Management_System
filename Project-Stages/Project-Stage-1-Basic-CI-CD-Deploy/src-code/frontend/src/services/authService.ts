import { apiClient } from './api';
import { AuthResponse, LoginRequest, RegisterRequest, User } from '../types/auth';

export const authService = {
  // User registration
  async register(data: RegisterRequest): Promise<AuthResponse> {
    return apiClient.post('/auth/register', data);
  },

  // User login
  async login(data: LoginRequest): Promise<AuthResponse> {
    return apiClient.post('/auth/login', data);
  },

  // Get user profile
  async getProfile(): Promise<{ success: boolean; data: User }> {
    return apiClient.get('/auth/profile');
  },

  // User logout
  async logout(): Promise<{ success: boolean; message: string }> {
    return apiClient.post('/auth/logout');
  },

  // Token management
  setToken(token: string): void {
    localStorage.setItem('routeclouds_token', token);
  },

  getToken(): string | null {
    return localStorage.getItem('routeclouds_token');
  },

  removeToken(): void {
    localStorage.removeItem('routeclouds_token');
  },

  // Check if user is authenticated
  isAuthenticated(): boolean {
    const token = this.getToken();
    if (!token) return false;
    
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload.exp > Date.now() / 1000;
    } catch {
      return false;
    }
  },
};
