const express = require("express");
const router = express.Router();
const axios = require("axios");
const HOST = "http://localhost:3001/registerUser";

router.get("/login/success", async (req, res, next) => {
  res.statusCode = 200;
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());
  res.send({
    name: req.query.name,
    years: req.query.years,
    email: req.query.email,
  });
});

router.get("/login/error", async (req, res, next) => {
  res.statusCode = 500;
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());
  res.sendStatus(500);
});

router.get("/registration/success", async (req, res, next) => {
  res.statusCode = 200;
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());

  axios.default.get(`${HOST}?username=${req.query.email}`).then(() => {
    res.sendStatus(200);
  });
});

router.get("/registration/error", async (req, res, next) => {
  res.statusCode = 500;
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());
  res.sendStatus(500);
});

module.exports = router;
