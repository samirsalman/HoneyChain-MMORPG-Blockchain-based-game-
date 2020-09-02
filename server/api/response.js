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

router.get("/login/success", (req, res, next) => {
  console.log(req.query);

  setTimeout(() => {
    try {
      res.setHeader("Cookie", `login=${req.query.cookie}`);
      console.log(`login=${req.query.cookie}; expires`);
      var cookie = req.query.cookie;

      console.log("select email from report_login WHERE cookie = '" + cookie);

      connection.query(
        "select email from report_login WHERE cookie = '" +
          cookie +
          "'" /*"select email from report_login where cookie = 'MWQqcHJvdmEzQGNpYW8uaXQqYjEzM2EwYzBlOWJlZTNiZTIwMTYzZDJhZDMxZDYyNDhkYjI5MmFhNmRjYjFlZTA4N2EyYWE1MGUwZmM3NWFlMg@@; expires'"*/,
        function (error, emailResult, fields) {
          if (error) throw error;
          console.log(emailResult);
          connection.query(
            `SELECT * FROM user WHERE email="${emailResult[0].email}"`,
            function (error, user, fields) {
              if (error) throw error;
              console.log(user[0]);
              res.json(JSON.parse(user[0]).toString());
            }
          );
        }
      );

      console.log(res.getHeaders());
    } catch (err) {
      console.log(err);
      res.send(err);
    }
  }, 3000);

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
  console.log(res.getHeaders());
  axios.default
    .get(`${HOST}?username=${req.query.email}`)
    .then((response) => {
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

router.post("/log", (req, res, next) => {
  console.log("---- LOGGING ----");
  console.log(req.body);
  res.send(req.body);
});

module.exports = router;
