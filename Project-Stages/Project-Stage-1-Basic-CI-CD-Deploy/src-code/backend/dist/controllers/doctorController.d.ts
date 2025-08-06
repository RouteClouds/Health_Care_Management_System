import { Request, Response } from 'express';
export declare const doctorController: {
    getAllDoctors(req: Request, res: Response): Promise<void>;
    getDoctorById(req: Request, res: Response): Promise<Response<any, Record<string, any>> | undefined>;
    getAllDepartments(req: Request, res: Response): Promise<void>;
    getDoctorsByDepartment(req: Request, res: Response): Promise<void>;
    getApiStats(req: Request, res: Response): Promise<void>;
};
//# sourceMappingURL=doctorController.d.ts.map