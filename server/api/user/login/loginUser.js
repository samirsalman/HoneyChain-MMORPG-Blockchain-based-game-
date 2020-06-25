const express = require("express");
const router = express.Router();

//endpoint to login user
router.get("/", (req, res, next) => {
  /*Verify email and password
  if true return the player of the user
else return error
  */

  res.send("login User");
});

module.exports = router;
