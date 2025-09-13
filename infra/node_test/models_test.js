// infra/node_test/models_test.js
const { sequelize, Usuario, Categoria, Servicio, Valoracion } = require("./models");

(async () => {
  try {
    await sequelize.authenticate();
    console.log("[OK] Sequelize models: autenticado");

    const [catCount, usrCount, srvCount] = await Promise.all([
      Categoria.count(),
      Usuario.count(),
      Servicio.count(),
    ]);
    console.log("[OK] counts ->", { categorias: catCount, usuarios: usrCount, servicios: srvCount });

    // Crear una valoración de ejemplo si hay datos
    const user = await Usuario.findOne({ order: [["id", "ASC"]] });
    const srv = await Servicio.findOne({ order: [["id", "ASC"]] });
    if (user && srv) {
      const val = await Valoracion.create({
        usuario_id: user.id,
        servicio_id: srv.id,
        puntuacion: 5,
        comentario: "Excelente servicio",
      });
      console.log("[OK] Valoracion creada id=", val.id);
    } else {
      console.log("[INFO] No hay datos para crear valoracion de ejemplo");
    }

    // Consultar valoraciones con include
    const vals = await Valoracion.findAll({
      include: [
        { model: Usuario, attributes: ["id", "nombre", "correo"] },
        { model: Servicio, attributes: ["id", "nombre"] },
      ],
      limit: 3,
      order: [["id", "DESC"]],
    });
    console.log(
      "[OK] Valoraciones (hasta 3):",
      vals.map((v) => ({
        id: v.id,
        puntuacion: v.puntuacion,
        usuario: v.Usuario?.correo,
        servicio: v.Servicio?.nombre,
      }))
    );

    await sequelize.close();
    console.log("[DONE] Models test ok");
  } catch (e) {
    console.error("[ERROR] Models test failed:", e);
    process.exit(1);
  }
})();
