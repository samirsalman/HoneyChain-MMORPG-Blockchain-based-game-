const express = require("express");
const router = express.Router();
const axios = require("axios");
const HOST = "http://localhost:3001/registerUser";

var mysql = require("mysql");
var connection = mysql.createConnection({
  host: "127.0.0.1",
  user: "root",
  password: "password",
  database: "honey",
});

connection.connect();

connection.query("SELECT * FROM user", function (error, results, fields) {
  if (error) throw error;
  console.log("The solution is: ", results[0].solution);
});

connection.end();

router.get("/login/success", async (req, res, next) => {
  if (req.query.email !== undefined && req.query.email !== null) {
    try {
      res.setHeader("Cookie", req.headers.cookie);
      var cookie = req.headers.cookie.split("login=")[1];
      var user = await knex("user").where("cookie", cookie);
      console.log(user);
      var email = user[0].email;
      console.log(email);
      var data = await knex("user").where("email", email);
      res.send(data);
    } catch (error) {
      console.log(error);
    }
  }
  console.log(res.getHeaders());

  try {
    var userRes = await knex("user").where("email", req.query.email);

    res.send(userRes);
  } catch (error) {
    res.send(error);
  }
  /*
  res.send({
    name: req.query.name,
    years: req.query.years,
    email: req.query.email,
  });
  */
});

router.get("/login/error", (req, res, next) => {
  res.statusCode = 500;
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());
  res.sendStatus(500);
});

router.get("/registration/success", (req, res, next) => {
  res.statusCode = 200;
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());
  axios.default
    .get(`${HOST}?username=${req.query.email}`)
    .then(() => {
      res.sendStatus(200);
    })
    .catch((err) => res.send(err));
});

router.get("/registration/error", (req, res, next) => {
  res.statusCode = 500;
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());
  res.sendStatus(500);
});

module.exports = router;
