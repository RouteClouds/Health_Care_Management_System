import React from 'react';
import { Link } from 'react-router-dom';
import { Search } from 'lucide-react';

const Hero: React.FC = () => {
  return (
    <div className="relative bg-gradient-to-r from-blue-600 to-blue-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
        <div className="text-center">
          <h1 className="text-4xl tracking-tight font-extrabold text-white sm:text-5xl md:text-6xl">
            <span className="block">Transforming Healthcare</span>
            <span className="block text-blue-200">For a Better Tomorrow</span>
          </h1>
          <p className="mt-3 max-w-md mx-auto text-base text-blue-100 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl">
            Advanced medical care with a human touch. Find the right doctor,
            schedule appointments, and manage your health journey all in one place.
          </p>
          
          <div className="mt-10 max-w-xl mx-auto">
            <div className="relative">
              <input
                type="text"
                className="w-full px-5 py-3 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-300"
                placeholder="Search for conditions, doctors, or services..."
              />
              <button className="absolute right-2 top-1/2 transform -translate-y-1/2 p-2 bg-blue-600 rounded-full text-white hover:bg-blue-700">
                <Search className="h-5 w-5" />
              </button>
            </div>
          </div>

          <div className="mt-10">
            <Link
              to="/doctors"
              className="inline-block bg-white text-blue-600 px-8 py-3 rounded-full font-medium hover:bg-blue-50 transition-colors"
            >
              Find a Doctor
            </Link>
            <Link
              to="/services"
              className="inline-block ml-4 text-white border-2 border-white px-8 py-3 rounded-full font-medium hover:bg-white hover:text-blue-600 transition-colors"
            >
              Our Services
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Hero;