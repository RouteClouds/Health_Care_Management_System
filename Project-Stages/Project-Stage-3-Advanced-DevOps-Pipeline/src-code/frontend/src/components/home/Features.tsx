import React from 'react';
import { Stethoscope, Calendar, Clock, Video, FileText, Shield } from 'lucide-react';

const features = [
  {
    icon: <Stethoscope className="h-6 w-6" />,
    title: 'Expert Doctors',
    description: 'Access to board-certified physicians across all specialties'
  },
  {
    icon: <Calendar className="h-6 w-6" />,
    title: 'Easy Scheduling',
    description: 'Book appointments online 24/7 with real-time availability'
  },
  {
    icon: <Clock className="h-6 w-6" />,
    title: 'Urgent Care',
    description: '24/7 emergency services with minimal waiting time'
  },
  {
    icon: <Video className="h-6 w-6" />,
    title: 'Telemedicine',
    description: 'Virtual consultations from the comfort of your home'
  },
  {
    icon: <FileText className="h-6 w-6" />,
    title: 'Digital Records',
    description: 'Secure access to your complete medical history'
  },
  {
    icon: <Shield className="h-6 w-6" />,
    title: 'Safe & Secure',
    description: 'HIPAA-compliant platform ensuring your privacy'
  }
];

const Features: React.FC = () => {
  return (
    <div className="py-24 bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <h2 className="text-3xl font-extrabold text-gray-900 sm:text-4xl">
            Why Choose RouteClouds Health
          </h2>
          <p className="mt-4 text-xl text-gray-600">
            Comprehensive healthcare solutions designed around you
          </p>
        </div>

        <div className="mt-20 grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => (
            <div
              key={index}
              className="relative bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
            >
              <div className="absolute top-6 left-6 bg-blue-100 rounded-lg p-3">
                <div className="text-blue-600">{feature.icon}</div>
              </div>
              <div className="ml-16">
                <h3 className="text-xl font-medium text-gray-900">{feature.title}</h3>
                <p className="mt-2 text-gray-500">{feature.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Features;