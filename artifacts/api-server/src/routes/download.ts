import { Router, type IRouter } from "express";
import { resolve } from "node:path";

const router: IRouter = Router();

const isoPath = resolve(
  process.cwd(),
  "../../",
  "maxos-0.4.0-cinnamon-64bit.iso",
);
const isoDownloadName = "maxos-0.4.0-cinnamon-64bit.iso";

router.get("/download/maxnet-os.iso", (req, res, next) => {
  if (process.env.NODE_ENV !== "development") {
    res.sendStatus(404);
    return;
  }

  res.setHeader("Cache-Control", "no-store");
  res.download(isoPath, isoDownloadName, (error) => {
    if (error && !res.headersSent) {
      next(error);
    }
  });
});

export default router;
