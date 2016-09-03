var express = require('express');
var http = require('http');
var app = express();

// The port the browser connects to
var serverPort = 8080;

var mode   = process.env.NODE_ENV;
var apiKey = process.env.demoApiKey;
if (!apiKey.trim()) {
    console.log("ERROR: demoApiKey must be set as an enviornment variable!\n\n");
    process.exit(-1);
}

// Static client files are served from here
app.use('/demo', express.static('demo'));
app.use('/bower_components', express.static('bower_components'));

// Setup to handle POST requests from client
var bodyParser = require('body-parser')
app.use( bodyParser.json() ); 
app.use(bodyParser.urlencoded({
  extended: true
})); 

app.use(bodyParser.urlencoded({ extended: true }));

// Setup API Proxy
var proxy = require('express-http-proxy');
var apiProxy = proxy('momo_server:80', {
    decorateRequest: function(proxyReq, originalReq) {
        proxyReq.headers['Authorization'] = apiKey;
        proxyReq.headers['Content-Type'] = "application/json"
        return proxyReq;
    },
    forwardPath: function(req, res) {
        console.log("> " + req.baseUrl + ": " + JSON.stringify(req.body));
        return req.baseUrl;
    }
});
app.use("/api/*", apiProxy);

// Start server listener
app.listen(serverPort, function () {
    console.log('Example app listening on port ' + serverPort + ".");
});



