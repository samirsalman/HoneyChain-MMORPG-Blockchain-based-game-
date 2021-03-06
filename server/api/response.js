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
      res.setHeader("Content-Type", `application/json`);

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
              var objectToRes = {
                email: user[0].email,
                name: user[0].name,
              };
              console.log(user[0]);
              res.json(objectToRes);
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
});

router.get("/loginGame/success", (req, res, next) => {
  console.log(req.headers);

  setTimeout(() => {
    try {
      res.setHeader("Cookie", `login=${req.headers["set-cookie"]}`);
      res.setHeader("Content-Type", `application/json`);

      console.log(`login=${req.headers.cookie}; expires`);
      var cookie = req.headers.cookie;

      console.log("select email from report_login WHERE cookie = '" + cookie);
      res.status(200).send("OK");

      console.log(res.getHeaders());
    } catch (err) {
      console.log(err);
      res.status(404).send(err);
    }
  }, 3000);
});

router.get("/loginCookie/success", (req, res, next) => {
  console.log(req.headers);

  setTimeout(() => {
    try {
      res.setHeader("Cookie", `${req.headers.cookie}`);
      res.setHeader("Content-Type", `application/json`);

      console.log(`${req.headers.cookie}; expires`);
      var cookie = req.headers.cookie.split("login=")[1];
      console.log(cookie);
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
              var objectToRes = {
                email: user[0].email,
                name: user[0].name,
              };
              console.log(user[0]);
              res.json(objectToRes);
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
  if (req.headers.cookie !== undefined) {
    res.setHeader("Cookie", req.headers.cookie);
  }
  console.log(res.getHeaders());
  res.status(404).send({
    error: "Utente non trovato",
  });
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
  console.log(req.query.error.replace("_", " "));

  res.status(503).send({
    error: req.query.error.replace("_", " "),
  });
});

router.post("/log", (req, res, next) => {
  console.log("---- LOGGING ----");
  console.log(req.body);
  res.send(req.body);
});

module.exports = router;
