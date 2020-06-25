const io = require("socket.io-client"),
  ioClient = io.connect("http://localhost:8000");

ioClient.on("fired", (data) => console.info(data, "fired"));

ioClient.on("moved", (data) =>
  console.info("player", data.id, "moved to:", `X: ${data.x}, Y: ${data.y}`)
);
