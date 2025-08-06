"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const doctorController_1 = require("../controllers/doctorController");
const router = (0, express_1.Router)();
// Doctor routes
router.get('/', doctorController_1.doctorController.getAllDoctors);
router.get('/stats', doctorController_1.doctorController.getApiStats);
router.get('/department/:departmentCode', doctorController_1.doctorController.getDoctorsByDepartment);
router.get('/:id', doctorController_1.doctorController.getDoctorById);
// Department routes (nested under doctors for API organization)
router.get('/departments/all', doctorController_1.doctorController.getAllDepartments);
exports.default = router;
//# sourceMappingURL=doctors.js.map