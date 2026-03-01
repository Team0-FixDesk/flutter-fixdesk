const express = require('express');
const cors = require('cors');
const http = require('http');

const app = express();

app.use(cors({
  origin: '*',  // หรือระบุ origin ของ Flutter web
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}))

app.use(express.json());

const TARGET_HOST = 'dekdee2.informatics.buu.ac.th';
const TARGET_PORT = 8058;

// Manual proxy ที่รองรับ HTTP/0.9
app.all('*', (req, res) => {
  const options = {
    hostname: TARGET_HOST,
    port: TARGET_PORT,
    path: req.url,
    method: req.method,
    headers: {
      ...req.headers,
      host: `${TARGET_HOST}:${TARGET_PORT}`,
    },
  };

  console.log(`→ ${req.method} ${req.url}`);

  const proxyReq = http.request(options, (proxyRes) => {
    console.log(`← ${proxyRes.statusCode ?? 'HTTP/0.9'} ${req.url}`);

    // รองรับ HTTP/0.9 ที่ไม่มี status code
    const statusCode = proxyRes.statusCode || 200;

    res.writeHead(statusCode, {
      'Content-Type': proxyRes.headers['content-type'] || 'application/json',
      'Access-Control-Allow-Origin': '*',
    });

    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err.message);
    res.status(502).json({ error: err.message });
  });

  // ส่ง body ไปด้วยถ้ามี
  if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
    const body = JSON.stringify(req.body);
    proxyReq.setHeader('Content-Length', Buffer.byteLength(body));
    proxyReq.write(body);
  }

  proxyReq.end();
});

app.listen(3000, () => {
  console.log('✅ Proxy running at http://localhost:3000');
  console.log(`   → forwarding to http://${TARGET_HOST}:${TARGET_PORT}`);
});