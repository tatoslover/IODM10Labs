const express = require("express");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = new Server(server);

// Serve the HTML file
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/index.html");
});

// Store users with their socket.id
let users = {};

io.on("connection", (socket) => {
  console.log("A user connected");

  // Send current online users to the newly connected client
  socket.emit("update user list", Object.values(users));

  // Handle nickname selection
  socket.on("choose name", (nickname) => {
    users[socket.id] = nickname;

    // Notify others about the new user
    socket.broadcast.emit("new user", {
      nickname: nickname,
      text: "has joined the chat",
    });

    // Update all clients with the new user list
    io.emit("update user list", Object.values(users));
  });

  // Handle chat messages
  socket.on("chat message", (msg) => {
    const sender = users[socket.id] || "Unknown";
    // Send to others except the sender
    socket.broadcast.emit("chat message", `${sender}: ${msg}`);
  });

  // Handle typing status
  socket.on("typing", () => {
    const user = users[socket.id];
    socket.broadcast.emit("user typing", `${user}`);
  });

  // Handle stop typing (optional if you implement timers on client side)
  socket.on("stop typing", () => {
    socket.broadcast.emit("not typing");
  });

  // Handle disconnection
  socket.on("disconnect", () => {
    const nickname = users[socket.id];
    if (nickname) {
      // Notify others
      socket.broadcast.emit("user left", `${nickname} has left the chat`);
    }
    // Remove user and update list
    delete users[socket.id];
    io.emit("update user list", Object.values(users));
  });
});

server.listen(3000, () => {
  console.log("listening on *:3000");
});
