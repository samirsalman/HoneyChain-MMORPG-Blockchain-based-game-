const express = require("express");
const router = express.Router();
//endpoint to register user

const axios = require("axios");

const HOST = "http://localhost:3001/registerUser";

router.post("/", async (req, res, next) => {
  axios.default.get(`${HOST}?username=${req.query.email}`).then((res) => {
    res.sendStatus(200);
  });
});

module.exports = router;
