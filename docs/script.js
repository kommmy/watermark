// =============================================================
// Sample data
// =============================================================
const DEFAULT_IMAGE = "./sample.svg";

const DEFAULT_DATA = {
  image: DEFAULT_IMAGE,
  cameraModel: "LEICA Q3",
  lensModel: "SUMMICRON 28 f/1.7 ASPH.",
  focal: 28,
  aperture: 1.7,
  shutter: "1/500s",
  iso: 200,
  date: "2026.05.25 14:00",
};

const TEMPLATES = [
  { id: "leica", name: "Leica" },
  { id: "fujifilm", name: "Fujifilm" },
  { id: "sony", name: "Sony" },
  { id: "hasselblad", name: "Hasselblad" },
  { id: "minimal", name: "Minimal" },
];

let state = {
  template: "leica",
  data: { ...DEFAULT_DATA },
};

// =============================================================
// HTML escaping (avoid XSS via user-entered fields)
// =============================================================
function escapeHtml(s) {
  if (s == null) return "";
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function paramsLine(d) {
  return [
    d.focal ? `${d.focal}mm` : null,
    d.aperture ? `f/${d.aperture}` : null,
    d.shutter || null,
    d.iso ? `ISO${d.iso}` : null,
  ]
    .filter(Boolean)
    .join("  ");
}

// =============================================================
// Templates – each returns innerHTML for the .preview-frame
// =============================================================
const RENDERERS = {
  leica(d) {
    return `
      <div class="canvas tpl-leica">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="bar">
          <div class="brand">
            <span class="logo">LEICA</span>
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
            <div class="logo">FUJIFILM</div>
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

  sony(d) {
    return `
      <div class="canvas tpl-sony">
        <img src="${escapeHtml(d.image)}" class="photo" alt="" />
        <div class="overlay">
          <div class="brand">SONY</div>
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
              <span class="h-dot">H</span>
              <span class="name">HASSELBLAD</span>
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
};

// =============================================================
// Render
// =============================================================
function render() {
  const renderer = RENDERERS[state.template] || RENDERERS.leica;
  document.getElementById("previewFrame").innerHTML = renderer(state.data);

  // Nav title 跟随当前机身名
  document.getElementById("navTitle").textContent =
    state.data.cameraModel || "编辑";

  // 模板选择缩略图：标记选中态 + 同步缩略图里的小图
  document.querySelectorAll(".tpl-thumb").forEach((btn) => {
    const isActive = btn.dataset.template === state.template;
    btn.classList.toggle("active", isActive);
    const thumb = btn.querySelector(".tpl-thumb-img img");
    if (thumb) thumb.src = state.data.image;
  });
}

// =============================================================
// Wire up controls
// =============================================================
function buildTemplateStrip() {
  const strip = document.getElementById("templateStrip");
  strip.innerHTML = TEMPLATES.map(
    (t) => `
      <button class="tpl-thumb" type="button" data-template="${t.id}">
        <div class="tpl-thumb-img">
          <img src="${escapeHtml(state.data.image)}" alt="" />
        </div>
        <span class="tpl-thumb-label">${t.name}</span>
      </button>`
  ).join("");

  strip.addEventListener("click", (ev) => {
    const btn = ev.target.closest(".tpl-thumb");
    if (!btn) return;
    state.template = btn.dataset.template;
    render();
  });
}

function bindForm() {
  const f = (id) => document.getElementById(id);
  const mapping = {
    fieldCamera: ["cameraModel", "string"],
    fieldLens: ["lensModel", "string"],
    fieldFocal: ["focal", "number"],
    fieldAperture: ["aperture", "number"],
    fieldShutter: ["shutter", "string"],
    fieldIso: ["iso", "number"],
    fieldDate: ["date", "string"],
  };

  // initial values
  Object.entries(mapping).forEach(([elId, [key]]) => {
    const v = state.data[key];
    if (v != null) f(elId).value = v;
  });

  Object.entries(mapping).forEach(([elId, [key, type]]) => {
    f(elId).addEventListener("input", (ev) => {
      const raw = ev.target.value;
      if (type === "number") {
        state.data[key] = raw === "" ? null : Number(raw);
      } else {
        state.data[key] = raw;
      }
      render();
    });
  });
}

function bindImageInput() {
  document.getElementById("fileInput").addEventListener("change", (ev) => {
    const file = ev.target.files && ev.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      state.data.image = reader.result;
      render();
    };
    reader.readAsDataURL(file);
  });

  document.getElementById("resetImageBtn").addEventListener("click", () => {
    state.data.image = DEFAULT_IMAGE;
    document.getElementById("fileInput").value = "";
    render();
  });
}

// =============================================================
// Boot
// =============================================================
buildTemplateStrip();
bindForm();
bindImageInput();
render();
