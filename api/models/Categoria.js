const { DataTypes, Model } = require("sequelize");

module.exports = (sequelize) => {
  class Categoria extends Model {}
  Categoria.init(
    {
      id: { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
      nombre: { type: DataTypes.STRING(80), allowNull: false, unique: true },
      creado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
    },
    {
      sequelize,
      modelName: "Categoria",
      tableName: "categorias",
      timestamps: false,
    }
  );
  return Categoria;
};
