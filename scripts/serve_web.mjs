/** Sirve el build de demostración exclusivamente en la máquina local. */
import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
const root=path.resolve('build/web');
const mime={'.html':'text/html; charset=utf-8','.js':'application/javascript','.json':'application/json','.wasm':'application/wasm','.ttf':'font/ttf','.otf':'font/otf','.png':'image/png'};
await fs.access(path.join(root,'index.html'));
http.createServer(async(req,res)=>{
 try {
  const relative=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
  const file=path.resolve(root,'.'+(relative==='/'?'/index.html':relative));
  if(!file.startsWith(root+path.sep)){res.writeHead(403);res.end();return;}
  const bytes=await fs.readFile(file);
  res.setHeader('Content-Type',mime[path.extname(file)]??'application/octet-stream');
  res.setHeader('Cache-Control','no-store');
  res.end(bytes);
 } catch {res.writeHead(404);res.end('Archivo no encontrado.');}
}).listen(5000,'127.0.0.1',()=>console.log('CampusFix local: http://127.0.0.1:5000 — Ctrl+C para detener.'));
