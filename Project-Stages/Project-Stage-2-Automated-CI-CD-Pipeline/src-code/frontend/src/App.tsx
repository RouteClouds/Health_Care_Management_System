import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Provider, useDispatch } from 'react-redux';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { Toaster } from 'react-hot-toast';
import { store } from './store';
import { setCredentials } from './store/slices/authSlice';
import { authService } from './services/authService';
import Header from './components/layout/Header';
import Hero from './components/home/Hero';
import Features from './components/home/Features';
import Footer from './components/layout/Footer';
import { DoctorList } from './components/doctors/DoctorList';
import { SimpleDoctorList } from './components/doctors/SimpleDoctorList';
import { LoginForm } from './components/auth/LoginForm';
import { RegisterForm } from './components/auth/RegisterForm';
import { ProtectedRoute } from './components/auth/ProtectedRoute';
import { ServicesPage } from './components/services/ServicesPage';
import { TestAppointmentsPage } from './components/appointments/TestAppointmentsPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
    },
  },
});

// Auth initialization component
const AuthInitializer: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const dispatch = useDispatch();

  useEffect(() => {
    // Initialize auth state from localStorage on app startup
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
  }, [dispatch]);

  return <>{children}</>;
};

function App() {
  return (
    <Provider store={store}>
      <QueryClientProvider client={queryClient}>
        <AuthInitializer>
          <Router>
            <Routes>
              {/* Public routes */}
              <Route path="/login" element={<LoginForm />} />
              <Route path="/register" element={<RegisterForm />} />

              {/* Doctors page - accessible to all users */}
              <Route path="/doctors" element={
                <div className="min-h-screen flex flex-col">
                  <Header />
                  <main className="flex-grow">
                    <DoctorList />
                  </main>
                  <Footer />
                </div>
              } />

              {/* Services page */}
              <Route path="/services" element={
                <div className="min-h-screen flex flex-col">
                  <Header />
                  <main className="flex-grow">
                    <ServicesPage />
                  </main>
                  <Footer />
                </div>
              } />

              {/* Appointments page - protected route */}
              <Route path="/appointments" element={
                <ProtectedRoute>
                  <div className="min-h-screen flex flex-col">
                    <Header />
                    <main className="flex-grow">
                      <TestAppointmentsPage />
                    </main>
                    <Footer />
                  </div>
                </ProtectedRoute>
              } />

              {/* Home page with Hero and Features */}
              <Route path="/home" element={
                <div className="min-h-screen flex flex-col">
                  <Header />
                  <main className="flex-grow">
                    <Hero />
                    <Features />
                  </main>
                  <Footer />
                </div>
              } />

              {/* Default redirect */}
              <Route path="/" element={<Navigate to="/home" replace />} />
            </Routes>

            {/* Toast notifications */}
            <Toaster
              position="top-right"
              toastOptions={{
                duration: 4000,
                style: {
                  background: '#363636',
                  color: '#fff',
                },
                success: {
                  duration: 3000,
                  iconTheme: {
                    primary: '#4ade80',
                    secondary: '#fff',
                  },
                },
                error: {
                  duration: 5000,
                  iconTheme: {
                    primary: '#ef4444',
                    secondary: '#fff',
                  },
                },
              }}
            />
          </Router>
        </AuthInitializer>

        {/* React Query Devtools */}
        <ReactQueryDevtools initialIsOpen={false} />
      </QueryClientProvider>
    </Provider>
  );
}

export default App;
