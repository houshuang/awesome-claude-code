# App Icon Generation

Generate app icon PNGs from HTML/CSS designs using Chrome headless screenshots.

## Workflow

1. **Design in HTML/CSS** — Create a standalone HTML file per icon size with Google Fonts loaded via `<link>`. No external images.
2. **Screenshot with Chrome headless** — Renders at exact pixel dimensions.
3. **Place in project assets directory.**

## Common Sizes

| File | Size | Notes |
|------|------|-------|
| `icon.png` | 1024x1024 | **No border-radius** — iOS/Android apply their own mask |
| `splash-icon.png` | 1024x1024 | Same as icon or custom splash design |
| `adaptive-icon.png` | 1024x1024 | Extra inset padding (~120px) for Android safe zone, no border-radius |
| `favicon.png` | 48x48 | Web favicon |

## HTML Template

Each HTML file sets `body` to the exact target dimensions with `overflow: hidden`:

```html
<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<link href="https://fonts.googleapis.com/css2?family=FONT_NAME&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { width: 1024px; height: 1024px; overflow: hidden; }
  .icon {
    width: 1024px; height: 1024px;
    background: #0f0f1a;
    display: flex; align-items: center; justify-content: center;
  }
</style>
</head>
<body><div class="icon"><!-- content --></div></body></html>
```

## Chrome Headless Command

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

"$CHROME" --headless=new --disable-gpu --no-sandbox --disable-application-cache \
  --screenshot="OUTPUT_PATH.png" --window-size=WIDTHxHEIGHT \
  "file:///path/to/source.html?v=CACHEBUST"
```

- **`--headless=new`** — Required for modern Chrome headless mode.
- **`--disable-application-cache`** + `?v=N` query param — Prevents Chrome from serving cached renders when iterating.
- **`--window-size`** must match the body dimensions in the HTML.
- **`dangerouslyDisableSandbox: true`** is required since Chrome launches a subprocess.

## Key Gotchas

- **No rounded corners on source images.** iOS and Android apply their own masks. Baking in border-radius causes double-rounding.
- **Adaptive icon needs extra padding** (~120px inset) because Android crops a circle/squircle from the center.
- **Google Fonts need network access.** The HTML loads fonts via `<link>`, so Chrome needs to fetch them. If offline, use locally installed fonts instead.
- **Cache busting.** When iterating, Chrome may cache the old render. Append `?v=2` (or increment) to the file URL and use `--disable-application-cache`.
- **Rosetta warning on Apple Silicon** is cosmetic — screenshots still render correctly despite the ARM/x64 warning.
