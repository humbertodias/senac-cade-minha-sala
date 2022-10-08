CACHE_NAME = "cache_v1.1";
URL_CACHE = [
  'index.html',
  '/',
  'favicon.ico',
  'salas.db',
  'https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons',
  'https://unpkg.com/quasar/dist/quasar.prod.css',

  'https://unpkg.com/vue@3/dist/vue.global.js',
  'https://unpkg.com/sql.js/dist/sql-wasm.js',
  'https://unpkg.com/quasar/dist/quasar.umd.prod.js',
];

self.addEventListener('install', (event) => {
  console.log("sw.js installed");


  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        cache.addAll(URL_CACHE);
      })
  );

});

self.addEventListener('activate', (event) => {

  event.waitUntil(
    caches.keys()
      .then((cache) => {
        Promise.all(
          cache.filter(item => {
            if (item != CACHE_NAME)
              return caches.delete(item);
          })
        );
      })
  );
  event.waitUntil(self.clients.claim());
});


self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request)
      .then(res => {
        if (res) {
          console.log("Already cached", res);
          return res;
        }
        return fetch(event.request, { "cache": "no-store" })
          .then(res => {
            console.log("Not cache", res);
            return res;
          }, err => {
            return err;
          })
      })
  );
});