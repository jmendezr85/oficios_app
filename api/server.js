// api/server.js
const path = require("path");
const express = require("express");
const cors = require("cors");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

// Carga .env desde la raíz del proyecto
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

// Modelos + conexión Sequelize (usa tu DB de .env)
const { sequelize, Usuario, Categoria, Servicio, Valoracion } = require("./models");

const app = express();
app.use(express.json());

const SALT_ROUNDS = (() => {
  const envRounds = Number(process.env.BCRYPT_ROUNDS || process.env.BCRYPT_SALT_ROUNDS);
  if (Number.isInteger(envRounds) && envRounds >= 4 && envRounds <= 15) {
    return envRounds;
  }
  return 12;
})();

const ALLOWED_SIGNUP_ROLES = new Set(["cliente", "proveedor"]);

const normalizeEmail = (value = "") => value.trim().toLowerCase();
const normalizePhone = (value) => {
  if (value === undefined || value === null) return null;
  const trimmed = String(value).trim();
  return trimmed.length ? trimmed : null;
};
// --- CORS con allowlist desde .env ---
// En .env puedes poner:
// CORS_ORIGIN=http://localhost:3000
// o múltiples: CORS_ORIGIN=http://localhost:5173,http://localhost:3000
const allowList = (process.env.CORS_ORIGIN || "*")
  .split(",")
  .map(s => s.trim())
  .filter(Boolean);

app.use(
  cors({
    origin: allowList.includes("*") ? true : allowList,
    credentials: true,
  })
);

// --- Config básica ---
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "dev-secret-change-me";

// Utilidad sencilla para manejar async/await en rutas
const ah = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

// --- Healthcheck ---
app.get("/health", (req, res) => {
  res.json({ ok: true, ts: new Date().toISOString() });
});

// --- Categorías ---
app.get(
  "/categorias",
  ah(async (req, res) => {
    const rows = await Categoria.findAll({ order: [["nombre", "ASC"]] });
    res.json(rows);
  })
);

// --- Servicios (opcional ?categoria_id=) ---
app.get(
  "/servicios",
  ah(async (req, res) => {
    const { categoria_id } = req.query;
    const where = {};
    if (categoria_id) where.categoria_id = Number(categoria_id);

    const rows = await Servicio.findAll({
      where,
      include: [{ model: Categoria, attributes: ["id", "nombre"] }],
      order: [["id", "ASC"]],
    });
    res.json(rows);
  })
);

// --- Valoraciones de un servicio ---
app.get(
  "/servicios/:id/valoraciones",
  ah(async (req, res) => {
    const { id } = req.params;
    const rows = await Valoracion.findAll({
      where: { servicio_id: Number(id) },
      include: [{ model: Usuario, attributes: ["id", "nombre", "correo"] }],
      order: [["id", "DESC"]],
      limit: 50,
    });
    res.json(rows);
  })
);

// --- Crear valoración ---
app.post(
  "/valoraciones",
  ah(async (req, res) => {
    const { usuario_id, servicio_id, puntuacion, comentario } = req.body;

    if (!usuario_id || !servicio_id || !puntuacion) {
      return res
        .status(400)
        .json({ error: "usuario_id, servicio_id y puntuacion son obligatorios" });
    }
    if (Number(puntuacion) < 1 || Number(puntuacion) > 5) {
      return res.status(400).json({ error: "puntuacion debe estar entre 1 y 5" });
    }

    const val = await Valoracion.create({
      usuario_id,
      servicio_id,
      puntuacion,
      comentario,
    });
    res.status(201).json(val);
  })
);


// --- Registro de usuarios ---
app.post(
  "/auth/register",
  ah(async (req, res) => {
    const { nombre, correo, password, telefono, rol } = req.body || {};

    const cleanNombre = typeof nombre === "string" ? nombre.trim() : "";
    const cleanCorreo = normalizeEmail(typeof correo === "string" ? correo : "");
    const cleanPassword = typeof password === "string" ? password : "";
    const cleanTelefono = normalizePhone(telefono);
    const rawRol = typeof rol === "string" ? rol.trim().toLowerCase() : "cliente";

    if (!cleanNombre || !cleanCorreo || !cleanPassword) {
      return res
        .status(400)
        .json({ error: "nombre, correo y password son requeridos" });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(cleanCorreo)) {
      return res.status(400).json({ error: "correo inválido" });
    }

    if (cleanPassword.length < 8) {
      return res
        .status(400)
        .json({ error: "password debe tener al menos 8 caracteres" });
    }

    if (!ALLOWED_SIGNUP_ROLES.has(rawRol)) {
      return res.status(400).json({ error: "rol inválido" });
    }

    const existing = await Usuario.findOne({ where: { correo: cleanCorreo } });
    if (existing) {
      return res.status(409).json({ error: "correo ya registrado" });
    }

    const password_hash = await bcrypt.hash(cleanPassword, SALT_ROUNDS);
    const user = await Usuario.create({
      nombre: cleanNombre,
      correo: cleanCorreo,
      password_hash,
      telefono: cleanTelefono,
      rol: rawRol,
    });

    const token = jwt.sign({ sub: user.id, rol: user.rol }, JWT_SECRET, {
      expiresIn: "8h",
    });

    res.status(201).json({
      token,
      user: {
        id: user.id,
        nombre: user.nombre,
        correo: user.correo,
        telefono: user.telefono,
        rol: user.rol,
      },
    });
  })
);

// --- Login (requiere que password_hash sea un bcrypt válido en la DB) ---
app.post(
  "/auth/login",
  ah(async (req, res) => {
    const { correo, password } = req.body || {};
    const cleanCorreo = normalizeEmail(typeof correo === "string" ? correo : "");
    const cleanPassword = typeof password === "string" ? password : "";

    if (!cleanCorreo || !cleanPassword) {
      return res.status(400).json({ error: "correo y password son requeridos" });
    }

     const user = await Usuario.findOne({ where: { correo: cleanCorreo } });
    if (!user) return res.status(401).json({ error: "credenciales inválidas" });

    const ok = await bcrypt.compare(cleanPassword, user.password_hash);
    if (!ok) return res.status(401).json({ error: "credenciales inválidas" });

    const token = jwt.sign({ sub: user.id, rol: user.rol }, JWT_SECRET, { expiresIn: "8h" });
    res.json({
      token,
      user: { id: user.id, nombre: user.nombre, correo: user.correo, rol: user.rol },
    });
  })
);

// --- Manejo de errores básico ---
app.use((err, req, res, _next) => {
  console.error("[ERROR]", err);
  res.status(500).json({ error: "Error interno" });
});

// --- Arranque ---
(async () => {
  await sequelize.authenticate();
  console.log("[OK] DB autenticada");
app.listen(PORT, '0.0.0.0', () => console.log(`[OK] API escuchando en http://localhost:${PORT}`));
})();
