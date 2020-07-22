const express = require("express");
const router = express.Router();
const database = require("../../database/database");
const User = require("../../../models/user");
var hash = require("object-hash");
//endpoint to register user
router.post("/", async (req, res, next) => {
  /*Verify name and email not exists
  if true create and save to mongoDB the user and initialize player
else return error

*/
  var isGood = false;

  isGood = await database.isEmailGood(req.body.email).catch((error) => {
    res.send(error);
  });

  console.log(isGood);

  if (isGood != null && isGood) {
    var user = new User(
      req.body.email,
      hash(req.body.password),
      req.body.name,
      req.body.years
    );
    await database.createUser(user).catch((err) => {
      console.error(err);
    });
    res.send(user);
  } else {
    res.send("Not good email");
  }
});

module.exports = router;
