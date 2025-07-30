import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const doctorController = {
  // Get all doctors with pagination and filtering
  async getAllDoctors(req: Request, res: Response) {
    try {
      const { department, search, page = 1, limit = 10 } = req.query;
      
      const skip = (Number(page) - 1) * Number(limit);
      
      const where: any = {};
      
      // Filter by department code
      if (department) {
        where.department = {
          code: department as string,
        };
      }
      
      // Search by name or specialization
      if (search) {
        where.OR = [
          { firstName: { contains: search as string, mode: 'insensitive' } },
          { lastName: { contains: search as string, mode: 'insensitive' } },
          { specialization: { contains: search as string, mode: 'insensitive' } },
        ];
      }

      const [doctors, total] = await Promise.all([
        prisma.doctor.findMany({
          where,
          include: {
            department: true,
          },
          skip,
          take: Number(limit),
          orderBy: {
            lastName: 'asc',
          },
        }),
        prisma.doctor.count({ where }),
      ]);

      res.json({
        success: true,
        data: {
          doctors,
          pagination: {
            page: Number(page),
            limit: Number(limit),
            total,
            totalPages: Math.ceil(total / Number(limit)),
          },
        },
        message: `Found ${doctors.length} doctors`,
      });
    } catch (error) {
      console.error('Error fetching doctors:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch doctors',
        error: process.env.NODE_ENV === 'development' ? error : undefined,
      });
    }
  },

  // Get doctor by ID
  async getDoctorById(req: Request, res: Response) {
    try {
      const { id } = req.params;
      
      const doctor = await prisma.doctor.findUnique({
        where: { id },
        include: {
          department: true,
        },
      });

      if (!doctor) {
        return res.status(404).json({
          success: false,
          message: 'Doctor not found',
        });
      }

      res.json({
        success: true,
        data: doctor,
        message: `Doctor ${doctor.firstName} ${doctor.lastName} found`,
      });
    } catch (error) {
      console.error('Error fetching doctor:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch doctor',
        error: process.env.NODE_ENV === 'development' ? error : undefined,
      });
    }
  },

  // Get all departments with doctor count
  async getAllDepartments(req: Request, res: Response) {
    try {
      const departments = await prisma.department.findMany({
        include: {
          _count: {
            select: { doctors: true },
          },
        },
        orderBy: {
          name: 'asc',
        },
      });

      const departmentsWithCount = departments.map(dept => ({
        id: dept.id,
        name: dept.name,
        code: dept.code,
        description: dept.description,
        doctorCount: dept._count.doctors,
        createdAt: dept.createdAt,
      }));

      res.json({
        success: true,
        data: departmentsWithCount,
        message: `Found ${departments.length} departments`,
      });
    } catch (error) {
      console.error('Error fetching departments:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch departments',
        error: process.env.NODE_ENV === 'development' ? error : undefined,
      });
    }
  },

  // Get doctors by department code
  async getDoctorsByDepartment(req: Request, res: Response) {
    try {
      const { departmentCode } = req.params;
      
      const doctors = await prisma.doctor.findMany({
        where: {
          department: {
            code: departmentCode.toUpperCase(),
          },
        },
        include: {
          department: true,
        },
        orderBy: {
          lastName: 'asc',
        },
      });

      res.json({
        success: true,
        data: {
          doctors,
          total: doctors.length,
          department: doctors.length > 0 ? doctors[0].department : null,
        },
        message: `Found ${doctors.length} doctors in ${departmentCode.toUpperCase()} department`,
      });
    } catch (error) {
      console.error('Error fetching doctors by department:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch doctors by department',
        error: process.env.NODE_ENV === 'development' ? error : undefined,
      });
    }
  },

  // Get API statistics
  async getApiStats(req: Request, res: Response) {
    try {
      const [totalDoctors, totalDepartments, departmentStats] = await Promise.all([
        prisma.doctor.count(),
        prisma.department.count(),
        prisma.department.findMany({
          include: {
            _count: {
              select: { doctors: true },
            },
          },
        }),
      ]);

      const stats = {
        totalDoctors,
        totalDepartments,
        departmentBreakdown: departmentStats.map(dept => ({
          department: dept.name,
          code: dept.code,
          doctorCount: dept._count.doctors,
        })),
        lastUpdated: new Date().toISOString(),
      };

      res.json({
        success: true,
        data: stats,
        message: 'API statistics retrieved successfully',
      });
    } catch (error) {
      console.error('Error fetching API stats:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch API statistics',
        error: process.env.NODE_ENV === 'development' ? error : undefined,
      });
    }
  },
};
