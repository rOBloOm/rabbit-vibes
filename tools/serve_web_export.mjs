import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const host = process.env.HOST ?? "127.0.0.1";
const port = Number(process.env.PORT ?? 8000);
const root = path.resolve(process.cwd(), process.env.ROOT_DIR ?? "build/web");

const mimeTypes = new Map([
  [".html", "text/html; charset=utf-8"],
  [".js", "application/javascript; charset=utf-8"],
  [".wasm", "application/wasm"],
  [".pck", "application/octet-stream"],
  [".png", "image/png"],
  [".json", "application/json; charset=utf-8"],
  [".txt", "text/plain; charset=utf-8"],
]);

function resolvePath(urlPath) {
  const decoded = decodeURIComponent(urlPath.split("?")[0]);
  const requestPath = decoded === "/" ? "/index.html" : decoded;
  const candidate = path.resolve(root, `.${requestPath}`);
  if (!candidate.startsWith(root)) {
    return null;
  }
  return candidate;
}

const server = http.createServer((req, res) => {
  const filePath = resolvePath(req.url ?? "/");
  if (!filePath) {
    res.writeHead(403, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("Forbidden");
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("Not found");
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = mimeTypes.get(ext) ?? "application/octet-stream";
    res.writeHead(200, {
      "Content-Type": contentType,
      "Cache-Control": "no-cache",
    });
    res.end(data);
  });
});

server.listen(port, host, () => {
  console.log(`SERVER_READY http://${host}:${port}/index.html`);
  console.log(`SERVING_FROM ${root}`);
});

for (const signal of ["SIGINT", "SIGTERM"]) {
  process.on(signal, () => {
    server.close(() => process.exit(0));
  });
}

