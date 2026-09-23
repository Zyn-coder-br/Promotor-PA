const CACHE='promotor-pa-v05';
const APP_SHELL=['./','./index.html','./styles.css','./app.js','./supabase-client.js','./manifest.webmanifest','./version.json'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(APP_SHELL)).then(()=>self.skipWaiting())));
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim())));
self.addEventListener('message',e=>{if(e.data?.type==='SKIP_WAITING')self.skipWaiting();});
self.addEventListener('fetch',e=>{if(e.request.method!=='GET')return;const url=new URL(e.request.url);if(url.pathname.endsWith('/version.json')){e.respondWith(fetch(e.request,{cache:'no-store'}));return;}const asset=e.request.mode==='navigate'||/\.(?:html|js|css|webmanifest)$/.test(url.pathname);if(asset){e.respondWith(fetch(e.request,{cache:'no-store'}).then(r=>{if(r?.ok)caches.open(CACHE).then(c=>c.put(e.request,r.clone()));return r;}).catch(()=>caches.match(e.request).then(x=>x||caches.match('./index.html'))));return;}e.respondWith(caches.match(e.request).then(x=>x||fetch(e.request)));});
