import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { hashPassword, comparePassword } from '../utils/passwordUtils';
import { generateToken } from '../services/tokenService';
import { AuthRequest } from '../middleware/auth';

const prisma = new PrismaClient();

export const authController = {
  // User registration
  async register(req: Request, res: Response) {
    try {
      const { username, email, password, firstName, lastName } = req.body;

      // Check if user already exists
      const existingUser = await prisma.user.findFirst({
        where: {
          OR: [
            { username },
            { email },
          ],
        },
      });

      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: existingUser.username === username 
            ? 'Username already exists' 
            : 'Email already exists',
        });
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Create user
      const user = await prisma.user.create({
        data: {
          username,
          email,
          password: hashedPassword,
          firstName,
          lastName,
        },
        select: {
          id: true,
          username: true,
          email: true,
          firstName: true,
          lastName: true,
          role: true,
          createdAt: true,
        },
      });

      // Generate token
      const token = generateToken({
        userId: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
      });

      res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: {
          user,
          token,
        },
      });
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error during registration',
      });
    }
  },

  // User login
  async login(req: Request, res: Response) {
    try {
      const { username, password } = req.body;

      // Find user by username
      const user = await prisma.user.findUnique({
        where: { username },
      });

      if (!user || !user.isActive) {
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password',
        });
      }

      // Verify password
      const isPasswordValid = await comparePassword(password, user.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Invalid username or password',
        });
      }

      // Generate token
      const token = generateToken({
        userId: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
      });

      res.json({
        success: true,
        message: 'Login successful',
        data: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            role: user.role,
          },
          token,
        },
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error during login',
      });
    }
  },

  // Get user profile
  async getProfile(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.userId;

      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          username: true,
          email: true,
          firstName: true,
          lastName: true,
          role: true,
          createdAt: true,
        },
      });

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      res.json({
        success: true,
        data: user,
      });
    } catch (error) {
      console.error('Profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error',
      });
    }
  },

  // User logout
  async logout(req: Request, res: Response) {
    // In a stateless JWT system, logout is handled on the client side
    // by removing the token from storage
    res.json({
      success: true,
      message: 'Logout successful',
    });
  },
};
