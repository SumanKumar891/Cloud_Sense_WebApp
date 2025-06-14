'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "d50e05bec47a1ca531ede214c9f03ffd",
"assets/AssetManifest.bin.json": "2119829ff09f2997ad37c72fbbdb52aa",
"assets/AssetManifest.json": "5e0e9d64cb78f82ad29e207fc0ad1fa3",
"assets/assets/applogo.jpg": "2e94775337b76c86ce1e0f9be0f894ae",
"assets/assets/background.jpg": "de4a32535578e611355ce4785f9657cf",
"assets/assets/buffalo.jpg": "edc76cee93b63f19d80b732404cbbce4",
"assets/assets/buffalo_.jpg": "0f21746395163610782b4c3f7a63471a",
"assets/assets/Chloritron.PNG": "322a9958ba5b556829e4c521e0cea421",
"assets/assets/Chloritronn.png": "63cf58bcf21ab3c4e1479daf44702b6d",
"assets/assets/cow.jpg": "2855c4322af63bf7646cb1221d4b5bd8",
"assets/assets/fonts/DMSerifText-Italic.ttf": "48d9b180aa132af0fe0d8ad1d5f8184d",
"assets/assets/fonts/DMSerifText-Regular.ttf": "26a61f86766bef242af31d725837a52a",
"assets/assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf": "31d95e96058490552ea28f732456d002",
"assets/assets/fonts/OpenSans-VariableFont_wdth,wght.ttf": "78609089d3dad36318ae0190321e6f3e",
"assets/assets/login.png": "a40869c6e3817c633af08c604dd31f86",
"assets/assets/maskable-icon512.png": "aa588f8a64c64484066fc7ddac946008",
"assets/assets/signup3.png": "ef4aa80af14539ea5a9abdc416f391ff",
"assets/assets/soil.jpg": "72ee5870b77de1c5fba3641e06807e1b",
"assets/assets/sun.jpg": "256e2b3d469326c72195f71c9077354e",
"assets/assets/tree.jpg": "474a61bd17c3381840a5684d707486f3",
"assets/assets/water_quality.jpg": "b4bf7dfbb24eb7e8caa713f0090c9267",
"assets/assets/weather.png": "14aab14d4fe80ab2673eaca1d1fd47aa",
"assets/FontManifest.json": "179513f8cdcc671da1d499dcbaaf2491",
"assets/fonts/DMSerifText-Italic.ttf": "48d9b180aa132af0fe0d8ad1d5f8184d",
"assets/fonts/DMSerifText-Regular.ttf": "26a61f86766bef242af31d725837a52a",
"assets/fonts/MaterialIcons-Regular.otf": "3c6a2275f3dfcc8e93b14db3fa92fe0f",
"assets/fonts/OpenSans-Italic-VariableFont_wdth,wght.ttf": "31d95e96058490552ea28f732456d002",
"assets/fonts/OpenSans-VariableFont_wdth,wght.ttf": "78609089d3dad36318ae0190321e6f3e",
"assets/NOTICES": "d080a53d0d62e64345597a7fdc763758",
"assets/packages/amplify_authenticator/assets/social-buttons/google.png": "a1e1d65465c69a65f8d01226ff5237ec",
"assets/packages/amplify_authenticator/assets/social-buttons/SocialIcons.ttf": "1566e823935d5fe33901f5a074480a20",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js": "7a393a8527b598eaf22d085f9aeb7915",
"assets/packages/amplify_auth_cognito_dart/lib/src/workers/workers.min.js.map": "3f8631d527c96ecfbe43cb67b16662c0",
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
"favicon.png": "352a05256273593e3e2b5d173d54cf60",
"firebase-messaging-sw.js": "17c44fff535ffea2671fce491d6dd458",
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
"flutter_bootstrap.js": "dda8aa8e8851bf0c5f530a32c041689b",
"icons/Icon-192.png": "90a948ad88bf1c17a5a40ed40bf4905a",
"icons/Icon-512.png": "76feaf63bcbf28ae35c368fa70d14ce7",
"icons/Icon-maskable-192.png": "90a948ad88bf1c17a5a40ed40bf4905a",
"icons/Icon-maskable-512.png": "76feaf63bcbf28ae35c368fa70d14ce7",
"index.html": "143aa858d65e77b68c923ab68f59d2bb",
"/": "143aa858d65e77b68c923ab68f59d2bb",
"main.dart.js": "8079bfc4476f2d856c35bf3e698ff208",
"manifest.json": "a44270f13c2af2a1352947ed9bba8842",
"maskable": "d41d8cd98f00b204e9800998ecf8427e",
"mobile-app.png": "c2b1747bda9c67c734ff806e5bf0e684",
"smartphone.png": "07c28484887d1e8f958e7975763a2d2b",
"vercel.json": "cec8404a2bcf91c9a170c9398e0aa3d2",
"version.json": "269bb23c86f1684c15105a6aa54a39da"};
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
