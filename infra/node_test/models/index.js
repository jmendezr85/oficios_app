const { sequelize } = require("../db");
const Usuario = require("./Usuario")(sequelize);
const Categoria = require("./Categoria")(sequelize);
const Servicio = require("./Servicio")(sequelize);
const Valoracion = require("./Valoracion")(sequelize);

// Relaciones
Categoria.hasMany(Servicio, { foreignKey: "categoria_id" });
Servicio.belongsTo(Categoria, { foreignKey: "categoria_id" });

Usuario.hasMany(Valoracion, { foreignKey: "usuario_id" });
Servicio.hasMany(Valoracion, { foreignKey: "servicio_id" });
Valoracion.belongsTo(Usuario, { foreignKey: "usuario_id" });
Valoracion.belongsTo(Servicio, { foreignKey: "servicio_id" });

module.exports = { sequelize, Usuario, Categoria, Servicio, Valoracion };
