const express = require("express");

const authRoutes = require("./auth");
const catalogRoutes = require("./catalog");
const ratingsRoutes = require("./ratings");
const healthRoutes = require("./health");

const router = express.Router();

router.use(healthRoutes);
router.use("/auth", authRoutes);
router.use(catalogRoutes);
router.use(ratingsRoutes);

module.exports = router;