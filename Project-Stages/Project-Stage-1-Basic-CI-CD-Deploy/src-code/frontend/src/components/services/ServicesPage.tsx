import React from 'react';
import { 
  Heart, 
  Brain, 
  Eye, 
  Stethoscope, 
  Activity, 
  Shield, 
  Users, 
  Clock, 
  Award,
  Phone,
  MapPin,
  Mail
} from 'lucide-react';

interface Service {
  id: string;
  title: string;
  description: string;
  icon: React.ReactNode;
  features: string[];
}

const services: Service[] = [
  {
    id: 'cardiology',
    title: 'Cardiology',
    description: 'Comprehensive heart care services including diagnosis, treatment, and prevention of cardiovascular diseases.',
    icon: <Heart className="h-8 w-8 text-red-500" />,
    features: [
      'ECG and Echocardiogram',
      'Cardiac Catheterization',
      'Heart Surgery',
      'Preventive Cardiology',
      'Arrhythmia Management'
    ]
  },
  {
    id: 'neurology',
    title: 'Neurology',
    description: 'Expert neurological care for brain, spine, and nervous system disorders.',
    icon: <Brain className="h-8 w-8 text-purple-500" />,
    features: [
      'Brain MRI and CT Scans',
      'Stroke Treatment',
      'Epilepsy Management',
      'Parkinson\'s Disease Care',
      'Memory Disorders'
    ]
  },
  {
    id: 'ophthalmology',
    title: 'Ophthalmology',
    description: 'Complete eye care services from routine exams to advanced surgical procedures.',
    icon: <Eye className="h-8 w-8 text-blue-500" />,
    features: [
      'Comprehensive Eye Exams',
      'Cataract Surgery',
      'Glaucoma Treatment',
      'Retinal Care',
      'LASIK Surgery'
    ]
  },
  {
    id: 'pulmonology',
    title: 'Pulmonology',
    description: 'Specialized care for lung and respiratory system conditions.',
    icon: <Activity className="h-8 w-8 text-green-500" />,
    features: [
      'Pulmonary Function Tests',
      'Asthma Management',
      'COPD Treatment',
      'Sleep Apnea Studies',
      'Lung Cancer Screening'
    ]
  },
  {
    id: 'orthopedics',
    title: 'Orthopedics',
    description: 'Comprehensive bone, joint, and musculoskeletal system care.',
    icon: <Shield className="h-8 w-8 text-orange-500" />,
    features: [
      'Joint Replacement Surgery',
      'Sports Medicine',
      'Fracture Treatment',
      'Arthritis Management',
      'Physical Therapy'
    ]
  },
  {
    id: 'nephrology',
    title: 'Nephrology',
    description: 'Expert kidney care and treatment of kidney-related disorders.',
    icon: <Stethoscope className="h-8 w-8 text-teal-500" />,
    features: [
      'Kidney Function Tests',
      'Dialysis Services',
      'Kidney Transplant',
      'Hypertension Management',
      'Chronic Kidney Disease Care'
    ]
  }
];

export const ServicesPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 text-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h1 className="text-4xl font-bold mb-4">Our Healthcare Services</h1>
            <p className="text-xl text-blue-100 max-w-3xl mx-auto">
              Comprehensive medical care with state-of-the-art facilities and experienced healthcare professionals
            </p>
          </div>
        </div>
      </div>

      {/* Services Grid */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {services.map((service) => (
            <div
              key={service.id}
              className="bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 p-6"
            >
              <div className="flex items-center mb-4">
                {service.icon}
                <h3 className="text-xl font-semibold text-gray-900 ml-3">
                  {service.title}
                </h3>
              </div>
              <p className="text-gray-600 mb-4">
                {service.description}
              </p>
              <div className="space-y-2">
                <h4 className="font-medium text-gray-900">Key Services:</h4>
                <ul className="space-y-1">
                  {service.features.map((feature, index) => (
                    <li key={index} className="text-sm text-gray-600 flex items-center">
                      <div className="w-1.5 h-1.5 bg-blue-500 rounded-full mr-2"></div>
                      {feature}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Why Choose Us Section */}
      <div className="bg-white py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Why Choose Our Healthcare Services?</h2>
            <p className="text-lg text-gray-600 max-w-3xl mx-auto">
              We are committed to providing exceptional healthcare with a patient-centered approach
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-blue-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <Users className="h-8 w-8 text-blue-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Expert Medical Team</h3>
              <p className="text-gray-600">
                Board-certified physicians and specialists with years of experience in their respective fields
              </p>
            </div>
            
            <div className="text-center">
              <div className="bg-green-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <Clock className="h-8 w-8 text-green-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">24/7 Emergency Care</h3>
              <p className="text-gray-600">
                Round-the-clock emergency services with immediate response and critical care capabilities
              </p>
            </div>
            
            <div className="text-center">
              <div className="bg-purple-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
                <Award className="h-8 w-8 text-purple-600" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">Advanced Technology</h3>
              <p className="text-gray-600">
                State-of-the-art medical equipment and cutting-edge treatment technologies
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Contact Section */}
      <div className="bg-gray-100 py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Get in Touch</h2>
            <p className="text-lg text-gray-600">
              Ready to schedule an appointment or have questions about our services?
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="bg-blue-600 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-4">
                <Phone className="h-6 w-6 text-white" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Call Us</h3>
              <p className="text-gray-600">+1 (555) 123-4567</p>
              <p className="text-sm text-gray-500">24/7 Emergency Hotline</p>
            </div>
            
            <div className="text-center">
              <div className="bg-blue-600 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-4">
                <Mail className="h-6 w-6 text-white" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Email Us</h3>
              <p className="text-gray-600">info@routeclouds-health.com</p>
              <p className="text-sm text-gray-500">We'll respond within 24 hours</p>
            </div>
            
            <div className="text-center">
              <div className="bg-blue-600 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-4">
                <MapPin className="h-6 w-6 text-white" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 mb-2">Visit Us</h3>
              <p className="text-gray-600">123 Healthcare Ave</p>
              <p className="text-sm text-gray-500">Medical District, City 12345</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
