const express = require("express");
const router = express.Router();

router.get("/login/success", async (req, res, next) => {
  res.statusCode = 200;
  res.sendStatus(200);
});

router.get("/login/error", async (req, res, next) => {
  res.statusCode = 500;
  res.sendStatus(500);
});

router.get("/registration/success", async (req, res, next) => {
  res.statusCode = 200;
  res.sendStatus(200);
});

router.get("/registration/error", async (req, res, next) => {
  res.statusCode = 500;
  res.sendStatus(500);
});

module.exports = router;
