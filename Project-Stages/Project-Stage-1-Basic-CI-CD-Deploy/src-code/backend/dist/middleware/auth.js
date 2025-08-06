"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateToken = void 0;
const tokenService_1 = require("../services/tokenService");
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access token required',
        });
    }
    try {
        const decoded = (0, tokenService_1.verifyToken)(token);
        req.user = decoded;
        next();
    }
    catch (error) {
        return res.status(403).json({
            success: false,
            message: 'Invalid or expired token',
        });
    }
};
exports.authenticateToken = authenticateToken;
//# sourceMappingURL=auth.js.map