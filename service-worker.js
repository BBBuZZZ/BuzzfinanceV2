// Service worker de BuZfinance: cachea la app la primera vez que se abre online,
// y a partir de ahí la sirve desde caché aunque no haya conexión.
const CACHE_NAME = 'buzfinance-cache-v1';
const ARCHIVOS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './icon-512-maskable.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ARCHIVOS)).catch(()=>{})
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((nombres) =>
      Promise.all(nombres.filter(n => n !== CACHE_NAME).map(n => caches.delete(n)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((respuestaCache) => {
      return respuestaCache || fetch(event.request).then((respuestaRed) => {
        // guarda una copia fresca en caché para la próxima vez, si es de nuestro propio origen
        if(event.request.url.startsWith(self.location.origin)){
          const copia = respuestaRed.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copia));
        }
        return respuestaRed;
      }).catch(() => respuestaCache);
    })
  );
});
