var http = require('http');

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.write(req.url+'</br>');
  res.end('Hello Ratanaz!'+ Date());
}).listen(8080);