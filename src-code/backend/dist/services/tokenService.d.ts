export interface TokenPayload {
    userId: string;
    username: string;
    email: string;
    role: string;
}
export declare const generateToken: (payload: TokenPayload) => string;
export declare const verifyToken: (token: string) => TokenPayload;
//# sourceMappingURL=tokenService.d.ts.map