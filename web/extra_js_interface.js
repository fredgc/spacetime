// The function pointer fileSaveDART is specified in js_interface.dart.
// It saves game on window unload.
globalThis.fileSaveDART = function() {
  console.log("XXX --- fileSaveDART was not redirected.");
}

globalThis.unsavedDART = function() {
  return false;
}

globalThis.setCallbackFunction = function(f) {
  console.log("GREEN: setting gamesavedart in javascript.");
  globalThis.fileSaveDART = f;
}

globalThis.setUnsavedCallback = function(f) {
  console.log("GREEN: setting unsaved callback in javascript.");
  globalThis.unsavedDART = f;
}

window.addEventListener('beforeunload', function(e) {
  if (globalThis.unsavedDART()) {
    e.preventDefault();
    e.returnValue = '';
  }
});
console.log("End of extra_js_interface.");
