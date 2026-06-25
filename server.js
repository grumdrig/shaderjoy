const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 7015;
const DIR = __dirname;

const MIME = {
  '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css',
  '.glsl': 'text/plain', '.json': 'application/json', '.png': 'image/png',
  '.jpg': 'image/jpeg', '.svg': 'image/svg+xml',
};

// SSE clients
const clients = new Set();

// Serve static files + SSE endpoint
const server = http.createServer((req, res) => {
  if (req.url === '/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });
    res.write('\n');
    clients.add(res);
    req.on('close', () => clients.delete(res));

    // Send full file list on connect, then push the most recently modified shader
    sendFileList(res);
    pushNewest(res);
    return;
  }

  // Static file serving
  let filePath = path.join(DIR, req.url === '/' ? 'shaderjoy.html' : decodeURIComponent(req.url.split('?')[0]));
  fs.stat(filePath, (err, stat) => {
    if (err || !stat.isFile()) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
    const ext = path.extname(filePath);
    res.writeHead(200, {
      'Content-Type': MIME[ext] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    fs.createReadStream(filePath).pipe(res);
  });
});

// Send the list of .glsl files to one client
function sendFileList(client) {
  const files = fs.readdirSync(DIR).filter(f => f.endsWith('.glsl')).map(f => f.slice(0, -5));
  client.write(`event: filelist\ndata: ${JSON.stringify(files)}\n\n`);
}

// Push the most recently modified .glsl file to one client
function pushNewest(client) {
  const files = fs.readdirSync(DIR).filter(f => f.endsWith('.glsl'));
  let newest = null, newestMtime = 0;
  for (const f of files) {
    const mt = fs.statSync(path.join(DIR, f)).mtimeMs;
    if (mt > newestMtime) { newestMtime = mt; newest = f; }
  }
  if (newest) {
    const name = newest.slice(0, -5);
    const contents = fs.readFileSync(path.join(DIR, newest), 'utf8');
    client.write(`event: change\ndata: ${JSON.stringify({ name, contents })}\n\n`);
  }
}

// Send a changed file's contents to all clients
function pushFile(name) {
  const filePath = path.join(DIR, name + '.glsl');
  fs.readFile(filePath, 'utf8', (err, contents) => {
    if (err) return;
    const data = JSON.stringify({ name, contents });
    for (const client of clients) {
      client.write(`event: change\ndata: ${data}\n\n`);
    }
  });
}

// Watch for .glsl file changes
const debounce = {};
fs.watch(DIR, (eventType, filename) => {
  if (!filename || !filename.endsWith('.glsl')) return;
  const name = filename.slice(0, -5);

  // Debounce: editors often fire multiple events per save
  clearTimeout(debounce[name]);
  debounce[name] = setTimeout(() => {
    const exists = fs.existsSync(path.join(DIR, filename));
    if (exists) {
      console.log(`changed: ${filename}`);
      pushFile(name);
    }
    // Also refresh file list (handles new/deleted files)
    for (const client of clients) sendFileList(client);
  }, 50);
});

server.listen(PORT, () => console.log(`Shaderjoy server on http://localhost:${PORT}`));
