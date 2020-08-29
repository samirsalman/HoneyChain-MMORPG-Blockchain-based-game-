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

router.get("/login/success", async (req, res, next) => {
  if (req.query.email !== undefined && req.query.email !== null) {
    try {
      res.setHeader("Cookie", req.headers.cookie);
      var cookie = req.headers.cookie.split("login=")[1];
      connection.query(
        `SELECT * FROM report_login WHERE cookie="${cookie}"`,
        function (error, results, fields) {
          if (error) throw error;
          console.log("The solution is: ", results[0].email);
          var email = results[0].email;

          connection.query(
            `SELECT * FROM user WHERE email="${email}"`,
            function (error, resultsUser, fields) {
              console.log(resultsUser);
              res.send(resultsUser[0]);
            }
          );
        }
      );
    } catch (error) {
      console.log(error);
    }
  }
  console.log(res.getHeaders());

  connection.query(
    `SELECT * FROM user WHERE email="${req.query.email}"`,
    function (error, resultsUser, fields) {
      if (error) throw error;
      console.log(resultsUser);
      res.send(resultsUser);
    }
  );

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
