# Graphic Studio

A browser-based vector illustration app — a single, self-contained clone of the Mac app **Graphic / iDraw**. Runs with zero setup: just open `index.html` in a browser.

## Architecture

- **The entire app is `index.html`** — one self-contained file: HTML + CSS + vanilla JS, no build step, no dependencies, no framework. All edits happen here.
- SVG-based canvas. Core state model:
  `state = { doc, shapes[], layers[], activeLayer, sel[], tool, zoom, panX, panY, style{} }`.
- Shapes are plain objects (`type: rect|ellipse|polygon|star|line|path|freehand|text|image`), rendered to SVG each frame via `render()` → `renderOverlay()`.
- Google web fonts are loaded from a `<link>` at runtime; on **print/export** the used fonts are fetched and inlined as base64 `@font-face` so text renders correctly (SVG-in-`<img>` and standalone SVG can't load external fonts).

## Build badge — bump on EVERY change

The top-left brand shows a `BUILD N` badge (search `BUILD ` in `index.html`). **Increment N by 1 on every change** so the user can confirm a hard-refresh (Ctrl+F5) picked up the new version. This is the single most important convention.

## Publish workflow

When the user says **"publish"**: commit all changes and push to GitHub (`websmartzadmin/graphicstudio`, branch `main`) with a clear, descriptive commit message summarizing the build. **Vercel is connected to the GitHub repo and auto-deploys on every push** — no other deploy step is needed.

Commit message style: `BUILD N: short summary` + a few bullet points of what changed.

## Running / testing locally

- Simplest: open `index.html` directly in Chrome and hard-refresh (Ctrl+F5 on Windows, Cmd+Shift+R on Mac) to test; confirm the BUILD badge.
- Optional dev server on port 8777 (serves the folder with correct MIME types):
  - **Windows:** `powershell -File server.ps1`
  - **Mac / Linux:** `python3 -m http.server 8777` (run from the repo folder), then open http://localhost:8777. `server.ps1` is Windows-only and won't run on macOS.

## Files

- `index.html` — the whole application (the only file you normally edit).
- `server.ps1` — tiny local static file server (port 8777).
- `manifest.webmanifest`, `icon.png`, `icon-192.png`, `icon-512.png` — PWA install icon (transparent-corner pen logo).
- `.claude/launch.json` — preview server config.

## Product context

- Target user is **non-technical and cost-conscious**; wants close fidelity to Graphic/iDraw's interface and behavior. Prefer clear, simple UI over clever complexity.
- Test flow is always: open the file, hard-refresh, verify the BUILD badge changed.

## Notable behavior decisions (don't re-litigate)

- **Image crop:** enter via double-click an image or right-click → Crop Image. Crop model: frame = `s.x/y/w/h`, full image placement = `s.imgX/imgY/imgW/imgH`, clipped to the frame. Dragging *inside* the frame does **nothing** (handles-only); finish with a plain click, Enter/Esc, the Done button, double-click, or clicking outside. Moving/resizing a cropped image must carry `imgX/imgY/imgW/imgH` with the frame (else the picture and crop drift apart).
- **Paste:** menu Edit → Paste (`doPaste`) pastes internal shapes first, otherwise reads the OS clipboard for an image (Chrome shows its permission popup — the user accepts this). Ctrl+V pastes images with no prompt via the `paste` event. Right-click Paste is always enabled. Do **not** add a "use Ctrl+V" toast.
- **Lock:** a locked shape can't be selected/moved; right-click it for a per-object Unlock, or use Unlock All on empty canvas.
