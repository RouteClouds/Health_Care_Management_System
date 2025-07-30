import React from 'react';
import { Link } from 'react-router-dom';
import { Heart, Search, Menu, LogOut, User } from 'lucide-react';
import { useAuth } from '../../hooks/useAuth';

const Header: React.FC = () => {
  const { isAuthenticated, user, logout } = useAuth();

  return (
    <header className="bg-white shadow-md">
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex">
            <Link to="/" className="flex items-center">
              <Heart className="h-8 w-8 text-blue-600" />
              <span className="ml-2 text-xl font-bold text-gray-900">
                RouteClouds Health
              </span>
            </Link>
          </div>

          <div className="hidden sm:ml-6 sm:flex sm:items-center space-x-8">
            <Link
              to="/home"
              className="text-gray-700 hover:text-blue-600 px-3 py-2 transition-colors duration-200"
            >
              Home
            </Link>
            <Link
              to="/doctors"
              className="text-gray-700 hover:text-blue-600 px-3 py-2 transition-colors duration-200"
            >
              Find a Doctor
            </Link>
            <Link
              to="/services"
              className="text-gray-700 hover:text-blue-600 px-3 py-2 transition-colors duration-200"
            >
              Our Services
            </Link>
            {isAuthenticated && (
              <Link
                to="/appointments"
                className="text-gray-700 hover:text-blue-600 px-3 py-2 transition-colors duration-200"
              >
                My Appointments
              </Link>
            )}
            {isAuthenticated ? (
              <>
                <div className="flex items-center space-x-4">
                  <div
                    className="flex items-center space-x-2 cursor-pointer group"
                    title={`${user?.firstName} ${user?.lastName} (${user?.email})`}
                  >
                    <User className="h-4 w-4 text-blue-600 group-hover:text-blue-700" />
                    <span className="text-sm text-gray-700 group-hover:text-blue-600 font-medium">
                      Welcome, {user?.firstName} {user?.lastName}!
                    </span>
                  </div>
                  <button
                    onClick={logout}
                    className="flex items-center space-x-1 text-gray-700 hover:text-red-600 px-3 py-2 transition-colors duration-200"
                  >
                    <LogOut className="h-4 w-4" />
                    <span>Logout</span>
                  </button>
                </div>
              </>
            ) : (
              <div className="flex items-center space-x-4">
                <Link
                  to="/login"
                  className="text-gray-700 hover:text-blue-600 px-3 py-2 transition-colors duration-200"
                >
                  Sign In
                </Link>
                <Link
                  to="/register"
                  className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition-colors duration-200"
                >
                  Sign Up
                </Link>
              </div>
            )}
          </div>

          <div className="flex items-center sm:hidden">
            <button className="p-2 rounded-md text-gray-700 hover:text-blue-600">
              <Menu className="h-6 w-6" />
            </button>
          </div>
        </div>
      </nav>
    </header>
  );
};

export default Header;