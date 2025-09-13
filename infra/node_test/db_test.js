// infra/node_test/db_test.js
const path = require("path");
const { Sequelize } = require("sequelize");
require("dotenv").config({ path: path.join(__dirname, "..", "..", ".env") });

const {
  DB_HOST,
  DB_PORT = "3306",
  DB_USER,
  DB_PASS,
  DB_NAME,
} = process.env;


(async () => {
  try {
    const sequelize = new Sequelize(DB_NAME, DB_USER, DB_PASS, {
      host: DB_HOST,
      port: Number(DB_PORT),
      dialect: "mysql",
      logging: false,
      dialectOptions: {
        // Opcional: útil si hay latencias
        connectTimeout: 10000,
      },
    });

    console.log(`[INFO] Conectando como ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME} ...`);
    await sequelize.authenticate();
    console.log("[OK] Autenticado con Sequelize.");

    // Consultas directas (sin modelos), para verificar seed
    const [[identidad]] = await sequelize.query("SELECT DATABASE() AS db, CURRENT_USER() AS user;");
    console.log("[OK] IDENTIDAD ->", identidad);

    const [[{ categorias }]] = await sequelize.query("SELECT COUNT(*) AS categorias FROM categorias;");
    const [[{ usuarios }]]   = await sequelize.query("SELECT COUNT(*) AS usuarios   FROM usuarios;");
    const [[{ servicios }]]  = await sequelize.query("SELECT COUNT(*) AS servicios  FROM servicios;");
    console.log("[OK] categorias:", categorias);
    console.log("[OK] usuarios:", usuarios);
    console.log("[OK] servicios:", servicios);

    const [rows] = await sequelize.query(`
      SELECT s.id, s.nombre AS servicio, c.nombre AS categoria, s.precio_base
      FROM servicios s
      JOIN categorias c ON c.id = s.categoria_id
      ORDER BY s.id
      LIMIT 5
    `);
    console.log("[OK] Muestra de servicios (hasta 5):");
    rows.forEach(r => console.log("   ", r));

    await sequelize.close();
    console.log("[DONE] Test Node/Sequelize completado.");
  } catch (err) {
    console.error("[ERROR] Falló el test Node/Sequelize:", err);
    process.exit(1);
  }
})();
