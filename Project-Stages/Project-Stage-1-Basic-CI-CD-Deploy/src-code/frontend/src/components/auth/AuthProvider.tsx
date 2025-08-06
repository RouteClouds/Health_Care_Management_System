import React, { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { setCredentials } from '../../store/slices/authSlice';
import { authService } from '../../services/authService';

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const dispatch = useDispatch();

  useEffect(() => {
    // Initialize auth state from localStorage on app startup
    const initializeAuth = () => {
      const token = authService.getToken();
      
      if (token && authService.isAuthenticated()) {
        try {
          // Decode JWT token to get user info
          const payload = JSON.parse(atob(token.split('.')[1]));
          const user = {
            id: payload.userId,
            username: payload.username,
            email: payload.email,
            firstName: payload.firstName || '',
            lastName: payload.lastName || '',
            role: payload.role,
            createdAt: new Date().toISOString()
          };
          
          dispatch(setCredentials({ user, token }));
        } catch (error) {
          console.error('Error initializing auth:', error);
          authService.removeToken();
        }
      }
    };

    initializeAuth();
  }, [dispatch]);

  return <>{children}</>;
};
