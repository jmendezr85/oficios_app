const path = require("path");
const dotenv = require("dotenv");

dotenv.config({ path: path.join(__dirname, "..", ".env") });

const toNumber = (value, fallback) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const parseCorsOrigins = (value) => {
  if (!value || typeof value !== "string") {
    return ["*"];
  }
  const origins = value
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);
  return origins.length ? origins : ["*"];
};

const resolveBcryptRounds = () => {
  const candidates = [process.env.BCRYPT_ROUNDS, process.env.BCRYPT_SALT_ROUNDS];
  for (const candidate of candidates) {
    const parsed = Number(candidate);
    if (Number.isInteger(parsed) && parsed >= 4 && parsed <= 15) {
      return parsed;
    }
  }
  return 12;
};

const config = {
  env: process.env.NODE_ENV || "development",
  port: toNumber(process.env.PORT, 3000),
  jwtSecret: (process.env.JWT_SECRET || "dev-secret-change-me").trim(),
  bcryptRounds: resolveBcryptRounds(),
  cors: {
    origins: parseCorsOrigins(process.env.CORS_ORIGIN),
  },
  auth: {
    allowedRoles: ["cliente", "proveedor"],
    tokenTtlHours: toNumber(process.env.JWT_TTL_HOURS, 8),
  },
  db: {
    host: process.env.DB_HOST,
    port: toNumber(process.env.DB_PORT, 3306),
    user: process.env.DB_USER,
    pass: process.env.DB_PASS,
    name: process.env.DB_NAME,
    logging: process.env.DB_LOGGING === "true",
    sync: process.env.DB_SYNC !== "false",
  },
};

module.exports = config;