const express = require("express");
const router = express.Router();

const database = require("../../database/database");
const User = require("../../../models/user");
var hash = require("object-hash");

var Cookies = require("cookies");

//endpoint to login user
router.post("/", async (req, res, next) => {
  /*Verify email and password
  if true return the player of the user
else return error
  */
  var cookies = new Cookies(req, res);

  var user = await database
    .getUser(req.body.email, hash(req.body.password))
    .catch((err) => res.send(404));
  console.log(user);

  if (user === undefined) {
    res.send(404);
  } else {
    var date = new Date();
    date.setDate(date.getDate() + 7);
    cookies.set("user", user.name, { expires: date });
    res.send(user);
  }
});

router.get("/logout", (req, res, next) => {
  var cookies = new Cookies(req, res);
  cookies.set("user", null);
  res.send(200);
});
module.exports = router;
