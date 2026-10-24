// Service worker de BuZfinance (v8)
// Estrategia: primero red, y si no hay conexión, copia guardada en caché.
const CACHE_NAME = 'buzfinance-cache-v8';
const ARCHIVOS = ['./', './index.html', './manifest.json', './icon-192.png', './icon-512.png', './icon-512-maskable.png'];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((c) => c.addAll(ARCHIVOS)).catch(() => {}));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((nombres) => Promise.all(nombres.filter((n) => n !== CACHE_NAME).map((n) => caches.delete(n))))
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return;
  event.respondWith(
    fetch(event.request)
      .then((resp) => {
        const copia = resp.clone();
        caches.open(CACHE_NAME).then((c) => c.put(event.request, copia));
        return resp;
      })
      .catch(() => caches.match(event.request).then((r) => r || caches.match('./index.html')))
  );
});
