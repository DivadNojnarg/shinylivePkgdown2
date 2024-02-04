document.addEventListener("DOMContentLoaded", function() {
  var localhostNames = ["localhost", "127.0.0.1", "[::1]"];
  if (window.location.protocol !== "https:" && !localhostNames.includes(window.location.hostname)) {
    const errorMessage = "Shinylive uses a Service Worker, which requires either a connection to localhost, or a connection via https.";
    document.body.innerText = errorMessage;
    throw Error(errorMessage);
  }

  var serviceWorkerPath = "./shinylive-sw.js";
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register(serviceWorkerPath, { type: "module" }).then(() => console.log("Service Worker registered")).catch(() => console.log("Service Worker registration failed"));
    navigator.serviceWorker.ready.then(() => {
      if (!navigator.serviceWorker.controller) {
        window.location.reload();
      }
    });
  }
})
