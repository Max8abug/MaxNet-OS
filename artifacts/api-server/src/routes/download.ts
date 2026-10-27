import {
  Router,
  type IRouter,
  type NextFunction,
  type Request,
  type Response,
} from "express";
import { createReadStream } from "node:fs";
import { readFile, stat } from "node:fs/promises";
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
const downloaderScriptPath = resolve(
  workspaceRoot,
  "artifacts",
  "api-server",
  "src",
  "routes",
  "download-maxos.ps1",
);
const chunkSize = 256 * 1024 * 1024;
const minimumIsoSize = 2_500_000_000;

const getIsoStat = async (res: Response) => {
  try {
    const iso = await stat(isoPath);
    if (!iso.isFile() || iso.size < minimumIsoSize) {
      res.status(503).json({ error: "The MaxOS ISO is not ready to download." });
      return null;
    }
    return iso;
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      res.status(503).json({ error: "The MaxOS ISO has not been built yet." });
      return null;
    }
    throw error;
  }
};

const ensureDevelopmentDownload = (res: Response) => {
  if (process.env.NODE_ENV !== "development") {
    res.sendStatus(404);
    return false;
  }
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("X-Content-Type-Options", "nosniff");
  return true;
};

const downloadIso = async (_req: Request, res: Response, next: NextFunction) => {
  if (!ensureDevelopmentDownload(res)) {
    return;
  }

  try {
    const iso = await getIsoStat(res);
    if (!iso) {
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

const downloadIsoChunk = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (!ensureDevelopmentDownload(res)) {
    return;
  }

  const partNumber = Number(req.params.part);
  if (!Number.isInteger(partNumber) || partNumber < 1) {
    res.status(400).json({ error: "Invalid MaxOS ISO chunk number." });
    return;
  }

  try {
    const iso = await getIsoStat(res);
    if (!iso) {
      return;
    }

    const totalParts = Math.ceil(iso.size / chunkSize);
    if (partNumber > totalParts) {
      res.status(404).json({ error: "MaxOS ISO chunk not found." });
      return;
    }

    const start = (partNumber - 1) * chunkSize;
    const end = Math.min(start + chunkSize - 1, iso.size - 1);
    const length = end - start + 1;
    const partName = `${isoDownloadName}.part${String(partNumber).padStart(2, "0")}`;

    res.status(206);
    res.setHeader("Accept-Ranges", "bytes");
    res.setHeader("Content-Range", `bytes ${start}-${end}/${iso.size}`);
    res.setHeader("Content-Length", String(length));
    res.setHeader("Content-Type", "application/octet-stream");
    res.setHeader("Content-Disposition", `attachment; filename="${partName}"`);

    if (req.method === "HEAD") {
      res.end();
      return;
    }

    const stream = createReadStream(isoPath, { start, end });
    stream.on("error", (error) => {
      if (res.headersSent) {
        res.destroy(error);
      } else {
        next(error);
      }
    });
    stream.pipe(res);
  } catch (error) {
    next(error);
  }
};

const downloadPowerShellHelper = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (!ensureDevelopmentDownload(res)) {
    return;
  }

  try {
    const forwardedProto = req.get("x-forwarded-proto")?.split(",")[0]?.trim();
    const origin = `${forwardedProto || req.protocol}://${req.get("host")}`;
    const template = await readFile(downloaderScriptPath, "utf8");
    const script = template.replaceAll("__MAXOS_DOWNLOAD_ORIGIN__", origin);

    res.type("text/plain");
    res.attachment("download-maxos.ps1");
    res.send(script);
  } catch (error) {
    next(error);
  }
};

router.get("/download/maxnet-os.iso", downloadIso);
router.get(`/download/${isoDownloadName}`, downloadIso);
router.get("/download/maxnet-os.part/:part", downloadIsoChunk);
router.get("/download/download-maxos.ps1", downloadPowerShellHelper);

export default router;
