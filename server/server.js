//Let's include the module to work with HTTP
const http = require("http");

//Let's include the module to create quicky our  server
const express = require("express");
const app = express();
const cors = require("cors");

app.use(cors({}));
//define the port on which the server will listen
const PORT = process.env.PORT || 3000;
app.listen(PORT, function () {
  console.log(`I'm listening on port : `, PORT);
});

//Let's define the basic route to access to our server
app.get("/fired/:id", (req, res, next) => {
  for (const [client, player] of players.entries()) {
    client.emit("fired", req.params.id);
  }
  res.sendStatus(200);
});

app.post("/exchange", (req, res, next) => {
  let userFrom = req.body.from;
  let userTo = req.body.to;
  let honey = req.body.honey;

  //Write to Hyperledger

  res.sendStatus(200);
});

app.get("/move/:id", (req, res, next) => {
  for (const [client, player] of players.entries()) {
    client.emit("moved", {
      id: req.params.id,
      x: Math.random(),
      y: Math.random(),
    });
    //players[req.id] = [Math.random(), Math.random()];
  }
  res.sendStatus(200);
});

const io = require("socket.io"),
  server = io.listen(8000);
let players = new Map();

// event fired every time a new client connects:
server.on("connection", (socket) => {
  console.info(`Client connected [id=${socket.id}]`);
  // initialize this client's sequence number
  players.set(socket, 0);

  // when socket disconnects, remove it from the list:
  socket.on("disconnect", () => {
    players.delete(socket);
    console.info(`Client gone [id=${socket.id}]`);
  });
});

/*Let's include the module that enable the backend to parse the json received in the
body of the http request*/
const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

const responseRoute = require("./api/response.js");
app.use("/response", responseRoute);

// sends each client its current sequence number
