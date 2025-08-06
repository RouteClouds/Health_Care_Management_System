import { Router } from 'express';
import { authController } from '../controllers/authController';
import { validateRequest } from '../middleware/validation';
import { authenticateToken } from '../middleware/auth';
import { registerSchema, loginSchema } from '../utils/validators';

const router = Router();

// Public routes
router.post('/register', validateRequest(registerSchema), authController.register);
router.post('/login', validateRequest(loginSchema), authController.login);
router.post('/logout', authController.logout);

// Protected routes
router.get('/profile', authenticateToken, authController.getProfile);

export default router;
