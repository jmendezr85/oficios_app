const sanitizeString = (value) => (typeof value === "string" ? value.trim() : "");

const normalizeEmail = (value = "") => sanitizeString(value).toLowerCase();

const normalizePhone = (value) => {
  if (value === undefined || value === null) return null;
  const trimmed = sanitizeString(String(value));
  return trimmed.length ? trimmed : null;
};

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const isValidEmail = (value) => emailRegex.test(normalizeEmail(value));

const serializeUser = (user) => ({
  id: user.id,
  nombre: user.nombre,
  correo: user.correo,
  telefono: user.telefono,
  rol: user.rol,
});

module.exports = {
  sanitizeString,
  normalizeEmail,
  normalizePhone,
  isValidEmail,
  serializeUser,
};