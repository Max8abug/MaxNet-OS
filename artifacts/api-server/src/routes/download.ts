import {
  Router,
  type IRouter,
  type NextFunction,
  type Request,
  type Response,
} from "express";
import { resolve } from "node:path";

const router: IRouter = Router();

const workspaceRoot = resolve(
  process.cwd(),
  "../../",
);
const isoDownloadName = "maxos-0.4.2-cinnamon-64bit.iso";
const isoPath = resolve(
  workspaceRoot,
  "generated-artifacts",
  "maxnet-remaster",
  isoDownloadName,
);

const downloadIso = (_req: Request, res: Response, next: NextFunction) => {
  if (process.env.NODE_ENV !== "development") {
    res.sendStatus(404);
    return;
  }

  res.setHeader("Cache-Control", "no-store");
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.download(isoPath, isoDownloadName, (error) => {
    if (error && !res.headersSent) {
      next(error);
    }
  });
};

router.get("/download/maxnet-os.iso", downloadIso);
router.get(`/download/${isoDownloadName}`, downloadIso);

export default router;
