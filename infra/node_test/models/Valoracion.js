const { DataTypes, Model } = require("sequelize");

module.exports = (sequelize) => {
  class Valoracion extends Model {}
  Valoracion.init(
    {
      id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
      usuario_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
      servicio_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
      puntuacion: {
        type: DataTypes.TINYINT.UNSIGNED,
        allowNull: false,
        validate: { min: 1, max: 5 },
      },
      comentario: { type: DataTypes.STRING(500) },
      creado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
    },
    {
      sequelize,
      modelName: "Valoracion",
      tableName: "valoraciones",
      timestamps: false,
    }
  );
  return Valoracion;
};
