// =============================================================
// LumaFrame · Web Demo
// 单文件 SPA：home (discover/watermark/puzzle/me) <-> editor
// =============================================================

// -------------------------------------------------------------
// Default sample images
// -------------------------------------------------------------
const SAMPLE_LANDSCAPE = "./sample.svg";
const SAMPLE_CAMERA    = "./sample-camera.svg";
const SAMPLE_PORTRAIT  = "./sample-portrait.svg";
const APP_NAME = "LumaFrame";

const LOGO = {
  leica: "./assets/logos/brand_leica.svg",
  fujifilm: "./assets/logos/brand_fujifilm.svg",
  sony: "./assets/logos/brand_sony.svg",
  hasselblad: "./assets/logos/brand_hasselblad.svg",
  ricoh: "./assets/logos/brand_ricoh.svg",
  apple: "./assets/logos/brand_apple.svg",
  polaroid: "./assets/logos/brand_polaroid.svg",
};

const DEFAULT_DATA = {
  image: SAMPLE_LANDSCAPE,
  cameraModel: "LEICA Q3",
  lensModel: "SUMMICRON 28 f/1.7 ASPH.",
  focal: 28,
  aperture: 1.7,
  shutter: "1/500s",
  iso: 200,
  date: "2026.05.25 14:00",
};

const TEMPLATE_PRESETS = {
  leica:        { cameraModel: "LEICA Q3", lensModel: "SUMMICRON 28 f/1.7 ASPH.", focal: 28, aperture: 1.7, shutter: "1/500s", iso: 200 },
  leica_mono:   { cameraModel: "LEICA M11 Monochrom", lensModel: "SUMMILUX-M 35 f/1.4", focal: 35, aperture: 1.4, shutter: "1/250s", iso: 400 },
  fujifilm:     { cameraModel: "FUJIFILM X100VI", lensModel: "23mm F2", focal: 35, aperture: 2, shutter: "1/320s", iso: 320 },
  fuji_strip:   { cameraModel: "FUJIFILM X-T5", lensModel: "XF 33mm F1.4", focal: 50, aperture: 1.4, shutter: "1/640s", iso: 250 },
  sony:         { cameraModel: "SONY A7CR", lensModel: "FE 35mm F1.4 GM", focal: 35, aperture: 1.4, shutter: "1/800s", iso: 100 },
  hasselblad:   { cameraModel: "HASSELBLAD X2D 100C", lensModel: "XCD 55V", focal: 43, aperture: 2.5, shutter: "1/500s", iso: 64 },
  ricoh_gr:     { cameraModel: "RICOH GR III", lensModel: "18.3mm F2.8", focal: 28, aperture: 2.8, shutter: "1/400s", iso: 200 },
  iphone:       { cameraModel: "iPhone 15 Pro", lensModel: "Main Camera", focal: 24, aperture: 1.8, shutter: "1/120s", iso: 80 },
  polaroid:     { cameraModel: "Polaroid Now+", lensModel: "Instant Film", focal: 35, aperture: 11, shutter: "1/60s", iso: 640 },
  minimal:      { cameraModel: "Canon R6 Mark II", lensModel: "RF 50mm F1.2", focal: 50, aperture: 1.2, shutter: "1/1000s", iso: 100 },
  minimal_dark: { cameraModel: "Nikon Zf", lensModel: "NIKKOR 40mm F2", focal: 40, aperture: 2, shutter: "1/250s", iso: 800 },
  date_stamp:   { cameraModel: "Kodak Gold 200", lensModel: "35mm Film", focal: 35, aperture: 5.6, shutter: "1/125s", iso: 200 },
};

// -------------------------------------------------------------
// 12 watermark templates
// -------------------------------------------------------------
const TEMPLATES = [
  { id: "leica",          name: "Leica White",  group: "leica",      brand: "LEICA" },
  { id: "leica_mono",     name: "Leica Mono",   group: "leica",      brand: "LEICA" },
  { id: "fujifilm",       name: "Fuji Dark",    group: "fujifilm",   brand: "FUJIFILM" },
  { id: "fuji_strip",     name: "Fuji Film",    group: "fujifilm",   brand: "FUJIFILM" },
  { id: "sony",           name: "Sony Alpha",   group: "sony",       brand: "SONY" },
  { id: "hasselblad",     name: "Hasselblad",   group: "hasselblad", brand: "HASSELBLAD" },
  { id: "ricoh_gr",       name: "Ricoh GR",     group: "ricoh",      brand: "RICOH" },
  { id: "iphone",         name: "iPhone Shot",  group: "iphone",     brand: "iPhone" },
  { id: "polaroid",       name: "Polaroid",     group: "instant",    brand: "Polaroid" },
  { id: "minimal",        name: "Minimal Light",group: "minimal",    brand: "Minimal" },
  { id: "minimal_dark",   name: "Minimal Dark", group: "minimal",    brand: "Minimal" },
  { id: "date_stamp",     name: "Date Stamp",   group: "stamp",      brand: "Kodak" },
];

// -------------------------------------------------------------
// 4 puzzle layouts
// -------------------------------------------------------------
const LAYOUTS = [
  { id: "vertical2",    name: "上下两格",   slots: 2, hint: "建筑 + 细节" },
  { id: "horizontal2",  name: "左右两格",   slots: 2, hint: "前后对比" },
  { id: "grid4",        name: "田字四格",   slots: 4, hint: "系列作品" },
  { id: "camera_detail",name: "相机 + 实拍",slots: 2, hint: "招牌玩法" },
];

// -------------------------------------------------------------
// App state
// -------------------------------------------------------------
const state = {
  page: "home",      // "home" | "editor-watermark" | "editor-puzzle"
  tab: "discover",   // "discover" | "watermark" | "puzzle" | "me"
  watermark: {
    templateId: "leica",
    data: { ...DEFAULT_DATA },
  },
  puzzle: {
    layoutId: "vertical2",
    images: [SAMPLE_CAMERA, SAMPLE_LANDSCAPE, SAMPLE_PORTRAIT, SAMPLE_LANDSCAPE],
    ratio: "3:4",     // "3:4" | "1:1" | "4:5" | "9:16"
    bg: "white",      // "white" | "black" | "warm" | "grad"
    caption: "Ricoh GR 3",
    tool: "layout",   // for editor toolbar highlight
  },
};

// -------------------------------------------------------------
// HTML helpers
// -------------------------------------------------------------
function h(strings, ...vals) {
  // tagged template that does light auto-escaping for ${} values
  let out = "";
  strings.forEach((s, i) => {
    out += s;
    if (i < vals.length) {
      const v = vals[i];
      out += (v == null) ? "" : (typeof v === "string" ? escapeHtml(v) : String(v));
    }
  });
  return out;
}
function escapeHtml(s) {
  if (s == null) return "";
  return String(s)
    .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;").replace(/'/g, "&#39;");
}
function paramsLine(d) {
  return [
    d.focal ? `${d.focal}mm` : null,
    d.aperture ? `f/${d.aperture}` : null,
    d.shutter || null,
    d.iso ? `ISO${d.iso}` : null,
  ].filter(Boolean).join("  ");
}

// =============================================================
// Watermark template renderers (innerHTML for .editor-preview-frame)
// =============================================================
const RENDERERS = {
  leica(d) {
    return `
      <div class="canvas tpl-leica">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          <div class="brand">
            <img src="${LOGO.leica}" class="logo logo-img" alt="Leica" />
            <div class="model">
              <div class="name">${escapeHtml(d.cameraModel)}</div>
              ${d.lensModel ? `<div class="lens">${escapeHtml(d.lensModel)}</div>` : ""}
            </div>
          </div>
          <div class="spacer"></div>
          <div class="divider"></div>
          <div class="params">
            <div class="line">${escapeHtml(paramsLine(d))}</div>
            ${d.date ? `<div class="date">${escapeHtml(d.date)}</div>` : ""}
          </div>
        </div>
      </div>`;
  },

  leica_mono(d) {
    return `
      <div class="canvas dark tpl-leica-mono">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          <div class="brand">
            <img src="${LOGO.leica}" class="logo logo-img" alt="Leica" />
            <div class="model">
              <div class="name">${escapeHtml(d.cameraModel)}</div>
              ${d.lensModel ? `<div class="lens">${escapeHtml(d.lensModel)}</div>` : ""}
            </div>
          </div>
          <div class="spacer"></div>
          <div class="divider"></div>
          <div class="params">
            <div class="line">${escapeHtml(paramsLine(d))}</div>
            ${d.date ? `<div class="date">${escapeHtml(d.date)}</div>` : ""}
          </div>
        </div>
      </div>`;
  },

  fujifilm(d) {
    return `
      <div class="canvas tpl-fujifilm">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          <div class="brand">
            <img src="${LOGO.fujifilm}" class="logo logo-img" alt="Fujifilm" />
            <div class="name">${escapeHtml(d.cameraModel || "X SERIES")}</div>
          </div>
          <div class="spacer"></div>
          <div class="params">
            <div class="line">${escapeHtml(paramsLine(d))}</div>
            ${d.date ? `<div class="date">${escapeHtml(d.date)}</div>` : ""}
          </div>
        </div>
      </div>`;
  },

  fuji_strip(d) {
    return `
      <div class="canvas tpl-fuji-strip">
        <div class="strip-top"></div>
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="strip-bottom"></div>
        <div class="bar">
          <span class="name"><img src="${LOGO.fujifilm}" class="logo logo-img" alt="Fujifilm" /> ${escapeHtml(d.cameraModel || "")}</span>
          <span class="spacer"></span>
          <span class="params">${escapeHtml(paramsLine(d))}</span>
        </div>
      </div>`;
  },

  sony(d) {
    return `
      <div class="canvas tpl-sony">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="overlay">
          <img src="${LOGO.sony}" class="brand-logo brand-logo-invert" alt="Sony" />
          ${d.cameraModel ? `<div class="model">${escapeHtml(d.cameraModel)}</div>` : ""}
          <div class="sep"></div>
          <div class="line">${escapeHtml(paramsLine(d))}</div>
          ${d.date ? `<div class="date">${escapeHtml(d.date)}</div>` : ""}
        </div>
      </div>`;
  },

  hasselblad(d) {
    return `
      <div class="canvas tpl-hasselblad">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="footer-bar">
          <div class="brand">
            <div class="row">
              <img src="${LOGO.hasselblad}" class="brand-logo" alt="Hasselblad" />
            </div>
            ${d.cameraModel ? `<div class="model">${escapeHtml(d.cameraModel)}</div>` : ""}
          </div>
          <div class="params">
            <div class="line">${escapeHtml(paramsLine(d))}</div>
            ${d.date ? `<div class="date">${escapeHtml(d.date)}</div>` : ""}
          </div>
        </div>
      </div>`;
  },

  ricoh_gr(d) {
    return `
      <div class="canvas dark tpl-ricoh-gr">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          <img src="${LOGO.ricoh}" class="logo logo-img logo-invert" alt="Ricoh" />
          <div class="brand">
            <div class="name">${escapeHtml(d.cameraModel || "RICOH GR III")}</div>
            ${d.lensModel ? `<div class="sub">${escapeHtml(d.lensModel)}</div>` : ""}
          </div>
          <span class="spacer"></span>
          <div class="params">
            <div class="line">${escapeHtml(paramsLine(d))}</div>
            ${d.date ? `<div class="date">${escapeHtml(d.date)}</div>` : ""}
          </div>
        </div>
      </div>`;
  },

  iphone(d) {
    return `
      <div class="canvas tpl-iphone">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          <div class="shot"><img src="${LOGO.apple}" class="apple-logo" alt="Apple" /> Shot on <span class="device">${escapeHtml(d.cameraModel || "iPhone")}</span></div>
        </div>
      </div>`;
  },

  polaroid(d) {
    return `
      <div class="canvas tpl-polaroid">
        <div class="photo-wrap">
          <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        </div>
        <img src="${LOGO.polaroid}" class="polaroid-logo" alt="Polaroid" />
        <div class="caption">${escapeHtml(d.cameraModel || "untitled")}</div>
        <div class="params">${escapeHtml(d.date || "")}</div>
      </div>`;
  },

  minimal(d) {
    const parts = [
      d.focal ? `${d.focal}mm` : null,
      d.aperture ? `f/${d.aperture}` : null,
      d.shutter || null,
      d.iso ? `ISO${d.iso}` : null,
      d.date || null,
    ].filter(Boolean);
    return `
      <div class="canvas tpl-minimal">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          ${d.cameraModel
            ? `<span class="name">${escapeHtml(d.cameraModel)}</span>
               <span class="divider"></span>`
            : ""}
          <span class="line">${escapeHtml(parts.join("  ·  "))}</span>
        </div>
      </div>`;
  },

  minimal_dark(d) {
    const parts = [
      d.focal ? `${d.focal}mm` : null,
      d.aperture ? `f/${d.aperture}` : null,
      d.shutter || null,
      d.iso ? `ISO${d.iso}` : null,
      d.date || null,
    ].filter(Boolean);
    return `
      <div class="canvas tpl-minimal-dark">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          ${d.cameraModel
            ? `<span class="name">${escapeHtml(d.cameraModel)}</span>
               <span class="divider"></span>`
            : ""}
          <span class="line">${escapeHtml(parts.join("  ·  "))}</span>
        </div>
      </div>`;
  },

  date_stamp(d) {
    return `
      <div class="canvas tpl-date-stamp">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="stamp">${escapeHtml(d.date || "2026 05 25")}</div>
      </div>`;
  },
};

// =============================================================
// Puzzle layout renderers
// 输入：images 数组（按 slot 顺序），options { ratio, bg, caption }
// =============================================================
const LAYOUT_RENDERERS = {
  vertical2(imgs, opts) {
    return `
      <div class="puzzle-canvas bg-${opts.bg}" style="${aspectStyle(opts.ratio)}">
        <div style="display:flex; flex-direction:column; height:100%; padding:10px; gap:6px;">
          <div class="puzzle-slot" style="flex:1; border-radius:6px;">
            <img src="${escapeHtml(imgs[0] || SAMPLE_LANDSCAPE)}" alt="" />
          </div>
          <div class="puzzle-slot" style="flex:1; border-radius:6px;">
            <img src="${escapeHtml(imgs[1] || SAMPLE_PORTRAIT)}" alt="" />
          </div>
        </div>
        ${opts.caption ? `<div class="puzzle-caption">${escapeHtml(opts.caption)}</div>` : ""}
      </div>`;
  },

  horizontal2(imgs, opts) {
    return `
      <div class="puzzle-canvas bg-${opts.bg}" style="${aspectStyle(opts.ratio)}">
        <div style="display:flex; height:100%; padding:10px; gap:6px;">
          <div class="puzzle-slot" style="flex:1; border-radius:6px;">
            <img src="${escapeHtml(imgs[0] || SAMPLE_LANDSCAPE)}" alt="" />
          </div>
          <div class="puzzle-slot" style="flex:1; border-radius:6px;">
            <img src="${escapeHtml(imgs[1] || SAMPLE_PORTRAIT)}" alt="" />
          </div>
        </div>
        ${opts.caption ? `<div class="puzzle-caption">${escapeHtml(opts.caption)}</div>` : ""}
      </div>`;
  },

  grid4(imgs, opts) {
    return `
      <div class="puzzle-canvas bg-${opts.bg}" style="${aspectStyle(opts.ratio)}">
        <div style="display:grid; grid-template-columns:1fr 1fr; grid-template-rows:1fr 1fr; height:100%; padding:10px; gap:6px;">
          ${[0,1,2,3].map(i => `
            <div class="puzzle-slot" style="border-radius:6px;">
              <img src="${escapeHtml(imgs[i] || SAMPLE_LANDSCAPE)}" alt="" />
            </div>
          `).join("")}
        </div>
        ${opts.caption ? `<div class="puzzle-caption">${escapeHtml(opts.caption)}</div>` : ""}
      </div>`;
  },

  camera_detail(imgs, opts) {
    // Camera detail layout: product photo on top, actual shot below.
    return `
      <div class="puzzle-canvas bg-${opts.bg}" style="${aspectStyle(opts.ratio)}">
        <div style="display:flex; flex-direction:column; height:100%;">
          <div style="flex:0 0 38%; display:flex; align-items:center; justify-content:center; padding:18px; background:#fff; flex-direction:column; gap:6px;">
            <div style="width:60%; aspect-ratio:4/3; overflow:hidden;">
              <img src="${escapeHtml(imgs[0] || SAMPLE_CAMERA)}" style="width:100%; height:100%; object-fit:contain;" alt="" />
            </div>
            ${opts.caption ? `<div style="font-size:11px; color:#333; font-weight:500;">${escapeHtml(opts.caption)}</div>` : ""}
          </div>
          <div class="puzzle-slot" style="flex:1; border-radius:0;">
            <img src="${escapeHtml(imgs[1] || SAMPLE_LANDSCAPE)}" alt="" />
          </div>
        </div>
      </div>`;
  },
};

function aspectStyle(ratio) {
  const map = { "3:4": "3/4", "1:1": "1/1", "4:5": "4/5", "9:16": "9/16" };
  return `aspect-ratio:${map[ratio] || "3/4"}; width:100%;`;
}

// =============================================================
// SVG icons (inline so we don't depend on icon font / external svg)
// =============================================================
const ICON = {
  back:    `<svg viewBox="0 0 12 20" aria-hidden="true"><path d="M10 1 L2 10 L10 19" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  gear:    `<svg viewBox="0 0 22 22"><path d="M11 14a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm9-2.5l-1.6-.5a7.4 7.4 0 0 0-.6-1.6l.9-1.4-1.7-1.7-1.4.9a7.4 7.4 0 0 0-1.6-.6L13.5 5h-2.5l-.5 1.6a7.4 7.4 0 0 0-1.6.6L7.5 6.3 5.8 8l.9 1.4a7.4 7.4 0 0 0-.6 1.6L4.5 11.5v2.5l1.6.5c.16.55.36 1.08.6 1.6l-.9 1.4 1.7 1.7 1.4-.9c.52.24 1.05.44 1.6.6l.5 1.6h2.5l.5-1.6a7.4 7.4 0 0 0 1.6-.6l1.4.9 1.7-1.7-.9-1.4c.24-.52.44-1.05.6-1.6l1.6-.5v-2.5z" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>`,
  share:   `<svg viewBox="0 0 22 22"><path d="M11 2 V13 M6 7 L11 2 L16 7" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 13 V19 H19 V13" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  save:    `<svg viewBox="0 0 22 22"><path d="M11 2 V13 M6 9 L11 14 L16 9" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M3 16 V19 H19 V16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>`,
  heart:   `<svg viewBox="0 0 22 22"><path d="M11 19s-7-4.5-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 18 9c0 5.5-7 10-7 10z" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/></svg>`,
  hot:     `<svg viewBox="0 0 22 22"><path d="M11 21s-6-3-6-9c0-3 2-5 3-5 0 0-1 3 2 3 0-3 2-7 4-7 0 4 4 6 4 11 0 4-3 7-7 7z" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/></svg>`,
  frame:   `<svg viewBox="0 0 22 22"><rect x="3" y="3" width="16" height="16" rx="2" fill="none" stroke="currentColor" stroke-width="1.6"/><rect x="6" y="6" width="10" height="10" fill="none" stroke="currentColor" stroke-width="1.2"/></svg>`,
  grid:    `<svg viewBox="0 0 22 22"><rect x="3" y="3" width="7" height="7" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/><rect x="12" y="3" width="7" height="7" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/><rect x="3" y="12" width="7" height="7" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/><rect x="12" y="12" width="7" height="7" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>`,
  user:    `<svg viewBox="0 0 22 22"><circle cx="11" cy="8" r="3.5" fill="none" stroke="currentColor" stroke-width="1.6"/><path d="M4 19a7 7 0 0 1 14 0" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>`,
  layout:  `<svg viewBox="0 0 22 22"><rect x="3" y="3" width="16" height="8" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/><rect x="3" y="13" width="7" height="6" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/><rect x="12" y="13" width="7" height="6" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>`,
  ratio:   `<svg viewBox="0 0 22 22"><rect x="4" y="5" width="14" height="12" rx="1" fill="none" stroke="currentColor" stroke-width="1.6"/><line x1="4" y1="11" x2="18" y2="11" stroke="currentColor" stroke-width="1.6" stroke-dasharray="2 2"/></svg>`,
  paint:   `<svg viewBox="0 0 22 22"><path d="M3 8 L19 8 L17 19 L5 19 Z" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/><circle cx="11" cy="5" r="2" fill="none" stroke="currentColor" stroke-width="1.6"/></svg>`,
  text:    `<svg viewBox="0 0 22 22"><path d="M5 6 L17 6 M11 6 L11 18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>`,
  add:     `<svg viewBox="0 0 22 22"><line x1="11" y1="4" x2="11" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><line x1="4" y1="11" x2="18" y2="11" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>`,
};

// =============================================================
// HOME page renderer (with 4 tabs)
// =============================================================
function renderHome() {
  const root = document.getElementById("appRoot");
  root.innerHTML = `
    <div class="app-root">
      <div class="app-top">
        <button class="pill pill-pro">PRO</button>
        <h1 class="app-title">${APP_NAME}</h1>
        <button class="icon-btn" aria-label="设置">${ICON.gear}</button>
      </div>

      <nav class="cat-chips">
        ${renderChip("discover", ICON.hot,   "推荐")}
        ${renderChip("watermark",ICON.frame, "水印")}
        ${renderChip("puzzle",   ICON.grid,  "拼图")}
        ${renderChip("me",       ICON.heart, "我的")}
      </nav>

      <div class="tab-content" id="tabContent">
        ${renderTab(state.tab)}
      </div>

      <nav class="tab-bar">
        ${renderTabBarBtn("discover", ICON.hot,   "推荐")}
        ${renderTabBarBtn("watermark",ICON.frame, "水印")}
        ${renderTabBarBtn("puzzle",   ICON.grid,  "拼图")}
        ${renderTabBarBtn("me",       ICON.user,  "我的")}
      </nav>

      <div class="home-indicator"></div>
    </div>
  `;

  // Wire chip + tabbar
  root.querySelectorAll("[data-tab]").forEach(el => {
    el.addEventListener("click", () => {
      state.tab = el.dataset.tab;
      renderHome();
    });
  });
  // Wire entry into editor
  root.querySelectorAll("[data-template-id]").forEach(el => {
    el.addEventListener("click", () => {
      state.watermark.templateId = el.dataset.templateId;
      applyTemplatePreset(el.dataset.templateId);
      state.page = "editor-watermark";
      renderApp();
    });
  });
  root.querySelectorAll("[data-layout-id]").forEach(el => {
    el.addEventListener("click", () => {
      state.puzzle.layoutId = el.dataset.layoutId;
      state.page = "editor-puzzle";
      renderApp();
    });
  });
}

function renderChip(id, icon, label) {
  return `<button class="chip ${state.tab === id ? "active" : ""}" data-tab="${id}">${icon}${label}</button>`;
}
function renderTabBarBtn(id, icon, label) {
  return `<button class="${state.tab === id ? "active" : ""}" data-tab="${id}">${icon}<span>${label}</span></button>`;
}

function renderTab(tab) {
  switch (tab) {
    case "discover":  return renderDiscover();
    case "watermark": return renderWatermarkList();
    case "puzzle":    return renderPuzzleList();
    case "me":        return renderMe();
    default:          return "";
  }
}

function renderDiscover() {
  return `
    <div class="discover">
      <div class="banner">
        <div class="banner-text">
          <p class="banner-kicker">TODAY'S PICK</p>
          <p class="banner-title">把照片变成一张作品卡</p>
          <p class="banner-sub">真实品牌 logo、水印签名和拼图布局都在本地完成</p>
        </div>
        <button class="banner-cta">开始创作</button>
      </div>

      <div class="section">
        <div class="section-head">
          <h3 class="section-title">水印</h3>
          <button class="section-more" data-tab="watermark">更多 ›</button>
        </div>
        <div class="h-scroll">
          ${TEMPLATES.slice(0, 8).map(t => `
            <button class="cover-card" data-template-id="${t.id}">
              ${renderTemplateCover(t)}
              <div class="meta">
                <p class="name">${escapeHtml(t.name)}</p>
                <p class="desc">${escapeHtml(t.brand)}</p>
              </div>
            </button>
          `).join("")}
        </div>
      </div>

      <div class="section">
        <div class="section-head">
          <h3 class="section-title">拼图</h3>
          <button class="section-more" data-tab="puzzle">更多 ›</button>
        </div>
        <div class="h-scroll">
          ${LAYOUTS.map(l => `
            <button class="cover-card" data-layout-id="${l.id}">
              <div class="cover">${puzzleCoverSvg(l.id)}</div>
              <div class="meta">
                <p class="name">${escapeHtml(l.name)}</p>
                <p class="desc">${escapeHtml(l.hint)}</p>
              </div>
            </button>
          `).join("")}
        </div>
      </div>
    </div>`;
}

function renderWatermarkList() {
  return `
    <div class="grid-2" style="padding-top: 8px; padding-bottom: 16px;">
      ${TEMPLATES.map(t => `
        <button class="cover-card" data-template-id="${t.id}">
          ${renderTemplateCover(t)}
          <div class="meta">
            <p class="name">${escapeHtml(t.name)}</p>
            <p class="desc">${escapeHtml(t.brand)}</p>
          </div>
        </button>
      `).join("")}
    </div>`;
}

function renderPuzzleList() {
  return `
    <div class="grid-2" style="padding-top: 8px; padding-bottom: 16px;">
      ${LAYOUTS.map(l => `
        <button class="cover-card" data-layout-id="${l.id}">
          <div class="cover">${puzzleCoverSvg(l.id)}</div>
          <div class="meta">
            <p class="name">${escapeHtml(l.name)}</p>
            <p class="desc">${escapeHtml(l.hint)}（${l.slots} 张图）</p>
          </div>
        </button>
      `).join("")}
    </div>`;
}

function renderMe() {
  return `
    <div style="padding: 24px 18px; color: var(--text-2); font-size: 13px;">
      <p style="color: var(--text); font-size: 14px; font-weight: 600; margin: 0 0 8px;">最近作品</p>
      <p>暂无作品。返回首页选个模板试试吧。</p>
      <p style="color: var(--text); font-size: 14px; font-weight: 600; margin: 24px 0 8px;">关于</p>
      <p>这是一个开源的相机水印 + 拼图工具，仓库：</p>
      <p><a href="https://github.com/kommmy/watermark" target="_blank" style="color: var(--accent-blue); text-decoration: none;">github.com/kommmy/watermark</a></p>
    </div>`;
}

function applyTemplatePreset(id) {
  const preset = TEMPLATE_PRESETS[id];
  if (!preset) return;
  state.watermark.data = {
    ...state.watermark.data,
    ...preset,
    image: state.watermark.data.image,
    date: state.watermark.data.date || DEFAULT_DATA.date,
  };
}

function renderTemplateCover(t) {
  const logoKey = logoKeyForTemplate(t.id);
  const preset = TEMPLATE_PRESETS[t.id] || {};
  const logo = LOGO[logoKey] ? `<img src="${LOGO[logoKey]}" alt="${escapeHtml(t.brand)}" />` : `<span>${escapeHtml(t.brand)}</span>`;
  return `
    <div class="cover template-cover template-cover-${t.id}">
      <div class="cover-glow"></div>
      <div class="cover-photo-mark"></div>
      <div class="cover-logo ${logoKey === "sony" || logoKey === "ricoh" ? "invert" : ""}">${logo}</div>
      <div class="cover-spec">
        <span>${escapeHtml(preset.cameraModel || t.brand)}</span>
        <b>${escapeHtml(paramsLine({ ...DEFAULT_DATA, ...preset }))}</b>
      </div>
    </div>`;
}

function logoKeyForTemplate(id) {
  if (id.startsWith("leica")) return "leica";
  if (id.startsWith("fuji")) return "fujifilm";
  if (id === "sony") return "sony";
  if (id === "hasselblad") return "hasselblad";
  if (id === "ricoh_gr") return "ricoh";
  if (id === "iphone") return "apple";
  if (id === "polaroid") return "polaroid";
  return null;
}

// SVG cover for puzzle layouts (since we don't have real previews)
function puzzleCoverSvg(id) {
  const w = 200, h = 240, gap = 8, pad = 16;
  const inner = `<rect x="${pad}" y="${pad}" width="${w-pad*2}" height="${h-pad*2}" rx="6" fill="#3a3a3f"/>`;
  switch (id) {
    case "vertical2": {
      const halfH = (h - pad*2 - gap) / 2;
      return `<svg viewBox="0 0 ${w} ${h}" width="100%" height="100%"><rect width="${w}" height="${h}" fill="#1a1a1d"/>
        <rect x="${pad}" y="${pad}" width="${w-pad*2}" height="${halfH}" rx="4" fill="#5a5a60"/>
        <rect x="${pad}" y="${pad+halfH+gap}" width="${w-pad*2}" height="${halfH}" rx="4" fill="#888"/></svg>`;
    }
    case "horizontal2": {
      const halfW = (w - pad*2 - gap) / 2;
      return `<svg viewBox="0 0 ${w} ${h}" width="100%" height="100%"><rect width="${w}" height="${h}" fill="#1a1a1d"/>
        <rect x="${pad}" y="${pad}" width="${halfW}" height="${h-pad*2}" rx="4" fill="#5a5a60"/>
        <rect x="${pad+halfW+gap}" y="${pad}" width="${halfW}" height="${h-pad*2}" rx="4" fill="#888"/></svg>`;
    }
    case "grid4": {
      const halfW = (w - pad*2 - gap) / 2;
      const halfH = (h - pad*2 - gap) / 2;
      return `<svg viewBox="0 0 ${w} ${h}" width="100%" height="100%"><rect width="${w}" height="${h}" fill="#1a1a1d"/>
        <rect x="${pad}" y="${pad}" width="${halfW}" height="${halfH}" rx="4" fill="#5a5a60"/>
        <rect x="${pad+halfW+gap}" y="${pad}" width="${halfW}" height="${halfH}" rx="4" fill="#888"/>
        <rect x="${pad}" y="${pad+halfH+gap}" width="${halfW}" height="${halfH}" rx="4" fill="#888"/>
        <rect x="${pad+halfW+gap}" y="${pad+halfH+gap}" width="${halfW}" height="${halfH}" rx="4" fill="#5a5a60"/></svg>`;
    }
    case "camera_detail":
    default: {
      const topH = (h - pad*2) * 0.4;
      const botH = (h - pad*2) - topH - gap;
      return `<svg viewBox="0 0 ${w} ${h}" width="100%" height="100%"><rect width="${w}" height="${h}" fill="#1a1a1d"/>
        <rect x="${pad}" y="${pad}" width="${w-pad*2}" height="${topH}" rx="4" fill="#fff"/>
        <rect x="${pad + (w-pad*2)*0.3}" y="${pad + topH*0.25}" width="${(w-pad*2)*0.4}" height="${topH*0.5}" rx="2" fill="#333"/>
        <rect x="${pad}" y="${pad+topH+gap}" width="${w-pad*2}" height="${botH}" rx="4" fill="#888"/></svg>`;
    }
  }
}

// =============================================================
// WATERMARK editor
// =============================================================
function renderWatermarkEditor() {
  const tpl = TEMPLATES.find(t => t.id === state.watermark.templateId) || TEMPLATES[0];
  const root = document.getElementById("appRoot");
  root.innerHTML = `
    <div class="app-root">
      <div class="editor">
        <div class="editor-nav">
          <button class="nav-back" id="navBack">${ICON.back}</button>
          <span class="nav-title">${escapeHtml(state.watermark.data.cameraModel || tpl.name)}</span>
          <div class="nav-actions">
            <button class="icon-btn" aria-label="收藏">${ICON.heart}</button>
            <button class="icon-btn" aria-label="分享">${ICON.share}</button>
          </div>
        </div>

        <div class="editor-preview">
          <div class="editor-preview-frame" id="previewFrame">
            ${RENDERERS[tpl.id](state.watermark.data)}
          </div>
        </div>

        <div class="editor-strip" id="templateStrip">
          ${TEMPLATES.map(t => `
            <button class="tpl-thumb ${t.id === tpl.id ? "active" : ""}" data-tpl="${t.id}">
              <div class="thumb-img"><img src="${escapeHtml(state.watermark.data.image)}" alt="" /></div>
              <span class="thumb-label">${escapeHtml(t.name)}</span>
            </button>
          `).join("")}
        </div>

        <div class="editor-actions">
          <button class="btn-pill btn-ghost">${ICON.share}分享</button>
          <button class="btn-pill btn-primary">${ICON.save}保存到相册</button>
        </div>

        <div class="home-indicator"></div>
      </div>
    </div>`;

  document.getElementById("navBack").addEventListener("click", () => {
    state.page = "home";
    renderApp();
  });

  root.querySelectorAll("[data-tpl]").forEach(el => {
    el.addEventListener("click", () => {
      state.watermark.templateId = el.dataset.tpl;
      renderWatermarkEditor();
      renderControls();
    });
  });
}

// =============================================================
// PUZZLE editor
// =============================================================
function renderPuzzleEditor() {
  const layout = LAYOUTS.find(l => l.id === state.puzzle.layoutId) || LAYOUTS[0];
  const root = document.getElementById("appRoot");
  root.innerHTML = `
    <div class="app-root">
      <div class="editor">
        <div class="editor-nav">
          <button class="nav-back" id="navBack">${ICON.back}</button>
          <span class="nav-title">${escapeHtml(layout.name)}</span>
          <div class="nav-actions">
            <button class="icon-btn" aria-label="收藏">${ICON.heart}</button>
            <button class="icon-btn" aria-label="分享">${ICON.share}</button>
          </div>
        </div>

        <div class="editor-preview">
          <div class="editor-preview-frame" id="previewFrame">
            ${LAYOUT_RENDERERS[layout.id](state.puzzle.images, state.puzzle)}
          </div>
        </div>

        <div class="editor-toolbar">
          ${toolbarBtn("layout", ICON.layout, "布局")}
          ${toolbarBtn("ratio",  ICON.ratio,  state.puzzle.ratio)}
          ${toolbarBtn("bg",     ICON.paint,  "背景")}
          ${toolbarBtn("text",   ICON.text,   "文字")}
        </div>

        <div class="home-indicator"></div>
      </div>
    </div>`;

  document.getElementById("navBack").addEventListener("click", () => {
    state.page = "home";
    renderApp();
  });
}

function toolbarBtn(id, icon, label) {
  return `<button class="${state.puzzle.tool === id ? "active" : ""}" data-tool="${id}">${icon}<span>${label}</span></button>`;
}

// =============================================================
// CONTROLS panel (right column outside iPhone)
// =============================================================
function renderControls() {
  const el = document.getElementById("controls");
  if (state.page === "home") {
    el.innerHTML = renderHomeControls();
  } else if (state.page === "editor-watermark") {
    el.innerHTML = renderWatermarkControls();
    bindWatermarkControls();
  } else if (state.page === "editor-puzzle") {
    el.innerHTML = renderPuzzleControls();
    bindPuzzleControls();
  }
}

function renderHomeControls() {
  return `
    <div class="card">
      <h2>使用说明</h2>
      <p style="font-size:13px;color:#555;line-height:1.6;margin:0;">
        在左侧 iPhone 里：
        <br/>· 顶部 chips 或底部 tabbar 切换功能
        <br/>· 点任一卡片进入编辑器
        <br/>· 编辑器内可换模板/换布局、调参数
      </p>
    </div>
    <div class="card subtle">
      <p>所有效果在浏览器内即时渲染，无需任何后端。最终 iOS App 使用 SwiftUI <code>ImageRenderer</code> 输出像素一致的 JPEG。</p>
    </div>`;
}

function renderWatermarkControls() {
  const d = state.watermark.data;
  return `
    <div class="card">
      <h2>照片</h2>
      <label class="file-input">
        <input type="file" accept="image/*" id="fileInput" />
        <span>上传一张照片</span>
      </label>
      <button class="reset-btn" id="resetImageBtn" type="button">恢复默认示例图</button>
    </div>
    <div class="card">
      <h2>参数（EXIF）</h2>
      <div class="field">
        <label for="fieldCamera">机身</label>
        <input id="fieldCamera" type="text" value="${escapeHtml(d.cameraModel ?? "")}" />
      </div>
      <div class="field">
        <label for="fieldLens">镜头</label>
        <input id="fieldLens" type="text" value="${escapeHtml(d.lensModel ?? "")}" />
      </div>
      <div class="row">
        <div class="field">
          <label for="fieldFocal">焦距 (mm)</label>
          <input id="fieldFocal" type="number" min="0" step="1" value="${d.focal ?? ""}" />
        </div>
        <div class="field">
          <label for="fieldAperture">光圈 f/</label>
          <input id="fieldAperture" type="number" min="0" step="0.1" value="${d.aperture ?? ""}" />
        </div>
      </div>
      <div class="row">
        <div class="field">
          <label for="fieldShutter">快门</label>
          <input id="fieldShutter" type="text" placeholder="1/500s" value="${escapeHtml(d.shutter ?? "")}" />
        </div>
        <div class="field">
          <label for="fieldIso">ISO</label>
          <input id="fieldIso" type="number" min="0" step="100" value="${d.iso ?? ""}" />
        </div>
      </div>
      <div class="field">
        <label for="fieldDate">日期</label>
        <input id="fieldDate" type="text" placeholder="2026.05.25 14:00" value="${escapeHtml(d.date ?? "")}" />
      </div>
    </div>
    <div class="card subtle">
      <p>切换模板可直接点 iPhone 屏幕底部的缩略图。修改参数实时同步预览。</p>
    </div>`;
}

function renderPuzzleControls() {
  const p = state.puzzle;
  return `
    <div class="card">
      <h2>图片</h2>
      ${[0, 1, 2, 3].slice(0, LAYOUTS.find(l => l.id === p.layoutId)?.slots ?? 2).map(i => `
        <label class="file-input" style="margin-bottom: 8px;">
          <input type="file" accept="image/*" data-slot="${i}" class="puzzle-file" />
          <span>图 ${i + 1}：上传 / 替换</span>
        </label>
      `).join("")}
      <button class="reset-btn" id="resetPuzzleBtn" type="button">恢复默认示例</button>
    </div>

    <div class="card">
      <h2>比例</h2>
      <div class="row" style="grid-template-columns: repeat(4, 1fr); gap:6px;">
        ${["3:4","1:1","4:5","9:16"].map(r => `
          <button data-ratio="${r}" class="chip" style="background:${r === p.ratio ? "#1a1a1a" : "#f1f1f1"}; color:${r === p.ratio ? "#fff" : "#333"};">${r}</button>
        `).join("")}
      </div>
    </div>

    <div class="card">
      <h2>背景</h2>
      <div class="swatch-row">
        <button class="swatch w ${p.bg === "white" ? "active" : ""}" data-bg="white" aria-label="白"></button>
        <button class="swatch b ${p.bg === "black" ? "active" : ""}" data-bg="black" aria-label="黑"></button>
        <button class="swatch warm ${p.bg === "warm" ? "active" : ""}" data-bg="warm" aria-label="米"></button>
        <button class="swatch grad ${p.bg === "grad" ? "active" : ""}" data-bg="grad" aria-label="渐变"></button>
      </div>
    </div>

    <div class="card">
      <h2>文字</h2>
      <div class="field">
        <label for="puzzleCaption">下方文字</label>
        <input id="puzzleCaption" type="text" value="${escapeHtml(p.caption ?? "")}" placeholder="例如：Ricoh GR 3" />
      </div>
    </div>`;
}

function bindWatermarkControls() {
  const mapping = {
    fieldCamera:   ["cameraModel", "string"],
    fieldLens:     ["lensModel",   "string"],
    fieldFocal:    ["focal",       "number"],
    fieldAperture: ["aperture",    "number"],
    fieldShutter:  ["shutter",     "string"],
    fieldIso:      ["iso",         "number"],
    fieldDate:     ["date",        "string"],
  };
  Object.entries(mapping).forEach(([elId, [key, type]]) => {
    const el = document.getElementById(elId);
    if (!el) return;
    el.addEventListener("input", (ev) => {
      const raw = ev.target.value;
      state.watermark.data[key] = type === "number" ? (raw === "" ? null : Number(raw)) : raw;
      renderWatermarkEditor();
    });
  });

  document.getElementById("fileInput")?.addEventListener("change", (ev) => {
    const file = ev.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      state.watermark.data.image = reader.result;
      renderWatermarkEditor();
    };
    reader.readAsDataURL(file);
  });

  document.getElementById("resetImageBtn")?.addEventListener("click", () => {
    state.watermark.data.image = SAMPLE_LANDSCAPE;
    renderWatermarkEditor();
    renderControls();
  });
}

function bindPuzzleControls() {
  document.querySelectorAll("[data-ratio]").forEach(b => {
    b.addEventListener("click", () => {
      state.puzzle.ratio = b.dataset.ratio;
      renderPuzzleEditor();
      renderControls();
    });
  });
  document.querySelectorAll("[data-bg]").forEach(b => {
    b.addEventListener("click", () => {
      state.puzzle.bg = b.dataset.bg;
      renderPuzzleEditor();
      renderControls();
    });
  });
  document.getElementById("puzzleCaption")?.addEventListener("input", (ev) => {
    state.puzzle.caption = ev.target.value;
    renderPuzzleEditor();
  });
  document.querySelectorAll(".puzzle-file").forEach(input => {
    input.addEventListener("change", (ev) => {
      const slot = Number(ev.target.dataset.slot);
      const file = ev.target.files?.[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = () => {
        state.puzzle.images[slot] = reader.result;
        renderPuzzleEditor();
      };
      reader.readAsDataURL(file);
    });
  });
  document.getElementById("resetPuzzleBtn")?.addEventListener("click", () => {
    state.puzzle.images = [SAMPLE_CAMERA, SAMPLE_LANDSCAPE, SAMPLE_PORTRAIT, SAMPLE_LANDSCAPE];
    renderPuzzleEditor();
    renderControls();
  });
}

// =============================================================
// Top-level dispatch
// =============================================================
function renderApp() {
  switch (state.page) {
    case "home":               renderHome();             break;
    case "editor-watermark":   renderWatermarkEditor();  break;
    case "editor-puzzle":      renderPuzzleEditor();     break;
  }
  renderControls();
}

// Boot
renderApp();
