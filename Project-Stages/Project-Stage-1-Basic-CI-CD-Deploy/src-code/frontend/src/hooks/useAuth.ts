import { useSelector, useDispatch } from 'react-redux';
import { useMutation, useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import { setCredentials, logout } from '../store/slices/authSlice';
import { RootState } from '../store';
import toast from 'react-hot-toast';

export const useAuth = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { user, token, isAuthenticated } = useSelector((state: RootState) => state.auth);

  // Login mutation
  const loginMutation = useMutation({
    mutationFn: authService.login,
    onSuccess: (data) => {
      const { user, token } = data.data;
      authService.setToken(token);
      dispatch(setCredentials({ user, token }));
      toast.success('Login successful!');
      // Force page reload to ensure state is updated
      setTimeout(() => {
        window.location.href = '/doctors';
      }, 1000);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Login failed');
    },
  });

  // Registration mutation
  const registerMutation = useMutation({
    mutationFn: authService.register,
    onSuccess: (data) => {
      const { user, token } = data.data;
      authService.setToken(token);
      dispatch(setCredentials({ user, token }));
      toast.success('Registration successful!');
      // Force page reload to ensure state is updated
      setTimeout(() => {
        window.location.href = '/doctors';
      }, 1000);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Registration failed');
    },
  });

  // Logout function
  const handleLogout = async () => {
    try {
      await authService.logout();
      authService.removeToken();
      dispatch(logout());
      toast.success('Logged out successfully');
      // Navigate to home page after logout
      navigate('/home');
    } catch (error) {
      // Even if API call fails, clear local state
      authService.removeToken();
      dispatch(logout());
      navigate('/home');
    }
  };

  return {
    user,
    token,
    isAuthenticated,
    login: loginMutation.mutate,
    register: registerMutation.mutate,
    logout: handleLogout,
    isLoggingIn: loginMutation.isPending,
    isRegistering: registerMutation.isPending,
  };
};
