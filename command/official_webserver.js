var express = require('express');
var server = express();

server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/drone_screen.html'); 
});

server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/drone_path.html'); 
});

server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/drone_battery.html'); 
});

server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/drone_radar_data.html'); 
});



console.log('Server is running on port 3000'); 
server.listen(3000,'0.0.0.0');
