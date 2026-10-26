import { Router, type IRouter } from "express";
import downloadRouter from "./download";
import healthRouter from "./health";

const router: IRouter = Router();

router.use(downloadRouter);
router.use(healthRouter);

export default router;
