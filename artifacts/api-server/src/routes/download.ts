import {
  Router,
  type IRouter,
  type NextFunction,
  type Request,
  type Response,
} from "express";
import { stat } from "node:fs/promises";
import { resolve } from "node:path";

const router: IRouter = Router();

const workspaceRoot = resolve(
  process.cwd(),
  "../../",
);
const isoDownloadName = "maxos-0.4.6-cinnamon-64bit.iso";
const isoPath = resolve(
  workspaceRoot,
  "generated-artifacts",
  "maxnet-remaster",
  isoDownloadName,
);

const downloadIso = async (_req: Request, res: Response, next: NextFunction) => {
  if (process.env.NODE_ENV !== "development") {
    res.sendStatus(404);
    return;
  }

  res.setHeader("Cache-Control", "no-store");
  res.setHeader("X-Content-Type-Options", "nosniff");
  try {
    const iso = await stat(isoPath);
    if (!iso.isFile() || iso.size < 2_500_000_000) {
      res.status(503).json({ error: "The MaxOS ISO is not ready to download." });
      return;
    }

    res.setHeader("Content-Length", String(iso.size));
    res.setHeader("Content-Type", "application/octet-stream");
    res.download(isoPath, isoDownloadName, (error) => {
      if (error && !res.headersSent) {
        next(error);
      }
    });
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      res.status(503).json({ error: "The MaxOS ISO has not been built yet." });
      return;
    }
    next(error);
  }
};

router.get("/download/maxnet-os.iso", downloadIso);
router.get(`/download/${isoDownloadName}`, downloadIso);

export default router;
