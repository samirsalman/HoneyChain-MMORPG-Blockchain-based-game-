const express = require("express");
const router = express.Router();

//endpoint to register user
router.post("/", (req, res, next) => {
  /*Verify name and email not exists
  if true create and save to mongoDB the user and initialize player
else return error
  */
  res.send("register User");
});

module.exports = router;
