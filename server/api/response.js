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
  console.log(req.headers.cookie);

  console.log(req.headers.cookie.split("login=")[1]);

  setTimeout(() => {
    res.setHeader("Cookie", req.headers.cookie);
    console.log(`${req.headers.cookie.split("login=")[1]}; expires`);
    var cookie = req.headers.cookie.split("login=")[1];

    console.log(
      "select email from report_login WHERE cookie = '" + cookie + "; expires'"
    );

    connection.query(
      "select email from report_login WHERE cookie = '" +
        cookie +
        "; expires'" /*"select email from report_login where cookie = 'MWQqcHJvdmEzQGNpYW8uaXQqYjEzM2EwYzBlOWJlZTNiZTIwMTYzZDJhZDMxZDYyNDhkYjI5MmFhNmRjYjFlZTA4N2EyYWE1MGUwZmM3NWFlMg@@; expires'"*/,
      function (error, emailResult, fields) {
        if (error) throw error;
        console.log(emailResult);
        connection.query(
          `SELECT * FROM user WHERE email="${emailResult[0].email}"`,
          function (error, user, fields) {
            if (error) throw error;
            console.log(user[0]);
            res.send(user[0]);
          }
        );
      }
    );

    console.log(res.getHeaders());
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
