/** Pruebas reales contra reglas: el SDK cliente intenta operaciones hostiles. */
import {before, after, beforeEach, test} from 'node:test';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, setDoc, getDoc, updateDoc, deleteDoc, writeBatch, serverTimestamp, collection, query, where, getDocs} from 'firebase/firestore';
import {ref, uploadBytes, getBytes} from 'firebase/storage';
let env;
const stamp = () => serverTimestamp();
const profile = (role) => ({name:'Persona de prueba',email:'test@example.com',role});
const incident = (overrides={}) => ({number:1,title:'Luminaria dañada',description:'La luminaria del aula no funciona.',categoryId:'luz',location:'Aula 10',priority:'media',status:'reportada',creatorId:'reporter',technicianId:null,revision:0,createdAt:stamp(),updatedAt:stamp(),...overrides});
const event = (status='reportada',technicianId=null,authorId='reporter',note='Descripción suficiente del cambio.') => ({authorId,at:stamp(),status,technicianId,note,categoryId:'luz',priority:'media'});
const db = (uid) => env.authenticatedContext(uid,{email:'test@example.com'}).firestore();
before(async()=> {env=await initializeTestEnvironment({projectId:'demo-campusfix',firestore:{rules:readFileSync('firestore.rules','utf8')},storage:{rules:readFileSync('storage.rules','utf8')}});});
after(async()=>{await env.cleanup();});
beforeEach(async()=>{
  await env.clearFirestore(); await env.clearStorage();
  await env.withSecurityRulesDisabled(async c=>{
    const d=c.firestore();
    for(const [uid,role] of [['reporter','reportante'],['other','reportante'],['tech','tecnico'],['tech2','tecnico'],['admin','administrador']]) await setDoc(doc(d,'users',uid),profile(role));
    await setDoc(doc(d,'categories/luz'),{name:'Iluminación',active:true});
    await setDoc(doc(d,'incidents/case'),incident());
    await setDoc(doc(d,'incidents/case/events/0'),event());
  });
});
async function change(uid,status,technicianId=null,note='Descripción suficiente del cambio.') {
  const d=db(uid); const current=(await getDoc(doc(d,'incidents/case'))).data();
  const batch=writeBatch(d); const revision=current.revision+1;
  batch.update(doc(d,'incidents/case'),{status,technicianId,revision,updatedAt:stamp()});
  batch.set(doc(d,`incidents/case/events/${revision}`),event(status,technicianId,uid,note));
  return batch.commit();
}
async function seedState(status,technicianId=null) {
  await env.withSecurityRulesDisabled(c=>updateDoc(doc(c.firestore(),'incidents/case'),{status,technicianId}));
}
test('sin sesión no se leen incidencias',()=>assertFails(getDoc(doc(env.unauthenticatedContext().firestore(),'incidents/case'))));
test('reportante lee propios pero no ajenos',async()=>{await assertSucceeds(getDoc(doc(db('reporter'),'incidents/case')));await assertFails(getDoc(doc(db('other'),'incidents/case')));});
test('consulta propia autorizada y consulta global denegada',async()=>{await assertSucceeds(getDocs(query(collection(db('reporter'),'incidents'),where('creatorId','==','reporter'))));await assertFails(getDocs(collection(db('reporter'),'incidents')));});
test('registro no permite autoasignarse administrador',()=>assertFails(setDoc(doc(db('new'),'users/new'),profile('administrador'))));
test('usuario nuevo puede registrarse reportante',()=>assertSucceeds(setDoc(doc(db('new'),'users/new'),profile('reportante'))));
test('perfil admite nombre pero no rol',async()=>{await assertSucceeds(updateDoc(doc(db('reporter'),'users/reporter'),{name:'Nombre actualizado'}));await assertFails(updateDoc(doc(db('reporter'),'users/reporter'),{role:'administrador'}));});
test('admin cambia rol ajeno pero no el propio',async()=>{await assertSucceeds(updateDoc(doc(db('admin'),'users/other'),{role:'tecnico'}));await assertFails(updateDoc(doc(db('admin'),'users/admin'),{role:'reportante'}));});
test('catálogo restringido a administrador',async()=>{await assertFails(setDoc(doc(db('reporter'),'categories/red'),{name:'Red',active:true}));await assertSucceeds(setDoc(doc(db('admin'),'categories/red'),{name:'Red',active:true}));});
test('creación atómica con consecutivo e historial',async()=>{
  const d=db('reporter'), b=writeBatch(d);
  b.set(doc(d,'counters/incidents'),{value:1,lastId:'new'});
  b.set(doc(d,'incidents/new'),incident());b.set(doc(d,'incidents/new/events/0'),event());
  await assertSucceeds(b.commit());
});
test('no permite crear sin contador ni auditoría',()=>assertFails(setDoc(doc(db('reporter'),'incidents/new'),incident())));
test('no permite modificar estado sin historial',()=>assertFails(updateDoc(doc(db('admin'),'incidents/case'),{status:'enRevision',revision:1,updatedAt:stamp()})));
test('flujo principal completo conserva auditoría',async()=>{
  await assertSucceeds(change('admin','enRevision'));
  await assertSucceeds(change('admin','asignada','tech'));
  await assertSucceeds(change('tech','enAtencion','tech'));
  await assertSucceeds(change('tech','resuelta','tech','Se reemplazó la luminaria y se verificó su funcionamiento.'));
  await assertSucceeds(change('admin','cerrada','tech'));
});
test('ni admin ni otro técnico pueden iniciar atención',async()=>{
  await seedState('asignada','tech');await assertFails(change('admin','enAtencion','tech'));
  const d=db('tech2'),b=writeBatch(d);b.update(doc(d,'incidents/case'),{status:'enAtencion',revision:1,updatedAt:stamp()});b.set(doc(d,'incidents/case/events/1'),event('enAtencion','tech','tech2'));await assertFails(b.commit());
});
test('resolver exige solución de al menos diez caracteres',async()=>{await seedState('enAtencion','tech');await assertFails(change('tech','resuelta','tech',''));});
test('no se puede cerrar directamente un reporte',()=>assertFails(change('admin','cerrada')));
test('no se asigna a un reportante',async()=>{await seedState('enRevision');await assertFails(change('admin','asignada','other'));});
test('solo creador cancela antes de asignación',async()=>{await assertSucceeds(change('reporter','cancelada'));await seedState('asignada','tech');await assertFails(change('reporter','cancelada','tech'));});
test('reapertura limpia responsable y conserva historial',async()=>{await seedState('cerrada','tech');await assertSucceeds(change('admin','reabierta'));});
test('auditoría inmutable y no eliminable',async()=>{await assertFails(updateDoc(doc(db('admin'),'incidents/case/events/0'),{note:'Cambio malicioso'}));await assertFails(deleteDoc(doc(db('admin'),'incidents/case')));});
test('comentario registra autor real',async()=>{
 const d=db('reporter');await assertSucceeds(setDoc(doc(d,'incidents/case/comments/a'),{authorId:'reporter',at:stamp(),text:'Información adicional.',evidence:null}));
 await assertFails(setDoc(doc(d,'incidents/case/comments/b'),{authorId:'admin',at:stamp(),text:'Autor falsificado.',evidence:null}));
});
test('caso cerrado bloquea nuevos comentarios',async()=>{await seedState('cerrada');await assertFails(setDoc(doc(db('reporter'),'incidents/case/comments/a'),{authorId:'reporter',at:stamp(),text:'Información adicional.',evidence:null}));});
test('Storage valida propietario, tipo, tamaño y lectura privada',async()=>{
 const mine=env.authenticatedContext('reporter').storage(), other=env.authenticatedContext('other').storage();
 const path='incidents/case/reporter/photo.png';
 await assertSucceeds(uploadBytes(ref(mine,path),new Uint8Array([137,80,78,71]),{contentType:'image/png'}));
 await assertFails(uploadBytes(ref(other,'incidents/case/other/a.png'),new Uint8Array([1]),{contentType:'image/png'}));
 await assertFails(uploadBytes(ref(mine,'incidents/case/reporter/a.txt'),new Uint8Array([1]),{contentType:'text/plain'}));
 await assertFails(uploadBytes(ref(mine,'incidents/case/reporter/large.png'),new Uint8Array(5*1024*1024+1),{contentType:'image/png'}));
 await assertFails(getBytes(ref(other,path)));
});
