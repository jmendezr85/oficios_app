const { sequelize } = require("./db");

const Usuario = require("./models/Usuario")(sequelize);
const Categoria = require("./models/Categoria")(sequelize);
const Servicio = require("./models/Servicio")(sequelize);
const Valoracion = require("./models/Valoracion")(sequelize);

// Asociaciones
Categoria.hasMany(Servicio, { foreignKey: "categoria_id" });
Servicio.belongsTo(Categoria, { foreignKey: "categoria_id" });

Usuario.hasMany(Valoracion, { foreignKey: "usuario_id" });
Servicio.hasMany(Valoracion, { foreignKey: "servicio_id" });
Valoracion.belongsTo(Usuario, { foreignKey: "usuario_id" });
Valoracion.belongsTo(Servicio, { foreignKey: "servicio_id" });

module.exports = { sequelize, Usuario, Categoria, Servicio, Valoracion };
