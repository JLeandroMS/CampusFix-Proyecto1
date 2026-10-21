/** Prueba de navegador con servicios emulados y build Flutter real. */
import { chromium } from 'playwright';
import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
const shots=process.env.CAMPUSFIX_TEST_ARTIFACTS||path.join(os.tmpdir(),'campusfix-browser');
await fs.mkdir(shots,{recursive:true});
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
const exec=promisify(execFile);
import {strict as assert} from 'node:assert';
import {getFirestore} from 'firebase-admin/firestore';
await import('../scripts/seed.mjs');
const root=path.resolve('build/web');
const types={'.html':'text/html','.js':'application/javascript','.wasm':'application/wasm','.json':'application/json','.png':'image/png','.ttf':'font/ttf'};
const server=http.createServer(async(req,res)=>{try{let name=decodeURIComponent(req.url.split('?')[0]);if(name==='/')name='/index.html';const full=path.resolve(root,'.'+name);if(!full.startsWith(root+path.sep)){res.writeHead(403);res.end();return;}const body=await fs.readFile(full);res.setHeader('Content-Type',types[path.extname(full)]??'application/octet-stream');res.end(body);}catch{res.writeHead(404);res.end('Not found');}});
await new Promise(r=>server.listen(5000,'127.0.0.1',r));
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_EXECUTABLE||undefined,args:['--disable-dev-shm-usage','--no-sandbox']});
try {
 const page=await browser.newPage({locale:'es-CR',viewport:{width:1440,height:1400}});
 if(process.env.HTTPS_PROXY){await page.route('https://www.gstatic.com/**',async route=>{try{const {stdout}=await exec('curl',['-fsSL','--max-time','45',route.request().url()],{encoding:'buffer',maxBuffer:20*1024*1024});await route.fulfill({status:200,contentType:'application/javascript',headers:{'Access-Control-Allow-Origin':'*'},body:stdout});}catch{await route.abort();}});}
 page.on('pageerror',e=>console.log('PAGEERROR',e.message));
 page.on('requestfailed',r=>console.log('REQUESTFAILED',r.url(),r.failure()?.errorText));
 await page.goto('http://127.0.0.1:5000');
 await page.waitForTimeout(15000);
 console.log('BODY',await page.locator('body').innerText());
 console.log('SEMANTICS',await page.locator('flt-semantics-placeholder').count());
 if(await page.locator('flt-semantics-placeholder').count())await page.locator('flt-semantics-placeholder').evaluate(e=>e.click());
 await page.waitForTimeout(2000);
 console.log('DOM',await page.locator('body').innerText());
 console.log('INPUTS',await page.locator('input').evaluateAll(es=>es.map(e=>({type:e.type,label:e.getAttribute('aria-label')}))));
 await page.screenshot({path:shots+'/campusfix-login.png'});
 async function typeField(name,value){await page.getByRole('textbox',{name,exact:typeof name==='string'}).click();await page.waitForTimeout(200);await page.keyboard.type(value,{delay:20});}
 await typeField('Correo electrónico','admin@campusfix.test');
 await typeField('Contraseña','CampusFix2026!');
 await page.getByRole('button',{name:'Ingresar',exact:true}).click();
 await page.waitForTimeout(5000);
 console.log('AFTER LOGIN',await page.locator('body').innerText());
 await page.screenshot({path:shots+'/campusfix-afterlogin.png'});
 await page.getByText('Cuidemos nuestro campus',{exact:true}).waitFor({timeout:15000});
 console.log('LOGIN OK');
 console.log('ADMIN',await page.locator('body').innerText());
 await page.screenshot({path:shots+'/campusfix-admin.png'});
 await page.getByText('Dashboard',{exact:true}).click();
 await page.getByText('El campus, en perspectiva',{exact:true}).waitFor();
 console.log('DASHBOARD OK');
 await page.screenshot({path:shots+'/campusfix-dashboard.png'});
 await page.getByText('Incidencias',{exact:true}).click();
 await page.getByRole('button',{name:'Nueva incidencia',exact:true}).click();
 await typeField('Título','Luminaria dañada en aula 10');
 await typeField('Descripción','La luminaria del aula 10 no enciende y requiere revisión.');
 await typeField(/^Ubicación/,'Edificio de aulas, aula 10');
 console.log('DROPDOWNS',await page.locator('[role]').evaluateAll(es=>es.filter(e=>e.textContent==='Categoría'||e.getAttribute('aria-label')?.includes('Categoría')).map(e=>({role:e.getAttribute('role'),label:e.getAttribute('aria-label'),text:e.textContent}))));
 await page.screenshot({path:shots+'/before-category.png'});
 await page.getByRole('button',{name:/Categoría/}).evaluate(e=>e.click());
 await page.waitForTimeout(500);
 await page.screenshot({path:shots+'/category-options.png'});
 console.log('OPTIONS',await page.locator('body').innerText());
 await page.getByText('Iluminación',{exact:true}).or(page.getByLabel('Iluminación',{exact:true})).first().click();
 await page.getByRole('button',{name:'Enviar reporte',exact:true}).click();
 await page.waitForTimeout(3000);
 console.log('REPORT',await page.locator('body').innerText());
 await page.getByRole('button',{name:'Revisar',exact:true}).waitFor();
 const cases=(await getFirestore().collection('incidents').get()).docs;
 assert.equal(cases.length,1);assert.equal(cases[0].data().number,1);assert.equal(cases[0].data().status,'reportada');
 console.log('CREATE OK');
 await page.screenshot({path:shots+'/campusfix-report.png'});
 async function confirmChange(button,note){await page.getByRole('button',{name:button,exact:true}).click();await typeField('Motivo o detalle del cambio',note);await page.getByRole('button',{name:'Confirmar',exact:true}).click();}
 await confirmChange('Revisar','Reporte verificado por administración.');
 await page.getByRole('button',{name:'Clasificar',exact:true}).waitFor();
 console.log('REVIEW OK');
 await confirmChange('Clasificar','Se confirma categoría y prioridad del reporte.');
 await page.getByRole('button',{name:'Asignar técnico',exact:true}).click();
 await page.getByRole('button',{name:/Técnico responsable/}).evaluate(e=>e.click());
 await page.getByText('Técnico de mantenimiento',{exact:true}).or(page.getByLabel('Técnico de mantenimiento',{exact:true})).first().click();
 await typeField('Motivo o detalle del cambio','Se asigna al técnico de mantenimiento.');
 await page.getByRole('button',{name:'Confirmar',exact:true}).click();
 await page.waitForTimeout(1000);
 const assigned=(await cases[0].ref.get()).data();assert.equal(assigned.status,'asignada');assert.equal(assigned.technicianId,'tecnico');
 console.log('ASSIGN OK');
 await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();
 await page.getByRole('textbox',{name:'Correo electrónico',exact:true}).waitFor();
 console.log('LOGOUT OK');



} finally {await browser.close();await new Promise(r=>server.close(r));}
