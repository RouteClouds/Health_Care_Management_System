"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.loginSchema = exports.registerSchema = void 0;
const joi_1 = __importDefault(require("joi"));
exports.registerSchema = joi_1.default.object({
    username: joi_1.default.string()
        .alphanum()
        .min(3)
        .max(20)
        .required()
        .messages({
        'string.alphanum': 'Username must contain only alphanumeric characters',
        'string.min': 'Username must be at least 3 characters long',
        'string.max': 'Username must not exceed 20 characters',
    }),
    email: joi_1.default.string()
        .email()
        .required()
        .messages({
        'string.email': 'Please provide a valid email address',
    }),
    password: joi_1.default.string()
        .min(5)
        .pattern(/^[a-zA-Z0-9]+$/)
        .required()
        .messages({
        'string.min': 'Password must be at least 5 characters long',
        'string.pattern.base': 'Password must contain only alphanumeric characters',
    }),
    firstName: joi_1.default.string()
        .min(2)
        .max(50)
        .required()
        .messages({
        'string.min': 'First name must be at least 2 characters long',
    }),
    lastName: joi_1.default.string()
        .min(2)
        .max(50)
        .required()
        .messages({
        'string.min': 'Last name must be at least 2 characters long',
    }),
});
exports.loginSchema = joi_1.default.object({
    username: joi_1.default.string().required(),
    password: joi_1.default.string().required(),
});
//# sourceMappingURL=validators.js.map