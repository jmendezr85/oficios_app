const { Sequelize } = require("sequelize");
const config = require("./config");

const { host, port, user, pass, name, logging } = config.db;

const sequelize = new Sequelize(name, user, pass, {
  host,
  port,
  dialect: "mysql",
  logging: Boolean(logging) && console.log,
  define: { freezeTableName: true },
  pool: { max: 5, min: 0, acquire: 20000, idle: 5000 },
});

module.exports = { sequelize };