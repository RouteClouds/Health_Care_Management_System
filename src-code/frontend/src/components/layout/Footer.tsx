import React from 'react';
import { Link } from 'react-router-dom';
import { Heart, Phone, Mail, MapPin } from 'lucide-react';

const Footer: React.FC = () => {
  return (
    <footer className="bg-gray-900 text-gray-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="col-span-1">
            <Link to="/" className="flex items-center">
              <Heart className="h-8 w-8 text-blue-500" />
              <span className="ml-2 text-xl font-bold text-white">
                RouteClouds Health
              </span>
            </Link>
            <p className="mt-4 text-sm">
              Transforming healthcare through innovation and compassionate care.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4">Quick Links</h3>
            <ul className="space-y-2">
              <li><Link to="/about" className="hover:text-blue-400">About Us</Link></li>
              <li><Link to="/services" className="hover:text-blue-400">Our Services</Link></li>
              <li><Link to="/doctors" className="hover:text-blue-400">Find a Doctor</Link></li>
              <li><Link to="/locations" className="hover:text-blue-400">Locations</Link></li>
            </ul>
          </div>

          {/* Services */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4">Services</h3>
            <ul className="space-y-2">
              <li><Link to="/emergency" className="hover:text-blue-400">Emergency Care</Link></li>
              <li><Link to="/telemedicine" className="hover:text-blue-400">Telemedicine</Link></li>
              <li><Link to="/lab-tests" className="hover:text-blue-400">Lab Tests</Link></li>
              <li><Link to="/pharmacy" className="hover:text-blue-400">Pharmacy</Link></li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4">Contact Us</h3>
            <ul className="space-y-4">
              <li className="flex items-center">
                <Phone className="h-5 w-5 mr-2 text-blue-500" />
                <span>1-800-HEALTH</span>
              </li>
              <li className="flex items-center">
                <Mail className="h-5 w-5 mr-2 text-blue-500" />
                <span>contact@routeclouds.health</span>
              </li>
              <li className="flex items-center">
                <MapPin className="h-5 w-5 mr-2 text-blue-500" />
                <span>123 Healthcare Ave, Medical City</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t border-gray-800">
          <div className="text-center text-sm">
            <p>&copy; {new Date().getFullYear()} RouteClouds Health. All rights reserved.</p>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;