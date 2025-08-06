"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const authController_1 = require("../controllers/authController");
const validation_1 = require("../middleware/validation");
const auth_1 = require("../middleware/auth");
const validators_1 = require("../utils/validators");
const router = (0, express_1.Router)();
// Public routes
router.post('/register', (0, validation_1.validateRequest)(validators_1.registerSchema), authController_1.authController.register);
router.post('/login', (0, validation_1.validateRequest)(validators_1.loginSchema), authController_1.authController.login);
router.post('/logout', authController_1.authController.logout);
// Protected routes
router.get('/profile', auth_1.authenticateToken, authController_1.authController.getProfile);
exports.default = router;
//# sourceMappingURL=auth.js.map