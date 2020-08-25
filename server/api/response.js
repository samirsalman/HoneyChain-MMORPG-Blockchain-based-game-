const express = require("express");
const router = express.Router();

router.get("/login/success", async (req, res, next) => {
  res.statusCode = 200;
  res.send("Login Effettuato");
});

router.get("/login/error", async (req, res, next) => {
  res.statusCode = 500;
  res.send("Login Non Effettuato");
});

router.get("/registration/success", async (req, res, next) => {
  res.statusCode = 200;
  res.send("Registrazione Effettuata");
});

router.get("/registration/error", async (req, res, next) => {
  res.statusCode = 500;
  res.send("Registrazione Non Effettuata");
});

module.exports = router;
