const { DataTypes, Model } = require("sequelize");

module.exports = (sequelize) => {
  class Usuario extends Model {}
  Usuario.init(
    {
      id: { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
      nombre: { type: DataTypes.STRING(120), allowNull: false },
      correo: { type: DataTypes.STRING(160), allowNull: false, unique: true },
      password_hash: { type: DataTypes.STRING(255), allowNull: false },
      telefono: { type: DataTypes.STRING(30) },
      rol: {
        type: DataTypes.ENUM("cliente", "proveedor", "admin"),
        allowNull: false,
        defaultValue: "cliente",
      },
      creado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
      actualizado_en: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
    },
    {
      sequelize,
      modelName: "Usuario",
      tableName: "usuarios",
      timestamps: true,
      createdAt: "creado_en",
      updatedAt: "actualizado_en",
    }
  );
  return Usuario;
};
