var express = require('express');
var server = express();


server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/command/rover_mainpage.html'); 
});

server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/command/rover_screen.html'); 
});

  server.get('/', function(req, res) {
      res.sendFile('/home/ubuntu/command/rover_map.html'); 
  });

 server.get('/', function(req, res) {
     res.sendFile('/home/ubuntu/command/rover_about.html'); 
 });



console.log('Server is running on port 3000'); 
server.listen(3000,'0.0.0.0');