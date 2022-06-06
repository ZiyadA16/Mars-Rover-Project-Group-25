var express = require('express');
var server = express();

server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/rover_screen.html'); 
});

server.get('/', function(req, res) {
     res.sendFile('/home/ubuntu/rover_mainpage.html'); 
 });

  server.get('/', function(req, res) {
      res.sendFile('/home/ubuntu/rover_map.html'); 
  });

 server.get('/', function(req, res) {
     res.sendFile('/home/ubuntu/rover_about.html'); 
 });



console.log('Server is running on port 3000'); 
server.listen(3000,'0.0.0.0');