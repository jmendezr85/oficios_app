const express = require("express");

const ApiError = require("../errors/ApiError");
const { Valoracion, Usuario } = require("../models");
const asyncHandler = require("../utils/asyncHandler");
const { sanitizeString } = require("../utils/formatters");

const router = express.Router();

router.get(
  "/servicios/:id/valoraciones",
  asyncHandler(async (req, res) => {
    const servicioId = Number(req.params.id);
    if (!Number.isInteger(servicioId)) {
      throw new ApiError(400, "servicio_id inválido");
    }

    const rows = await Valoracion.findAll({
      where: { servicio_id: servicioId },
      include: [{ model: Usuario, attributes: ["id", "nombre", "correo"] }],
      order: [["id", "DESC"]],
      limit: 50,
    });

    res.json(rows);
  })
);

router.post(
  "/valoraciones",
  asyncHandler(async (req, res) => {
    const { usuario_id: usuarioId, servicio_id: servicioId, puntuacion, comentario } = req.body || {};

    const parsedUsuarioId = Number(usuarioId);
    const parsedServicioId = Number(servicioId);
    const parsedPuntuacion = Number(puntuacion);

    if (!Number.isInteger(parsedUsuarioId) || !Number.isInteger(parsedServicioId)) {
      throw new ApiError(400, "usuario_id y servicio_id deben ser números enteros");
    }

    if (!Number.isInteger(parsedPuntuacion) || parsedPuntuacion < 1 || parsedPuntuacion > 5) {
      throw new ApiError(400, "puntuacion debe estar entre 1 y 5");
    }

    const valoracion = await Valoracion.create({
      usuario_id: parsedUsuarioId,
      servicio_id: parsedServicioId,
      puntuacion: parsedPuntuacion,
      comentario: sanitizeString(comentario) || null,
    });

    res.status(201).json(valoracion);
  })
);

module.exports = router;