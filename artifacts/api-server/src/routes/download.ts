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
const isoFileName = "maxos-0.4.10-cinnamon-64bit.iso";
const isoDownloadName = "MaxOS-0.4.10-cinnamon-64bit.iso";
const isoPath = resolve(
  workspaceRoot,
  "generated-artifacts",
  "maxnet-remaster",
  isoFileName,
);
const checksumPath = `${isoPath}.sha256`;
const downloaderScriptPath = resolve(
  workspaceRoot,
  "artifacts",
  "api-server",
  "src",
  "routes",
  "download-maxos.ps1",
);
const shellDownloaderScriptPath = resolve(
  workspaceRoot,
  "artifacts",
  "api-server",
  "src",
  "routes",
  "download-maxos.sh",
);
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

const streamIso = (
  req: Request,
  res: Response,
  next: NextFunction,
  start: number,
  end: number,
) => {
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
  res.on("close", () => {
    if (!res.writableEnded) {
      stream.destroy();
    }
  });
  stream.pipe(res);
};

const downloadIso = async (req: Request, res: Response, next: NextFunction) => {
  if (!ensureDevelopmentDownload(res)) {
    return;
  }

  try {
    const iso = await getIsoStat(res);
    if (!iso) {
      return;
    }

    res.setHeader("Accept-Ranges", "bytes");
    res.setHeader("Content-Type", "application/octet-stream");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="${isoDownloadName}"`,
    );

    const rangeHeader = req.get("range");
    if (!rangeHeader) {
      res.status(200);
      res.setHeader("Content-Length", String(iso.size));
      streamIso(req, res, next, 0, iso.size - 1);
      return;
    }

    const match = /^bytes=(\d*)-(\d*)$/.exec(rangeHeader.trim());
    if (!match || (!match[1] && !match[2])) {
      res.setHeader("Content-Range", `bytes */${iso.size}`);
      res.status(416).end();
      return;
    }

    let start: number;
    let end: number;
    if (!match[1]) {
      const suffixLength = Number(match[2]);
      if (!Number.isSafeInteger(suffixLength) || suffixLength <= 0) {
        res.setHeader("Content-Range", `bytes */${iso.size}`);
        res.status(416).end();
        return;
      }
      start = Math.max(iso.size - suffixLength, 0);
      end = iso.size - 1;
    } else {
      start = Number(match[1]);
      end = match[2] ? Number(match[2]) : iso.size - 1;
    }

    if (
      !Number.isSafeInteger(start) ||
      !Number.isSafeInteger(end) ||
      start < 0 ||
      end < start ||
      start >= iso.size
    ) {
      res.setHeader("Content-Range", `bytes */${iso.size}`);
      res.status(416).end();
      return;
    }

    end = Math.min(end, iso.size - 1);
    const length = end - start + 1;
    res.status(206);
    res.setHeader("Content-Range", `bytes ${start}-${end}/${iso.size}`);
    res.setHeader("Content-Length", String(length));
    streamIso(req, res, next, start, end);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      res.status(503).json({ error: "The MaxOS ISO has not been built yet." });
      return;
    }
    next(error);
  }
};

const downloadIsoChecksum = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (!ensureDevelopmentDownload(res)) {
    return;
  }

  try {
    const iso = await getIsoStat(res);
    if (!iso) {
      return;
    }
    const checksumText = await readFile(checksumPath, "utf8");
    const checksum = checksumText.trim().split(/\s+/)[0];
    if (!/^[a-f0-9]{64}$/i.test(checksum ?? "")) {
      res.status(503).json({ error: "The MaxOS ISO checksum is not ready." });
      return;
    }

    res.type("text/plain").send(`${checksum}  ${isoDownloadName}\n`);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      res.status(503).json({ error: "The MaxOS ISO checksum is not ready." });
      return;
    }
    next(error);
  }
};

const downloadHelperScript = async (
  req: Request,
  res: Response,
  next: NextFunction,
  scriptPath: string,
  filename: string,
) => {
  if (!ensureDevelopmentDownload(res)) {
    return;
  }

  try {
    const forwardedProto = req.get("x-forwarded-proto")?.split(",")[0]?.trim();
    const origin = `${forwardedProto || req.protocol}://${req.get("host")}`;
    const template = await readFile(scriptPath, "utf8");
    const script = template.replaceAll("__MAXOS_DOWNLOAD_ORIGIN__", origin);

    res.type("text/plain");
    res.attachment(filename);
    res.send(script);
  } catch (error) {
    next(error);
  }
};

const downloadPowerShellHelper = (req: Request, res: Response, next: NextFunction) =>
  downloadHelperScript(req, res, next, downloaderScriptPath, "download-maxos.ps1");

const downloadShellHelper = (req: Request, res: Response, next: NextFunction) =>
  downloadHelperScript(req, res, next, shellDownloaderScriptPath, "download-maxos.sh");

router.get("/download/maxnet-os.iso", downloadIso);
router.get(`/download/${isoFileName}`, downloadIso);
router.get("/download/maxnet-os.iso.sha256", downloadIsoChecksum);
router.get("/download/download-maxos.ps1", downloadPowerShellHelper);
router.get("/download/download-maxos.sh", downloadShellHelper);

export default router;
