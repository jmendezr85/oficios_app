const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const config = require("../config");
const ApiError = require("../errors/ApiError");
const { Usuario } = require("../models");
const asyncHandler = require("../utils/asyncHandler");
const {
  sanitizeString,
  normalizeEmail,
  normalizePhone,
  isValidEmail,
  serializeUser,
} = require("../utils/formatters");

const router = express.Router();

const allowedRoles = new Set(config.auth.allowedRoles);

const buildTokenOptions = () => {
  const hours = Number(config.auth.tokenTtlHours);
  if (Number.isFinite(hours) && hours > 0) {
    return { expiresIn: `${hours}h` };
  }
  return {};
};

router.post(
  "/register",
  asyncHandler(async (req, res) => {
    const { nombre, correo, password, telefono, rol } = req.body || {};

    const cleanNombre = sanitizeString(nombre);
    const cleanCorreo = normalizeEmail(correo);
    const cleanPassword = typeof password === "string" ? password : "";
    const cleanTelefono = normalizePhone(telefono);
    const requestedRole = sanitizeString(rol).toLowerCase() || "cliente";

    if (!cleanNombre || !cleanCorreo || !cleanPassword) {
      throw new ApiError(400, "nombre, correo y password son requeridos");
    }

    if (!isValidEmail(cleanCorreo)) {
      throw new ApiError(400, "correo inválido");
    }

    if (cleanPassword.length < 8) {
      throw new ApiError(400, "password debe tener al menos 8 caracteres");
    }

    if (!allowedRoles.has(requestedRole)) {
      throw new ApiError(400, "rol inválido");
    }

    const existing = await Usuario.findOne({ where: { correo: cleanCorreo } });
    if (existing) {
      throw new ApiError(409, "correo ya registrado");
    }

    const passwordHash = await bcrypt.hash(cleanPassword, config.bcryptRounds);
    const user = await Usuario.create({
      nombre: cleanNombre,
      correo: cleanCorreo,
      password_hash: passwordHash,
      telefono: cleanTelefono,
      rol: requestedRole,
    });

    const token = jwt.sign(
      { sub: user.id, rol: user.rol },
      config.jwtSecret,
      buildTokenOptions()
    );

    res.status(201).json({ token, user: serializeUser(user) });
  })
);

router.post(
  "/login",
  asyncHandler(async (req, res) => {
    const { correo, password } = req.body || {};
    const cleanCorreo = normalizeEmail(correo);
    const cleanPassword = typeof password === "string" ? password : "";

    if (!cleanCorreo || !cleanPassword) {
      throw new ApiError(400, "correo y password son requeridos");
    }

    const user = await Usuario.findOne({ where: { correo: cleanCorreo } });
    if (!user) {
      throw new ApiError(401, "credenciales inválidas");
    }

    const validPassword = await bcrypt.compare(cleanPassword, user.password_hash);
    if (!validPassword) {
      throw new ApiError(401, "credenciales inválidas");
    }

    const token = jwt.sign(
      { sub: user.id, rol: user.rol },
      config.jwtSecret,
      buildTokenOptions()
    );

    res.json({ token, user: serializeUser(user) });
  })
);

module.exports = router;