/** Semillas reproducibles exclusivamente para emuladores. No toca producción. */
import {initializeApp} from 'firebase-admin/app';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
const projectId='demo-campusfix';
process.env.FIREBASE_AUTH_EMULATOR_HOST='127.0.0.1:9099';
process.env.FIRESTORE_EMULATOR_HOST='127.0.0.1:8080';
initializeApp({projectId});
const users=[['admin','Administrador','administrador'],['tecnico','Técnico de mantenimiento','tecnico'],['usuario','Usuario reportante','reportante']];
for(const [uid,name,role] of users){
 try{await getAuth().createUser({uid,email:`${uid}@campusfix.test`,password:'CampusFix2026!',displayName:name});}
 catch(e){if(e.code!=='auth/uid-already-exists'&&e.code!=='auth/email-already-exists')throw e;}
 await getFirestore().doc(`users/${uid}`).set({name,email:`${uid}@campusfix.test`,role});
}
for(const [id,name] of Object.entries({infraestructura:'Infraestructura',conectividad:'Conectividad',mobiliario:'Mobiliario',iluminacion:'Iluminación',limpieza:'Limpieza',accesibilidad:'Accesibilidad',equipos:'Equipos'})){
 await getFirestore().doc(`categories/${id}`).set({name,active:true});
}
console.log('Emuladores preparados. Usuarios: admin, tecnico, usuario @campusfix.test. Clave local: CampusFix2026!');
