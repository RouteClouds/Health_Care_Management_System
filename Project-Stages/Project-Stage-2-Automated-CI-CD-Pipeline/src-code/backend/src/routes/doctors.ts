import { Router } from 'express';
import { doctorController } from '../controllers/doctorController';

const router = Router();

// Doctor routes
router.get('/', doctorController.getAllDoctors);
router.get('/stats', doctorController.getApiStats);
router.get('/department/:departmentCode', doctorController.getDoctorsByDepartment);
router.get('/:id', doctorController.getDoctorById);

// Department routes (nested under doctors for API organization)
router.get('/departments/all', doctorController.getAllDepartments);

export default router;
