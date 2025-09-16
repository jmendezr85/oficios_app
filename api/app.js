const express = require("express");
const cors = require("cors");

const config = require("./config");
const routes = require("./routes");
const notFound = require("./middleware/notFound");
const errorHandler = require("./middleware/errorHandler");

const app = express();

const corsOrigins = config.cors.origins;
const corsOptions = corsOrigins.includes("*")
  ? { origin: true, credentials: true }
  : { origin: corsOrigins, credentials: true };

app.use(cors(corsOptions));
app.use(express.json());

app.use(routes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;