const express = require("express");

const { Categoria, Servicio } = require("../models");
const asyncHandler = require("../utils/asyncHandler");

const router = express.Router();

router.get(
  "/categorias",
  asyncHandler(async (req, res) => {
    const rows = await Categoria.findAll({ order: [["nombre", "ASC"]] });
    res.json(rows);
  })
);

router.get(
  "/servicios",
  asyncHandler(async (req, res) => {
    const { categoria_id: categoriaId } = req.query;
    const where = {};

    if (categoriaId !== undefined) {
      const parsedId = Number(categoriaId);
      if (Number.isFinite(parsedId)) {
        where.categoria_id = parsedId;
      }
    }

    const rows = await Servicio.findAll({
      where,
      include: [{ model: Categoria, attributes: ["id", "nombre"] }],
      order: [["id", "ASC"]],
    });

    res.json(rows);
  })
);

module.exports = router;