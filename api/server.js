const app = require("./app");
const config = require("./config");
const { sequelize } = require("./models");

async function start() {
  try {
    const missingDbConfig = [
      ["host", "DB_HOST"],
      ["user", "DB_USER"],
      ["name", "DB_NAME"],
    ]
      .filter(([key]) => !config.db[key])
      .map(([, envKey]) => envKey);

    if (missingDbConfig.length) {
      throw new Error(
        `Faltan variables de entorno para la base de datos: ${missingDbConfig.join(", ")}`
      );
    }

    await sequelize.authenticate();
    console.log("[OK] DB autenticada");

    if (config.db.sync) {
      await sequelize.sync();
      console.log("[OK] Modelos sincronizados");
    }

    if (!process.env.JWT_SECRET) {
      console.warn(
        "[WARN] JWT_SECRET no está definido. Usa un valor seguro en producción."
      );
    }

    const port = config.port;
    app.listen(port, "0.0.0.0", () => {
      console.log(`[OK] API escuchando en http://localhost:${port}`);
    });
  } catch (error) {
    console.error("[ERROR] No se pudo iniciar la API", error);
    process.exit(1);
  }
}

if (require.main === module) {
  start();
}

module.exports = { start };
