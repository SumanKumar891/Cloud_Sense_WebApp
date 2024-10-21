'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "032b79bbeced9477ffcb163e96a0f899",
"assets/AssetManifest.bin.json": "81f0335e382967d4925249e4867945a1",
"assets/AssetManifest.json": "c562006e1d4a649da23dc9582db8a630",
"assets/assets/backgroundd.jpg": "03c56935fdf2d8682da17b033e37c012",
"assets/assets/Chloritron.PNG": "322a9958ba5b556829e4c521e0cea421",
"assets/assets/Chloritronn.png": "63cf58bcf21ab3c4e1479daf44702b6d",
"assets/assets/fonts/DMSerifText-Italic.ttf": "48d9b180aa132af0fe0d8ad1d5f8184d",
"assets/assets/fonts/DMSerifText-Regular.ttf": "26a61f86766bef242af31d725837a52a",
"assets/assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf": "31d95e96058490552ea28f732456d002",
"assets/assets/fonts/OpenSans-VariableFont_wdth,wght.ttf": "78609089d3dad36318ae0190321e6f3e",
"assets/assets/loginImage.png": "ceacc775a12fd448637fa595e149c78b",
"assets/assets/signup3.png": "ef4aa80af14539ea5a9abdc416f391ff",
"assets/assets/soil.jpg": "72ee5870b77de1c5fba3641e06807e1b",
"assets/assets/sunn.jpg": "78761d26feda572137c41c4a063014ae",
"assets/assets/tree.jpg": "474a61bd17c3381840a5684d707486f3",
"assets/assets/water_quality.jpg": "b4bf7dfbb24eb7e8caa713f0090c9267",
"assets/assets/water_quality.png": "182785373df3a5926ea7f0e73dbd24f1",
"assets/assets/weatherr.jpg": "392959e1b8e013ffc18053f53308b46c",
"assets/FontManifest.json": "179513f8cdcc671da1d499dcbaaf2491",
"assets/fonts/DMSerifText-Italic.ttf": "48d9b180aa132af0fe0d8ad1d5f8184d",
"assets/fonts/DMSerifText-Regular.ttf": "26a61f86766bef242af31d725837a52a",
"assets/fonts/MaterialIcons-Regular.otf": "fed4f87facf1d6f0806309b824474355",
"assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf": "31d95e96058490552ea28f732456d002",
"assets/fonts/OpenSans-VariableFont_wdth,wght.ttf": "78609089d3dad36318ae0190321e6f3e",
"assets/NOTICES": "d342b12b612c63eedb7db7262c824ad8",
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
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_assets/AssetManifest.bin": "a4cfe0625361a42a9af93d1425d4e871",
"flutter_assets/AssetManifest.bin.json": "158b1c95491ca94fcd0bce1c6bdca5cb",
"flutter_assets/AssetManifest.json": "4f1e2a600dd0b4c88663a1187edf66d3",
"flutter_assets/assets/backgroundd.jpg": "03c56935fdf2d8682da17b033e37c012",
"flutter_assets/assets/blue.jpg": "8072cb25190fd50b5670d651cfadeb6e",
"flutter_assets/assets/buildings.jpg": "9e2c9a6b6696b83a3310fb87602d12ad",
"flutter_assets/assets/Chloritron.PNG": "322a9958ba5b556829e4c521e0cea421",
"flutter_assets/assets/clouds.jpg": "221b2165c09f2e727b07a8c419600640",
"flutter_assets/assets/fonts/DMSerifText-Italic.ttf": "48d9b180aa132af0fe0d8ad1d5f8184d",
"flutter_assets/assets/fonts/DMSerifText-Regular.ttf": "26a61f86766bef242af31d725837a52a",
"flutter_assets/assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf": "31d95e96058490552ea28f732456d002",
"flutter_assets/assets/fonts/OpenSans-VariableFont_wdth,wght.ttf": "78609089d3dad36318ae0190321e6f3e",
"flutter_assets/assets/leaves.jpg": "64cb742f70a91909db67ae84b1f40a85",
"flutter_assets/assets/loginImage.png": "ceacc775a12fd448637fa595e149c78b",
"flutter_assets/assets/Nature.jpg": "ec620499f96475619cba2e4258e2cdc3",
"flutter_assets/assets/sensors.jpg": "638e2638011c90e32e612d879f41f6ad",
"flutter_assets/assets/signup3.png": "ef4aa80af14539ea5a9abdc416f391ff",
"flutter_assets/assets/soil.jpg": "72ee5870b77de1c5fba3641e06807e1b",
"flutter_assets/assets/sunn.jpg": "78761d26feda572137c41c4a063014ae",
"flutter_assets/assets/tower.jpg": "07b5a01dccce31eb87ef7a34ed54cd9a",
"flutter_assets/assets/tree.jpg": "474a61bd17c3381840a5684d707486f3",
"flutter_assets/assets/weathericon.jpg": "32ad1b3d055e336bb837b1eabeb1f316",
"flutter_assets/assets/weatherr.jpg": "392959e1b8e013ffc18053f53308b46c",
"flutter_assets/assets/weatherstation.jpg": "d2cb37f2f3eded1f59fef15541441393",
"flutter_assets/assets/weather_.jpg": "9c62cef4873c5f527a4c1559b78dba0f",
"flutter_assets/FontManifest.json": "179513f8cdcc671da1d499dcbaaf2491",
"flutter_assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"flutter_assets/NOTICES": "7c9a0053c21a0c2a52a28cd65be6ca15",
"flutter_assets/packages/amplify_authenticator/assets/social-buttons/google.png": "a1e1d65465c69a65f8d01226ff5237ec",
"flutter_assets/packages/amplify_authenticator/assets/social-buttons/SocialIcons.ttf": "1566e823935d5fe33901f5a074480a20",
"flutter_assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js": "cd31f8bd84a5ccef13328435b7939797",
"flutter_assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js.map": "ffbadfeea33908f78ebbf1da85e17dd8",
"flutter_assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js": "abe35548f5f77ce82b98887a14f296b2",
"flutter_assets/packages/amplify_secure_storage_dart/lib/src/worker/workers.min.js.map": "3ce9ff7bf3f1ff4fd8c105b33a06e4a1",
"flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"flutter_assets/packages/fluttertoast/assets/toastify.css": "910ddaaf9712a0b0392cf7975a3b7fb5",
"flutter_assets/packages/fluttertoast/assets/toastify.js": "18cfdd77033aa55d215e8a78c090ba89",
"flutter_assets/packages/flutter_map/lib/assets/flutter_map_logo.png": "208d63cc917af9713fc9572bd5c09362",
"flutter_assets/packages/wakelock_plus/assets/no_sleep.js": "9c3aa3cd0b217305aa860decab3d9f42",
"flutter_assets/shaders/ink_sparkle.frag": "9bb2aaa0f9a9213b623947fa682efa76",
"flutter_bootstrap.js": "57d8c9e3ad62b843ef9baa7119caa642",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "ac3d76aa9e36fe5b3bb2600f7c12437d",
"/": "ac3d76aa9e36fe5b3bb2600f7c12437d",
"main.dart.js": "5701105a4b8bd0514c29143da5f914ab",
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
