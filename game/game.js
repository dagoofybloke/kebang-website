/* ============================================================
   TAKAM MISING SÍ:SANG KÉBANG — Game Engine
   ============================================================ */

"use strict";

// ── DOM REFS ─────────────────────────────────────────────────
const canvas = document.getElementById("game-canvas");
const ctx = canvas.getContext("2d");
const titleScreen = document.getElementById("title-screen");
const gameoverScreen = document.getElementById("gameover-screen");
const hud = document.getElementById("hud");
const mobileCtrl = document.getElementById("mobile-controls");
const healthBar = document.getElementById("health-bar");
const healthText = document.getElementById("health-text");
const killCountEl = document.getElementById("kill-count");
const waveNumEl = document.getElementById("wave-num");
const zoneTimeEl = document.getElementById("zone-time");
const goKillsEl = document.getElementById("go-kills");
const goWaveEl = document.getElementById("go-wave");
const goTitleEl = document.getElementById("go-title");
const goMsgEl = document.getElementById("go-msg");
const joystickBase = document.getElementById("joystick-base");
const joystickKnob = document.getElementById("joystick-knob");

// ── CONSTANTS ────────────────────────────────────────────────
const WORLD_W = 1800;
const WORLD_H = 1800;
const PLAYER_SPEED = 200;
const PLAYER_RADIUS = 18;
const BULLET_SPEED = 520;
const BULLET_RADIUS = 5;
const BULLET_DAMAGE = 25;
const ENEMY_RADIUS = 16;
const ENEMY_SPEED_BASE = 75;
const ZONE_SHRINK_INTERVAL = 30; // seconds between shrinks
const ZONE_SHRINK_AMOUNT = 0.1; // fraction per shrink
const ZONE_DAMAGE = 8; // hp/sec outside zone
const TREE_COUNT = 80;
const ROCK_COUNT = 40;

// ── PALETTE ──────────────────────────────────────────────────
const C = {
  dark: "#0f0402",
  crimson: "#8c1a0e",
  amber: "#c87010",
  green: "#3a7a2a",
  greenLt: "#5db84a",
  blue: "rgba(30,100,220,0.22)",
  blueLine: "rgba(80,160,255,0.85)",
  ground: "#1a0d06",
  ground2: "#231108",
  text: "#f5ddb0",
};

// ── GAME STATE ────────────────────────────────────────────────
let state = {};
let keys = {};
let mouse = { x: 0, y: 0, shooting: false };
let joystick = { active: false, dx: 0, dy: 0, touchId: null };
let fireBtnActive = false;
let lastTime = 0;
let animId = null;
let isMobile = false;
let particles = [];
let trees = [];
let rocks = [];
let floatingTexts = [];

// ── DETECT MOBILE ─────────────────────────────────────────────
function detectMobile() {
  return (
    "ontouchstart" in window ||
    navigator.maxTouchPoints > 0 ||
    window.innerWidth <= 900
  );
}

// ── RESIZE CANVAS ─────────────────────────────────────────────
function resizeCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}

window.addEventListener("resize", () => {
  resizeCanvas();
  if (state.running) state.camera = computeCamera();
});

// ── CAMERA ────────────────────────────────────────────────────
function computeCamera() {
  const p = state.player;
  return {
    x: Math.max(0, Math.min(WORLD_W - canvas.width, p.x - canvas.width / 2)),
    y: Math.max(0, Math.min(WORLD_H - canvas.height, p.y - canvas.height / 2)),
  };
}

// ── WORLD GENERATION ─────────────────────────────────────────
function generateWorld() {
  trees = [];
  rocks = [];
  for (let i = 0; i < TREE_COUNT; i++) {
    trees.push({
      x: 80 + Math.random() * (WORLD_W - 160),
      y: 80 + Math.random() * (WORLD_H - 160),
      r: 14 + Math.random() * 14,
      shade: Math.random() > 0.5,
    });
  }
  for (let i = 0; i < ROCK_COUNT; i++) {
    rocks.push({
      x: 60 + Math.random() * (WORLD_W - 120),
      y: 60 + Math.random() * (WORLD_H - 120),
      w: 18 + Math.random() * 22,
      h: 14 + Math.random() * 16,
      angle: Math.random() * Math.PI,
    });
  }
}

// ── INIT GAME ─────────────────────────────────────────────────
function initGame() {
  generateWorld();
  state = {
    running: true,
    player: {
      x: WORLD_W / 2,
      y: WORLD_H / 2,
      hp: 100,
      maxHp: 100,
      angle: 0,
      radius: PLAYER_RADIUS,
      shootCooldown: 0,
    },
    enemies: [],
    bullets: [],
    enemyBullets: [],
    kills: 0,
    wave: 1,
    waveTimer: 0,
    spawnTimer: 0,
    spawnInterval: 2.5,
    maxEnemies: 6,
    zone: {
      cx: WORLD_W / 2,
      cy: WORLD_H / 2,
      r: Math.min(WORLD_W, WORLD_H) * 0.48,
      targetR: Math.min(WORLD_W, WORLD_H) * 0.38,
      shrinkTimer: ZONE_SHRINK_INTERVAL,
      shrinking: false,
      shrinkProgress: 1,
    },
    camera: {
      x: WORLD_W / 2 - canvas.width / 2,
      y: WORLD_H / 2 - canvas.height / 2,
    },
  };
  particles = [];
  floatingTexts = [];
  state.camera = computeCamera();

  // Spawn initial wave
  spawnEnemies(state.wave + 2);
}

// ── ENEMY SPAWNING ────────────────────────────────────────────
function spawnEnemy() {
  const z = state.zone;
  // Spawn at zone edge or random world edge
  const angle = Math.random() * Math.PI * 2;
  const dist = z.r * (0.5 + Math.random() * 0.45);
  let x = z.cx + Math.cos(angle) * dist;
  let y = z.cy + Math.sin(angle) * dist;
  x = Math.max(ENEMY_RADIUS, Math.min(WORLD_W - ENEMY_RADIUS, x));
  y = Math.max(ENEMY_RADIUS, Math.min(WORLD_H - ENEMY_RADIUS, y));

  const speed = ENEMY_SPEED_BASE + state.wave * 8 + Math.random() * 30;
  const hp = 40 + state.wave * 10;
  state.enemies.push({
    x,
    y,
    hp,
    maxHp: hp,
    radius: ENEMY_RADIUS,
    speed,
    angle: 0,
    shootCooldown: 1 + Math.random() * 2,
    shootInterval: 1.8 - Math.min(1.2, state.wave * 0.1),
  });
}

function spawnEnemies(count) {
  for (let i = 0; i < count; i++) spawnEnemy();
}

// ── PARTICLES ─────────────────────────────────────────────────
function spawnParticles(x, y, color, count, speed) {
  for (let i = 0; i < count; i++) {
    const angle = Math.random() * Math.PI * 2;
    const spd = speed * (0.4 + Math.random() * 0.8);
    particles.push({
      x,
      y,
      vx: Math.cos(angle) * spd,
      vy: Math.sin(angle) * spd,
      life: 0.5 + Math.random() * 0.4,
      maxLife: 0.5 + Math.random() * 0.4,
      r: 3 + Math.random() * 4,
      color,
    });
  }
}

function addFloatingText(x, y, text, color) {
  floatingTexts.push({ x, y, text, color, life: 1.2, vy: -50 });
}

// ── UPDATE ────────────────────────────────────────────────────
function update(dt) {
  if (!state.running) return;

  const p = state.player;
  const z = state.zone;

  // Player movement
  let dx = 0,
    dy = 0;
  if (isMobile) {
    dx = joystick.dx;
    dy = joystick.dy;
  } else {
    if (keys["w"] || keys["arrowup"]) dy -= 1;
    if (keys["s"] || keys["arrowdown"]) dy += 1;
    if (keys["a"] || keys["arrowleft"]) dx -= 1;
    if (keys["d"] || keys["arrowright"]) dx += 1;
    const mag = Math.hypot(dx, dy);
    if (mag > 0) {
      dx /= mag;
      dy /= mag;
    }
  }

  p.x = Math.max(
    p.radius,
    Math.min(WORLD_W - p.radius, p.x + dx * PLAYER_SPEED * dt),
  );
  p.y = Math.max(
    p.radius,
    Math.min(WORLD_H - p.radius, p.y + dy * PLAYER_SPEED * dt),
  );

  // Player angle (PC: toward mouse, Mobile: movement dir or last dir)
  if (!isMobile) {
    const cam = state.camera;
    const mx = mouse.x + cam.x;
    const my = mouse.y + cam.y;
    p.angle = Math.atan2(my - p.y, mx - p.x);
  } else if (Math.hypot(dx, dy) > 0.05) {
    p.angle = Math.atan2(dy, dx);
  }

  // Shooting
  p.shootCooldown -= dt;
  const shooting = isMobile ? fireBtnActive : mouse.shooting;
  if (shooting && p.shootCooldown <= 0) {
    fireBullet(p.x, p.y, p.angle, false);
    p.shootCooldown = 0.22;
  }

  // Zone logic
  z.shrinkTimer -= dt;
  if (z.shrinkTimer <= 0 && !z.shrinking) {
    z.shrinking = true;
    z.shrinkProgress = 0;
    const newR = Math.max(
      120,
      z.r * (1 - ZONE_SHRINK_AMOUNT) - state.wave * 10,
    );
    z.targetR = newR;
    z.shrinkTimer = ZONE_SHRINK_INTERVAL;
  }
  if (z.shrinking) {
    z.shrinkProgress = Math.min(1, z.shrinkProgress + dt * 0.4);
    z.r = z.r + (z.targetR - z.r) * dt * 0.4;
    if (z.shrinkProgress >= 1) z.shrinking = false;
  }
  zoneTimeEl.textContent = Math.max(0, Math.ceil(z.shrinkTimer));

  // Zone damage
  const distToCenter = Math.hypot(p.x - z.cx, p.y - z.cy);
  if (distToCenter > z.r) {
    p.hp -= ZONE_DAMAGE * dt;
    if (Math.random() < dt * 3) spawnParticles(p.x, p.y, "#4488ff", 2, 60);
  }

  // Wave progression
  state.spawnTimer -= dt;
  if (state.spawnTimer <= 0 && state.enemies.length < state.maxEnemies) {
    spawnEnemy();
    state.spawnTimer = state.spawnInterval;
  }

  state.waveTimer += dt;
  if (state.waveTimer > 25 + state.wave * 5) {
    state.wave++;
    state.waveTimer = 0;
    state.maxEnemies = Math.min(20, 6 + state.wave * 2);
    state.spawnInterval = Math.max(0.8, 2.5 - state.wave * 0.15);
    waveNumEl.textContent = state.wave;
    spawnEnemies(state.wave + 2);
    addFloatingText(p.x, p.y - 40, `WAVE ${state.wave}`, C.amber);
  }

  // Update enemies
  for (let i = state.enemies.length - 1; i >= 0; i--) {
    const e = state.enemies[i];
    const ex = p.x - e.x,
      ey = p.y - e.y;
    const edist = Math.hypot(ex, ey);
    if (edist > 0) {
      e.x += (ex / edist) * e.speed * dt;
      e.y += (ey / edist) * e.speed * dt;
      e.angle = Math.atan2(ey, ex);
    }

    // Enemy shoots
    e.shootCooldown -= dt;
    if (e.shootCooldown <= 0 && edist < 500) {
      fireBullet(e.x, e.y, e.angle, true);
      e.shootCooldown = e.shootInterval;
    }

    // Enemy hits player
    if (edist < p.radius + e.radius) {
      p.hp -= 20 * dt;
      spawnParticles(p.x, p.y, C.crimson, 1, 40);
    }

    // Enemy out of zone — slow damage
    const eDist = Math.hypot(e.x - z.cx, e.y - z.cy);
    if (eDist > z.r) e.hp -= 5 * dt;

    if (e.hp <= 0) {
      spawnParticles(e.x, e.y, C.crimson, 12, 120);
      addFloatingText(e.x, e.y - 20, "+1 KILL", C.crimson);
      state.enemies.splice(i, 1);
      state.kills++;
      killCountEl.textContent = state.kills;
    }
  }

  // Update player bullets
  for (let i = state.bullets.length - 1; i >= 0; i--) {
    const b = state.bullets[i];
    b.x += b.vx * dt;
    b.y += b.vy * dt;
    b.life -= dt;
    if (b.life <= 0 || b.x < 0 || b.x > WORLD_W || b.y < 0 || b.y > WORLD_H) {
      state.bullets.splice(i, 1);
      continue;
    }
    for (let j = state.enemies.length - 1; j >= 0; j--) {
      const e = state.enemies[j];
      if (Math.hypot(b.x - e.x, b.y - e.y) < BULLET_RADIUS + e.radius) {
        e.hp -= BULLET_DAMAGE;
        spawnParticles(b.x, b.y, C.amber, 5, 80);
        state.bullets.splice(i, 1);
        break;
      }
    }
  }

  // Update enemy bullets
  for (let i = state.enemyBullets.length - 1; i >= 0; i--) {
    const b = state.enemyBullets[i];
    b.x += b.vx * dt;
    b.y += b.vy * dt;
    b.life -= dt;
    if (b.life <= 0 || b.x < 0 || b.x > WORLD_W || b.y < 0 || b.y > WORLD_H) {
      state.enemyBullets.splice(i, 1);
      continue;
    }
    if (Math.hypot(b.x - p.x, b.y - p.y) < BULLET_RADIUS + p.radius) {
      p.hp -= 12;
      spawnParticles(b.x, b.y, C.crimson, 5, 70);
      state.enemyBullets.splice(i, 1);
    }
  }

  // Update particles
  for (let i = particles.length - 1; i >= 0; i--) {
    const pt = particles[i];
    pt.x += pt.vx * dt;
    pt.y += pt.vy * dt;
    pt.vy += 40 * dt;
    pt.life -= dt;
    if (pt.life <= 0) particles.splice(i, 1);
  }

  // Update floating texts
  for (let i = floatingTexts.length - 1; i >= 0; i--) {
    const ft = floatingTexts[i];
    ft.y += ft.vy * dt;
    ft.life -= dt;
    if (ft.life <= 0) floatingTexts.splice(i, 1);
  }

  // Update HUD health
  p.hp = Math.max(0, Math.min(p.maxHp, p.hp));
  const hpPct = p.hp / p.maxHp;
  healthBar.style.width = hpPct * 100 + "%";
  healthBar.style.background =
    hpPct > 0.5
      ? `linear-gradient(90deg, #3a7a2a, #5db84a)`
      : hpPct > 0.25
        ? `linear-gradient(90deg, #c87010, #e89030)`
        : `linear-gradient(90deg, #8c1a0e, #c03010)`;
  healthText.textContent = Math.ceil(p.hp);

  // Camera
  state.camera = computeCamera();

  // Death check
  if (p.hp <= 0) {
    endGame(false);
  }
}

function fireBullet(x, y, angle, isEnemy) {
  const b = {
    x,
    y,
    vx: Math.cos(angle) * BULLET_SPEED,
    vy: Math.sin(angle) * BULLET_SPEED,
    life: isEnemy ? 1.8 : 2.2,
    r: BULLET_RADIUS,
  };
  if (isEnemy) state.enemyBullets.push(b);
  else state.bullets.push(b);
}

// ── DRAW ──────────────────────────────────────────────────────
function draw() {
  const cam = state.camera;
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Background ground
  ctx.fillStyle = C.ground;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  ctx.save();
  ctx.translate(-cam.x, -cam.y);

  // Ground texture grid
  ctx.strokeStyle = C.ground2;
  ctx.lineWidth = 1;
  const gridSize = 80;
  const startX = Math.floor(cam.x / gridSize) * gridSize;
  const startY = Math.floor(cam.y / gridSize) * gridSize;
  for (let gx = startX; gx < cam.x + canvas.width + gridSize; gx += gridSize) {
    ctx.beginPath();
    ctx.moveTo(gx, cam.y);
    ctx.lineTo(gx, cam.y + canvas.height);
    ctx.stroke();
  }
  for (let gy = startY; gy < cam.y + canvas.height + gridSize; gy += gridSize) {
    ctx.beginPath();
    ctx.moveTo(cam.x, gy);
    ctx.lineTo(cam.x + canvas.width, gy);
    ctx.stroke();
  }

  // World border
  ctx.strokeStyle = C.amber;
  ctx.lineWidth = 4;
  ctx.strokeRect(2, 2, WORLD_W - 4, WORLD_H - 4);

  // Safe zone (blue zone fill)
  const z = state.zone;
  ctx.save();
  ctx.beginPath();
  ctx.rect(0, 0, WORLD_W, WORLD_H);
  ctx.arc(z.cx, z.cy, z.r, 0, Math.PI * 2, true);
  ctx.fillStyle = "rgba(10,30,120,0.35)";
  ctx.fill();
  ctx.restore();

  // Zone border
  ctx.beginPath();
  ctx.arc(z.cx, z.cy, z.r, 0, Math.PI * 2);
  ctx.strokeStyle = C.blueLine;
  ctx.lineWidth = 3;
  ctx.shadowColor = "#5599ff";
  ctx.shadowBlur = 14;
  ctx.stroke();
  ctx.shadowBlur = 0;

  // Trees
  trees.forEach((t) => {
    if (!isVisible(t.x, t.y, t.r * 2, cam)) return;
    ctx.beginPath();
    ctx.arc(t.x, t.y, t.r, 0, Math.PI * 2);
    ctx.fillStyle = t.shade ? "#2a5a1a" : "#1e4512";
    ctx.fill();
    ctx.beginPath();
    ctx.arc(t.x - t.r * 0.2, t.y - t.r * 0.2, t.r * 0.6, 0, Math.PI * 2);
    ctx.fillStyle = t.shade ? "#3a7a2a" : "#2e641e";
    ctx.fill();
  });

  // Rocks
  rocks.forEach((r) => {
    if (!isVisible(r.x, r.y, r.w * 2, cam)) return;
    ctx.save();
    ctx.translate(r.x, r.y);
    ctx.rotate(r.angle);
    ctx.beginPath();
    ctx.ellipse(0, 0, r.w, r.h, 0, 0, Math.PI * 2);
    ctx.fillStyle = "#3a2a20";
    ctx.fill();
    ctx.strokeStyle = "#5a4030";
    ctx.lineWidth = 1.5;
    ctx.stroke();
    ctx.restore();
  });

  // Enemy bullets
  state.enemyBullets.forEach((b) => {
    ctx.beginPath();
    ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
    ctx.fillStyle = C.crimson;
    ctx.shadowColor = C.crimson;
    ctx.shadowBlur = 8;
    ctx.fill();
    ctx.shadowBlur = 0;
  });

  // Player bullets
  state.bullets.forEach((b) => {
    ctx.beginPath();
    ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
    ctx.fillStyle = C.amber;
    ctx.shadowColor = C.amber;
    ctx.shadowBlur = 10;
    ctx.fill();
    ctx.shadowBlur = 0;
  });

  // Enemies
  state.enemies.forEach((e) => {
    if (!isVisible(e.x, e.y, e.radius * 3, cam)) return;
    drawEnemy(e);
  });

  // Player
  drawPlayer(state.player);

  // Particles
  particles.forEach((pt) => {
    const alpha = pt.life / pt.maxLife;
    ctx.globalAlpha = alpha;
    ctx.beginPath();
    ctx.arc(pt.x, pt.y, pt.r * alpha, 0, Math.PI * 2);
    ctx.fillStyle = pt.color;
    ctx.fill();
    ctx.globalAlpha = 1;
  });

  // Floating texts
  floatingTexts.forEach((ft) => {
    ctx.globalAlpha = Math.min(1, ft.life);
    ctx.font = 'bold 16px "Share Tech Mono", monospace';
    ctx.fillStyle = ft.color;
    ctx.shadowColor = "#000";
    ctx.shadowBlur = 5;
    ctx.fillText(ft.text, ft.x - ctx.measureText(ft.text).width / 2, ft.y);
    ctx.shadowBlur = 0;
    ctx.globalAlpha = 1;
  });

  ctx.restore();

  // Minimap
  drawMinimap();
}

function drawPlayer(p) {
  ctx.save();
  ctx.translate(p.x, p.y);

  // Shadow
  ctx.beginPath();
  ctx.ellipse(4, 6, p.radius * 0.9, p.radius * 0.5, 0, 0, Math.PI * 2);
  ctx.fillStyle = "rgba(0,0,0,0.4)";
  ctx.fill();

  // Body
  ctx.rotate(p.angle);
  ctx.beginPath();
  ctx.arc(0, 0, p.radius, 0, Math.PI * 2);
  ctx.fillStyle = C.green;
  ctx.fill();
  ctx.strokeStyle = C.greenLt;
  ctx.lineWidth = 2.5;
  ctx.stroke();

  // Head stripe / detail
  ctx.beginPath();
  ctx.arc(0, 0, p.radius * 0.55, 0, Math.PI * 2);
  ctx.fillStyle = C.greenLt;
  ctx.fill();

  // Weapon barrel
  ctx.beginPath();
  ctx.rect(p.radius * 0.4, -3, p.radius * 0.85, 6);
  ctx.fillStyle = "#222";
  ctx.fill();

  ctx.restore();

  // HP bar above player
  const cam = state.camera;
  const sx = p.x - cam.x;
  const sy = p.y - cam.y;
  const bw = p.radius * 2.5;
  ctx.fillStyle = "rgba(0,0,0,0.5)";
  ctx.fillRect(sx - bw / 2, sy - p.radius - 10, bw, 5);
  ctx.fillStyle = C.greenLt;
  ctx.fillRect(sx - bw / 2, sy - p.radius - 10, bw * (p.hp / p.maxHp), 5);
}

function drawEnemy(e) {
  ctx.save();
  ctx.translate(e.x, e.y);

  // Shadow
  ctx.beginPath();
  ctx.ellipse(3, 5, e.radius * 0.85, e.radius * 0.45, 0, 0, Math.PI * 2);
  ctx.fillStyle = "rgba(0,0,0,0.4)";
  ctx.fill();

  ctx.rotate(e.angle);
  // Body
  ctx.beginPath();
  ctx.arc(0, 0, e.radius, 0, Math.PI * 2);
  ctx.fillStyle = "#7a0808";
  ctx.fill();
  ctx.strokeStyle = C.crimson;
  ctx.lineWidth = 2;
  ctx.stroke();

  // Head
  ctx.beginPath();
  ctx.arc(0, 0, e.radius * 0.5, 0, Math.PI * 2);
  ctx.fillStyle = "#c01010";
  ctx.fill();

  // Weapon
  ctx.beginPath();
  ctx.rect(e.radius * 0.3, -2.5, e.radius * 0.8, 5);
  ctx.fillStyle = "#111";
  ctx.fill();

  ctx.restore();

  // HP bar
  const cam = state.camera;
  const sx = e.x - cam.x;
  const sy = e.y - cam.y;
  const bw = e.radius * 2.2;
  ctx.fillStyle = "rgba(0,0,0,0.5)";
  ctx.fillRect(sx - bw / 2, sy - e.radius - 9, bw, 4);
  ctx.fillStyle = C.crimson;
  ctx.fillRect(sx - bw / 2, sy - e.radius - 9, bw * (e.hp / e.maxHp), 4);
}

function drawMinimap() {
  const mm = { x: canvas.width - 154, y: 54, w: 140, h: 140 };
  const scale = mm.w / WORLD_W;

  ctx.save();
  ctx.globalAlpha = 0.82;
  ctx.fillStyle = "rgba(15,4,2,0.8)";
  ctx.strokeStyle = C.amber;
  ctx.lineWidth = 1.5;
  ctx.fillRect(mm.x, mm.y, mm.w, mm.h);
  ctx.strokeRect(mm.x, mm.y, mm.w, mm.h);

  // Zone
  const z = state.zone;
  ctx.beginPath();
  ctx.arc(
    mm.x + z.cx * scale,
    mm.y + z.cy * scale,
    z.r * scale,
    0,
    Math.PI * 2,
  );
  ctx.strokeStyle = C.blueLine;
  ctx.lineWidth = 1.5;
  ctx.stroke();

  // Enemies
  state.enemies.forEach((e) => {
    ctx.beginPath();
    ctx.arc(mm.x + e.x * scale, mm.y + e.y * scale, 3, 0, Math.PI * 2);
    ctx.fillStyle = C.crimson;
    ctx.fill();
  });

  // Player
  const p = state.player;
  ctx.beginPath();
  ctx.arc(mm.x + p.x * scale, mm.y + p.y * scale, 4, 0, Math.PI * 2);
  ctx.fillStyle = C.greenLt;
  ctx.fill();

  // Viewport rect
  const cam = state.camera;
  ctx.strokeStyle = "rgba(255,220,140,0.4)";
  ctx.lineWidth = 1;
  ctx.strokeRect(
    mm.x + cam.x * scale,
    mm.y + cam.y * scale,
    canvas.width * scale,
    canvas.height * scale,
  );

  ctx.globalAlpha = 1;
  ctx.restore();
}

function isVisible(x, y, r, cam) {
  return (
    x + r > cam.x &&
    x - r < cam.x + canvas.width &&
    y + r > cam.y &&
    y - r < cam.y + canvas.height
  );
}

// ── GAME LOOP ─────────────────────────────────────────────────
function loop(ts) {
  const dt = Math.min((ts - lastTime) / 1000, 0.05);
  lastTime = ts;
  update(dt);
  draw();
  animId = requestAnimationFrame(loop);
}

// ── GAME END ──────────────────────────────────────────────────
function endGame(won) {
  state.running = false;
  cancelAnimationFrame(animId);
  hud.classList.add("hidden");
  mobileCtrl.classList.add("hidden");

  goKillsEl.textContent = state.kills;
  goWaveEl.textContent = state.wave;

  if (won) {
    goTitleEl.textContent = "VICTORY!";
    goMsgEl.textContent =
      "The Mising people have defended the sacred land.\nThe Mipaks are vanquished!";
  } else {
    goTitleEl.textContent = "FALLEN";
    goMsgEl.textContent =
      "Your spirit has faded.\nBut the land remembers your sacrifice.";
  }

  gameoverScreen.classList.remove("hidden");
}

// ── START GAME ────────────────────────────────────────────────
function startGame() {
  resizeCanvas();
  isMobile = detectMobile();

  titleScreen.classList.add("hidden");
  gameoverScreen.classList.add("hidden");
  hud.classList.remove("hidden");

  if (isMobile) {
    mobileCtrl.classList.remove("hidden");
  }

  initGame();
  waveNumEl.textContent = state.wave;
  lastTime = performance.now();
  animId = requestAnimationFrame(loop);
}

// ── INPUT — KEYBOARD ──────────────────────────────────────────
window.addEventListener("keydown", (e) => {
  keys[e.key.toLowerCase()] = true;
});
window.addEventListener("keyup", (e) => {
  keys[e.key.toLowerCase()] = false;
});

// ── INPUT — MOUSE ─────────────────────────────────────────────
canvas.addEventListener("mousemove", (e) => {
  mouse.x = e.clientX;
  mouse.y = e.clientY;
});
canvas.addEventListener("mousedown", (e) => {
  if (e.button === 0) mouse.shooting = true;
});
canvas.addEventListener("mouseup", (e) => {
  if (e.button === 0) mouse.shooting = false;
});
canvas.addEventListener("contextmenu", (e) => e.preventDefault());

// ── INPUT — JOYSTICK ──────────────────────────────────────────
const JOYSTICK_MAX = 42;

function joystickStart(e) {
  if (joystick.active) return;
  joystick.active = true;
  joystick.touchId = e.changedTouches[0].identifier;
  updateJoystick(e.changedTouches[0]);
}

function joystickMove(e) {
  for (const t of e.changedTouches) {
    if (t.identifier === joystick.touchId) {
      updateJoystick(t);
      break;
    }
  }
}

function joystickEnd(e) {
  for (const t of e.changedTouches) {
    if (t.identifier === joystick.touchId) {
      joystick.active = false;
      joystick.dx = 0;
      joystick.dy = 0;
      joystick.touchId = null;
      joystickKnob.style.transform = "translate(-50%, -50%)";
      break;
    }
  }
}

function updateJoystick(touch) {
  const rect = joystickBase.getBoundingClientRect();
  const cx = rect.left + rect.width / 2;
  const cy = rect.top + rect.height / 2;
  let ox = touch.clientX - cx;
  let oy = touch.clientY - cy;
  const dist = Math.hypot(ox, oy);
  if (dist > JOYSTICK_MAX) {
    ox = (ox / dist) * JOYSTICK_MAX;
    oy = (oy / dist) * JOYSTICK_MAX;
  }
  joystick.dx = ox / JOYSTICK_MAX;
  joystick.dy = oy / JOYSTICK_MAX;
  joystickKnob.style.transform = `translate(calc(-50% + ${ox}px), calc(-50% + ${oy}px))`;
}

joystickBase.addEventListener("touchstart", joystickStart, { passive: true });
joystickBase.addEventListener("touchmove", joystickMove, { passive: true });
joystickBase.addEventListener("touchend", joystickEnd, { passive: true });
joystickBase.addEventListener("touchcancel", joystickEnd, { passive: true });

// ── INPUT — FIRE BUTTON ───────────────────────────────────────
const fireBtn = document.getElementById("fire-btn");
fireBtn.addEventListener(
  "touchstart",
  () => {
    fireBtnActive = true;
  },
  { passive: true },
);
fireBtn.addEventListener(
  "touchend",
  () => {
    fireBtnActive = false;
  },
  { passive: true },
);
fireBtn.addEventListener(
  "touchcancel",
  () => {
    fireBtnActive = false;
  },
  { passive: true },
);

// ── BUTTONS ───────────────────────────────────────────────────
document.getElementById("start-btn").addEventListener("click", startGame);
document.getElementById("start-btn").addEventListener("touchend", (e) => {
  e.preventDefault();
  startGame();
});

document.getElementById("restart-btn").addEventListener("click", startGame);
document.getElementById("restart-btn").addEventListener("touchend", (e) => {
  e.preventDefault();
  startGame();
});
