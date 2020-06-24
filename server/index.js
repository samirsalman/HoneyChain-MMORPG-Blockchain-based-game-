//Let's include the module to work with HTTP
const http = require("http");

//Let's include the module to create quicky our  server
const express = require("express");
const app = express();

//define the port on which the server will listen
const PORT = process.env.PORT || 3000;
app.listen(PORT, function () {
  console.log(`I'm listening on port : `, PORT);
});

//Let's define the basic route to access to our server
app.get("/fire", (req, res, next) => {
  for (const [client, sequenceNumber] of sequenceNumberByClient.entries()) {
    client.emit("fire", sequenceNumber);
    sequenceNumberByClient.set(client, sequenceNumber + 1);
  }
});

const io = require("socket.io"),
  server = io.listen(8000);
let sequenceNumberByClient = new Map();

// event fired every time a new client connects:
server.on("connection", (socket) => {
  console.info(`Client connected [id=${socket.id}]`);
  // initialize this client's sequence number
  sequenceNumberByClient.set(socket, 1);

  // when socket disconnects, remove it from the list:
  socket.on("disconnect", () => {
    sequenceNumberByClient.delete(socket);
    console.info(`Client gone [id=${socket.id}]`);
  });
});

// sends each client its current sequence number
