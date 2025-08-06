export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'patient' | 'doctor' | 'admin';
}

export interface Patient {
  id: string;
  userId: string;
  dateOfBirth: string;
  bloodType: string;
  medicalHistory: string[];
  emergencyContact: {
    name: string;
    phone: string;
    relationship: string;
  };
}

export interface Doctor {
  id: string;
  userId: string;
  specialization: string;
  department: string;
  qualifications: string[];
  availability: {
    days: string[];
    hours: string;
  };
}

export interface Appointment {
  id: string;
  patientId: string;
  doctorId: string;
  dateTime: string;
  status: 'scheduled' | 'completed' | 'cancelled';
  type: 'in-person' | 'telemedicine';
  notes?: string;
}