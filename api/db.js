const path = require("path");
const { Sequelize } = require("sequelize");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const { DB_HOST, DB_PORT = "3306", DB_USER, DB_PASS, DB_NAME } = process.env;

const sequelize = new Sequelize(DB_NAME, DB_USER, DB_PASS, {
  host: DB_HOST,
  port: Number(DB_PORT),
  dialect: "mysql",
  logging: false,
  define: { freezeTableName: true },
  pool: { max: 5, min: 0, acquire: 20000, idle: 5000 },
});

module.exports = { sequelize };
