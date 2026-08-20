const CACHE='gspend-v2-6-4';
const ASSETS=['/','/index.html','/legal.html','/manifest.webmanifest','/icon-192.png','/icon-512.png','/icon-maskable-512.png','/apple-touch-icon.png','/gspend-logo.png'];
self.addEventListener('install',e=>{self.skipWaiting();e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)))});
self.addEventListener('activate',e=>e.waitUntil(Promise.all([self.clients.claim(),caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k))))])));
self.addEventListener('fetch',e=>{if(e.request.method!=='GET')return;e.respondWith(fetch(e.request).then(r=>{const c=r.clone();caches.open(CACHE).then(x=>x.put(e.request,c));return r}).catch(()=>caches.match(e.request)))});
self.addEventListener('push',e=>{
  let d={};try{d=e.data?e.data.json():{}}catch{d={body:e.data?.text?.()||''}}
  const title=d.title||'GSpend';
  const options={body:d.body||'',icon:d.icon||'/icon-192.png',badge:d.badge||'/icon-192.png',tag:d.tag||'gspend',renotify:true,data:{url:d.url||'/',notificationId:d.notificationId||null}};
  e.waitUntil(self.registration.showNotification(title,options));
});
self.addEventListener('notificationclick',e=>{
  e.notification.close();const url=e.notification?.data?.url||'/';
  e.waitUntil(clients.matchAll({type:'window',includeUncontrolled:true}).then(list=>{for(const client of list){if('navigate' in client){client.navigate(url);client.focus();return}}return clients.openWindow(url)}));
});
