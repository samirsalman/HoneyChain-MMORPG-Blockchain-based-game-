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
  var user = await database
    .getUser(req.body.email, req.body.password)
    .catch((err) => res.send(404));
  console.log(user);

  if (user === undefined) {
    res.send(404);
  } else {
    var date = new Date();
    date.setDate(date.getDate() + 7);
    res.send(user);
  }
});

router.get("/logout", (req, res, next) => {
  res.send(200);
});
module.exports = router;
