'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "e36400edbc838fbe74ace4503be0b019",
"assets/AssetManifest.bin.json": "729af01b5cd29463cba582e9459c8e80",
"assets/AssetManifest.json": "f565bb245f21e5ed1b9388f7e905e853",
"assets/assets/backgroundd.jpg": "03c56935fdf2d8682da17b033e37c012",
"assets/assets/blue.jpg": "8072cb25190fd50b5670d651cfadeb6e",
"assets/assets/buildings.jpg": "9e2c9a6b6696b83a3310fb87602d12ad",
"assets/assets/Chloritron.PNG": "322a9958ba5b556829e4c521e0cea421",
"assets/assets/clouds.jpg": "221b2165c09f2e727b07a8c419600640",
"assets/assets/fonts/DMSerifText-Italic.ttf": "48d9b180aa132af0fe0d8ad1d5f8184d",
"assets/assets/fonts/DMSerifText-Regular.ttf": "26a61f86766bef242af31d725837a52a",
"assets/assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf": "31d95e96058490552ea28f732456d002",
"assets/assets/fonts/OpenSans-VariableFont_wdth,wght.ttf": "78609089d3dad36318ae0190321e6f3e",
"assets/assets/images/atmosphere.jpg": "ddb494d871b013227a642a0b28faab3d",
"assets/assets/images/AWaDH.jpg": "6478d0c83adb6b08838cd2d487bc7fc3",
"assets/assets/images/background.jpg": "74293090e6b9fbd4d6bbbffa5b5d225a",
"assets/assets/images/backgroundd.jpg": "03c56935fdf2d8682da17b033e37c012",
"assets/assets/images/blue.jpg": "8072cb25190fd50b5670d651cfadeb6e",
"assets/assets/images/buildings.jpg": "9e2c9a6b6696b83a3310fb87602d12ad",
"assets/assets/images/Chloritron.PNG": "322a9958ba5b556829e4c521e0cea421",
"assets/assets/images/cloud.gif": "e186139f660889e5a793f3546a6eee7a",
"assets/assets/images/clouds.jpg": "221b2165c09f2e727b07a8c419600640",
"assets/assets/images/home.jpg": "b80acda8254e9719a0f4a63dc7eed1bd",
"assets/assets/images/imageicon.jpg": "fd70ea6c3a6913effb9d61fb53ea88f3",
"assets/assets/images/leaves.jpg": "64cb742f70a91909db67ae84b1f40a85",
"assets/assets/images/loginImage.png": "ceacc775a12fd448637fa595e149c78b",
"assets/assets/images/Nature.jpg": "ec620499f96475619cba2e4258e2cdc3",
"assets/assets/images/pink.jpg": "1875f60e00f51345c9d424af3b12a638",
"assets/assets/images/purple.jpg": "8e2078f577a548be0d3abfa91d716cfa",
"assets/assets/images/sensor.jpg": "253adf881d1b24bf0c3c169e096bb345",
"assets/assets/images/sensors.jpg": "638e2638011c90e32e612d879f41f6ad",
"assets/assets/images/sensor_.avif": "b66244c0fc6a48f7901281aa96add290",
"assets/assets/images/sensor_.jpg": "f513e05b126cc914d0ba8c09de78be72",
"assets/assets/images/signup3.png": "ef4aa80af14539ea5a9abdc416f391ff",
"assets/assets/images/soil.jpg": "72ee5870b77de1c5fba3641e06807e1b",
"assets/assets/images/sun.jpg": "719fbe3ffbf0a49828982c48b156b4ce",
"assets/assets/images/sunn.jpg": "78761d26feda572137c41c4a063014ae",
"assets/assets/images/toronto.jpg": "49064d66e7f206938d9793bfd3b0cd8a",
"assets/assets/images/tower.jpg": "07b5a01dccce31eb87ef7a34ed54cd9a",
"assets/assets/images/tree.jpg": "474a61bd17c3381840a5684d707486f3",
"assets/assets/images/water.jpg": "9074bf635d2b04860f6719b31328e78d",
"assets/assets/images/weather.jpg": "52c8ce001a46c5f1d9ba1aa26c1b9277",
"assets/assets/images/weathericon.jpg": "32ad1b3d055e336bb837b1eabeb1f316",
"assets/assets/images/weatherr.jpg": "392959e1b8e013ffc18053f53308b46c",
"assets/assets/images/weatherrr.jpg": "f8be3ec10ddcee5eff9b4c4709bf2a95",
"assets/assets/images/weatherstation.jpg": "d2cb37f2f3eded1f59fef15541441393",
"assets/assets/images/weatherstation.webp": "6f7b8b8164e86e2df1010fb76253b323",
"assets/assets/images/weather_.jpg": "9c62cef4873c5f527a4c1559b78dba0f",
"assets/assets/images/yellow.jpg": "7215ef970dc4a3680887a08a76f03d82",
"assets/assets/leaves.jpg": "64cb742f70a91909db67ae84b1f40a85",
"assets/assets/loginImage.png": "ceacc775a12fd448637fa595e149c78b",
"assets/assets/Nature.jpg": "ec620499f96475619cba2e4258e2cdc3",
"assets/assets/sensors.jpg": "638e2638011c90e32e612d879f41f6ad",
"assets/assets/signup3.png": "ef4aa80af14539ea5a9abdc416f391ff",
"assets/assets/soil.jpg": "72ee5870b77de1c5fba3641e06807e1b",
"assets/assets/sunn.jpg": "78761d26feda572137c41c4a063014ae",
"assets/assets/tower.jpg": "07b5a01dccce31eb87ef7a34ed54cd9a",
"assets/assets/tree.jpg": "474a61bd17c3381840a5684d707486f3",
"assets/assets/weathericon.jpg": "32ad1b3d055e336bb837b1eabeb1f316",
"assets/assets/weatherr.jpg": "392959e1b8e013ffc18053f53308b46c",
"assets/assets/weatherstation.jpg": "d2cb37f2f3eded1f59fef15541441393",
"assets/assets/weather_.jpg": "9c62cef4873c5f527a4c1559b78dba0f",
"assets/FontManifest.json": "179513f8cdcc671da1d499dcbaaf2491",
"assets/fonts/MaterialIcons-Regular.otf": "0e90b54dfb6ceb3cc7f016094ef1d603",
"assets/NOTICES": "7c9a0053c21a0c2a52a28cd65be6ca15",
"assets/packages/amplify_authenticator/assets/social-buttons/google.png": "a1e1d65465c69a65f8d01226ff5237ec",
"assets/packages/amplify_authenticator/assets/social-buttons/SocialIcons.ttf": "1566e823935d5fe33901f5a074480a20",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js": "d439755124d125cf0a5ead2ea8993c20",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js.map": "ffbadfeea33908f78ebbf1da85e17dd8",
"assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js": "3dce3007b60184273c34857117a97551",
"assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js.map": "3ce9ff7bf3f1ff4fd8c105b33a06e4a1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "5fda3f1af7d6433d53b24083e2219fa0",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "87325e67bf77a9b483250e1fb1b54677",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "9fa2ffe90a40d062dd2343c7b84caf01",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f31737fb005cd3a3c6bd9355efd33061",
"flutter_bootstrap.js": "070e5e9deb059622a156ef37c5d3f423",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "cf347c9bdc2af8c27c79b4f3bfa3ad38",
"/": "cf347c9bdc2af8c27c79b4f3bfa3ad38",
"main.dart.js": "9df830e0ea3698ee0f5ff20b8a5db842",
"manifest.json": "1945d941ea0a66a4fc873921c259c902",
"version.json": "c99f477bf3954abaf222bbd37a2f300d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
