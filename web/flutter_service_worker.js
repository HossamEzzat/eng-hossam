// Kill any lingering Flutter PWA service worker from older deploys.
self.addEventListener('install', function (event) {
  self.skipWaiting();
});

self.addEventListener('activate', function (event) {
  event.waitUntil((async function () {
    try {
      var keys = await caches.keys();
      await Promise.all(keys.map(function (k) { return caches.delete(k); }));
    } catch (e) {}
    try {
      await self.registration.unregister();
    } catch (e) {}
    try {
      var clients = await self.clients.matchAll({ type: 'window' });
      clients.forEach(function (client) {
        if (client.url && 'navigate' in client) {
          client.navigate(client.url);
        }
      });
    } catch (e) {}
  })());
});
