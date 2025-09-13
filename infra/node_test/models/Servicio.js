const { DataTypes, Model } = require("sequelize");

module.exports = (sequelize) => {
  class Servicio extends Model {}
  Servicio.init(
    {
      id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
      categoria_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
      nombre: { type: DataTypes.STRING(140), allowNull: false },
      descripcion: { type: DataTypes.TEXT },
      precio_base: { type: DataTypes.DECIMAL(12, 2), allowNull: false, defaultValue: 0 },
      activo: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
      creado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
      actualizado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
    },
    {
      sequelize,
      modelName: "Servicio",
      tableName: "servicios",
      timestamps: true,
      createdAt: "creado_en",
      updatedAt: "actualizado_en",
      indexes: [{ fields: ["categoria_id"] }, { fields: ["nombre"] }],
    }
  );
  return Servicio;
};
