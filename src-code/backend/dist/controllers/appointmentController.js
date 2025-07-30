"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAvailableTimeSlots = exports.cancelAppointment = exports.updateAppointment = exports.createAppointment = exports.getAppointments = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
// Get all appointments for the authenticated user
const getAppointments = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { status, page = 1, limit = 10 } = req.query;
        const skip = (Number(page) - 1) * Number(limit);
        const where = {
            patientId: userId,
        };
        if (status && status !== 'all') {
            where.status = status;
        }
        const [appointments, total] = await Promise.all([
            prisma.appointment.findMany({
                where,
                include: {
                    doctor: {
                        include: {
                            department: true,
                        },
                    },
                },
                orderBy: {
                    dateTime: 'desc',
                },
                skip,
                take: Number(limit),
            }),
            prisma.appointment.count({ where }),
        ]);
        res.json({
            success: true,
            data: {
                appointments,
                pagination: {
                    page: Number(page),
                    limit: Number(limit),
                    total,
                    pages: Math.ceil(total / Number(limit)),
                },
            },
        });
    }
    catch (error) {
        console.error('Error fetching appointments:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch appointments',
        });
    }
};
exports.getAppointments = getAppointments;
// Create a new appointment
const createAppointment = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { doctorId, dateTime, type, notes } = req.body;
        // Validate required fields
        if (!doctorId || !dateTime) {
            return res.status(400).json({
                success: false,
                message: 'Doctor ID and date/time are required',
            });
        }
        // Check if doctor exists
        const doctor = await prisma.doctor.findUnique({
            where: { id: doctorId },
        });
        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: 'Doctor not found',
            });
        }
        // Check if the time slot is available
        const appointmentDate = new Date(dateTime);
        const existingAppointment = await prisma.appointment.findFirst({
            where: {
                doctorId,
                dateTime: appointmentDate,
                status: {
                    not: 'CANCELLED',
                },
            },
        });
        if (existingAppointment) {
            return res.status(409).json({
                success: false,
                message: 'This time slot is already booked',
            });
        }
        // Create the appointment
        const appointment = await prisma.appointment.create({
            data: {
                patientId: userId,
                doctorId,
                dateTime: appointmentDate,
                type: type || 'IN_PERSON',
                notes,
                status: 'SCHEDULED',
            },
            include: {
                doctor: {
                    include: {
                        department: true,
                    },
                },
            },
        });
        res.status(201).json({
            success: true,
            message: 'Appointment created successfully',
            data: appointment,
        });
    }
    catch (error) {
        console.error('Error creating appointment:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create appointment',
        });
    }
};
exports.createAppointment = createAppointment;
// Update an appointment
const updateAppointment = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { id } = req.params;
        const { dateTime, type, notes, status } = req.body;
        // Check if appointment exists and belongs to the user
        const existingAppointment = await prisma.appointment.findFirst({
            where: {
                id,
                patientId: userId,
            },
        });
        if (!existingAppointment) {
            return res.status(404).json({
                success: false,
                message: 'Appointment not found',
            });
        }
        // If updating dateTime, check availability
        if (dateTime) {
            const appointmentDate = new Date(dateTime);
            const conflictingAppointment = await prisma.appointment.findFirst({
                where: {
                    doctorId: existingAppointment.doctorId,
                    dateTime: appointmentDate,
                    status: {
                        not: 'CANCELLED',
                    },
                    id: {
                        not: id,
                    },
                },
            });
            if (conflictingAppointment) {
                return res.status(409).json({
                    success: false,
                    message: 'This time slot is already booked',
                });
            }
        }
        const updatedAppointment = await prisma.appointment.update({
            where: { id },
            data: {
                ...(dateTime && { dateTime: new Date(dateTime) }),
                ...(type && { type }),
                ...(notes !== undefined && { notes }),
                ...(status && { status }),
            },
            include: {
                doctor: {
                    include: {
                        department: true,
                    },
                },
            },
        });
        res.json({
            success: true,
            message: 'Appointment updated successfully',
            data: updatedAppointment,
        });
    }
    catch (error) {
        console.error('Error updating appointment:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update appointment',
        });
    }
};
exports.updateAppointment = updateAppointment;
// Cancel an appointment
const cancelAppointment = async (req, res) => {
    try {
        const userId = req.user?.userId;
        const { id } = req.params;
        // Check if appointment exists and belongs to the user
        const existingAppointment = await prisma.appointment.findFirst({
            where: {
                id,
                patientId: userId,
            },
        });
        if (!existingAppointment) {
            return res.status(404).json({
                success: false,
                message: 'Appointment not found',
            });
        }
        if (existingAppointment.status === 'CANCELLED') {
            return res.status(400).json({
                success: false,
                message: 'Appointment is already cancelled',
            });
        }
        const cancelledAppointment = await prisma.appointment.update({
            where: { id },
            data: {
                status: 'CANCELLED',
            },
            include: {
                doctor: {
                    include: {
                        department: true,
                    },
                },
            },
        });
        res.json({
            success: true,
            message: 'Appointment cancelled successfully',
            data: cancelledAppointment,
        });
    }
    catch (error) {
        console.error('Error cancelling appointment:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to cancel appointment',
        });
    }
};
exports.cancelAppointment = cancelAppointment;
// Get available time slots for a doctor on a specific date
const getAvailableTimeSlots = async (req, res) => {
    try {
        const { doctorId, date } = req.params;
        if (!doctorId || !date) {
            return res.status(400).json({
                success: false,
                message: 'Doctor ID and date are required',
            });
        }
        // Check if doctor exists
        const doctor = await prisma.doctor.findUnique({
            where: { id: doctorId },
        });
        if (!doctor) {
            return res.status(404).json({
                success: false,
                message: 'Doctor not found',
            });
        }
        // Generate time slots (9 AM to 5 PM, excluding lunch 12-1 PM)
        const timeSlots = [
            '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
            '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'
        ];
        const requestedDate = new Date(date);
        const startOfDay = new Date(requestedDate);
        startOfDay.setHours(0, 0, 0, 0);
        const endOfDay = new Date(requestedDate);
        endOfDay.setHours(23, 59, 59, 999);
        // Get existing appointments for this doctor on this date
        const existingAppointments = await prisma.appointment.findMany({
            where: {
                doctorId,
                dateTime: {
                    gte: startOfDay,
                    lte: endOfDay,
                },
                status: {
                    not: 'CANCELLED',
                },
            },
        });
        // Create a set of booked times
        const bookedTimes = new Set(existingAppointments.map(apt => {
            const time = apt.dateTime.toTimeString().slice(0, 5);
            return time;
        }));
        // Generate available slots
        const availableSlots = timeSlots.map(time => ({
            time,
            available: !bookedTimes.has(time),
            doctorId,
        }));
        res.json({
            success: true,
            data: availableSlots,
        });
    }
    catch (error) {
        console.error('Error fetching available time slots:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch available time slots',
        });
    }
};
exports.getAvailableTimeSlots = getAvailableTimeSlots;
//# sourceMappingURL=appointmentController.js.map