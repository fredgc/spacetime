/******************************************************************************/
// This is the Google Drive file load/save functionality.
// The URL has to be spacetime.gchouse.org for this client id.
var CLIENT_ID = '1008051861201.apps.googleusercontent.com';
var SCOPES = ['https://www.googleapis.com/auth/drive',
              'email', 'profile'];
var APP_ID = "1008051861201";   // Drive SDK App ID.
var browserKey = "AIzaSyDuUEjGwmbFLd2rWCWpfzTqAf5GTTtu3G4"; // API key for browser.
var authorized = false;
var retryWhenAuthorized = null; // Callback to run after authorized.
var current_file = null;
var action_table = {};      // Lookup table "action name" -> "action function".
var file_share = null;
var share_requested = false;
var oauthToken = null;

// google.setOnLoadCallback(enableLoad);

function enableLoad() {
  document.getElementById('load').disabled = false;
}

/**
 * Called when the client library is loaded to start the auth flow.
 */
function handleClientLoad() {
  window.setTimeout(checkAuth, 1);
}

/**
 * Check if the current user has authorized the application.
 */
function checkAuth() {
  gapi.auth.authorize(
      {'client_id': CLIENT_ID, 'scope': SCOPES, 'immediate': true},
      handleAuthResult);
  gapi.load('drive-share', share_init);
  gapi.load('picker', {'callback': enableLoad});
}

function share_init() {
  file_share = new gapi.drive.share.ShareClient(APP_ID);
}

/**
 * Called when authorization server replies.

 * @param {Object} authResult Authorization result.
 */
function handleAuthResult(authResult) {
  if (authResult && !authResult.error) {
    authorized = true;
    oauthToken = authResult.access_token;
    if( retryWhenAuthorized != null ) {
      retryWhenAuthorized();
      retryWhenAuthorized = null;
    }
  } else {
    authorized = false;
    retryWhenAuthorized = null;
  }
}

function getAuthorization(callback) {
  retryWhenAuthorized = callback;
  gapi.auth.authorize(
    {'client_id': CLIENT_ID, 'scope': SCOPES, 'immediate': false},
    handleAuthResult);
}

function start_load(file_id) {
  // Initialize all data to reasoable values with newdoc, in case the
  // load fails.
  action_table.newdoc();
  current_file = { id: file_id };
  retryWhenAuthorized = action_table.reload;
}

action_table.load = function() {
  if( ! authorized ) {
    return getAuthorization(action_table.load);
  }

  var view = new google.picker.View(google.picker.ViewId.DOCS);
  view.setMimeTypes("application/spacetime,text/plain");

  var picker = new google.picker.PickerBuilder().
      //addView(google.picker.ViewId.DOCS).
      addView(view).
      setOAuthToken(oauthToken).
      setDeveloperKey(browserKey).
      setCallback(pickerCallback).
      // .setAppId(YOUR_APP_ID)
      // .setOAuthToken(AUTH_TOKEN)
      build();
  picker.setVisible(true);
}

function pickerCallback(data) { // Called after user picked a file to load.
  if (data[google.picker.Response.ACTION] == google.picker.Action.PICKED) {
    current_file = data.docs[0];
    action_table.reload();
  }
}

// Called when user clicks "reload" or picks a file.
action_table.reload = function() {
  if( ! authorized ) {
    return getAuthorization(action_table.reload);
  }
  if( current_file == null ) {
    alert("No current file.  Cannot reload.");
    return;
  }
  var path = '/drive/v2/files/' + current_file.id;
  var request = gapi.client.request({
    'path': path,
    'method': 'GET'
  });
  $("*").addClass("busy_cursor");
  request.execute(afterReload);
}

function afterReload(file, response) {
  $(".busy_cursor").removeClass("busy_cursor");
  if( ! file ) {
    alert("Error Loading file: \nEmpty response from server.");
    return;
  }
  if( file.error ) {
    alert("Error Loading ("+file.error.code+")\n"
        + file.error.message);
    console.log('Error code: ' + file.error.code);
    console.log('Error message: ' + file.error.message);
    return;
  }

  if( ! file.id ) {
    alert("Corrupted response from server.\nNo File ID.");
    return;
  }
  current_file = file;
  window.location.hash = "#file=" + current_file.id;
  document.getElementById('filename').value = file.title;
  if( ! file.downloadUrl ) {
    alert("Corrupted response from server:\nNo download URL.");
    return;
  }

  var myToken = gapi.auth.getToken();
  var myXHR   = new XMLHttpRequest();
  myXHR.open('GET', file.downloadUrl, true );
  myXHR.setRequestHeader('Authorization', 'Bearer ' + myToken.access_token );
  myXHR.onreadystatechange = function( theProgressEvent ) {
    // console.log("myXHR ready state change: " + myXHR.readyState);
    if (myXHR.readyState == 4) {
      //          1=connection ok, 2=Request received, 3=running, 4=terminated
      if ( myXHR.status == 200 ) {
        //              200=OK
        // console.log( myXHR.response );
        select_item(null);
        clean_serialize();
        set_new_scene(my_parse(myXHR.response));
        clean_serialize();
      } else {
        console.log("ERROR.  XHR status: " + myXHR.status);
      }
    }
  }
  myXHR.send();
}

action_table.save = function() {
  if( ! authorized ) {
    return getAuthorization(action_table.save);
  }
  const boundary = '-------314159265358979323846';
  const delimiter = "\r\n--" + boundary + "\r\n";
  const close_delim = "\r\n--" + boundary + "--";

  var content_type = 'application/spacetime';
  var metadata = {
    'title': document.getElementById('filename').value,
    'mimeType': content_type
  };
  var path =  '/upload/drive/v2/files';
  var params = {'uploadType': 'multipart'};
  var method = 'POST';
  if( current_file != null ) {
    metadata.id = current_file.id;
    path += '/' + current_file.id;
    params.fileId = current_file.id;
    method = 'PUT';
  }
  clean_serialize();
  var base64Data = btoa(my_stringify(scene));
  clean_serialize();
  var multipartRequestBody = ( delimiter +
                               'Content-Type: application/json\r\n\r\n' +
                               JSON.stringify(metadata) +
                               delimiter +
                               'Content-Type: ' + content_type + '\r\n' +
                               'Content-Transfer-Encoding: base64\r\n' +
                               '\r\n' +
                               base64Data +
                               close_delim);

  var request = gapi.client.request({
    'path': path,
    'method': method,
    'params': params,
    'headers': {
      'Content-Type': 'multipart/mixed; boundary="' + boundary + '"'
    },
    'body': multipartRequestBody});
  request.execute(afterFileSaved);
}

function afterFileSaved(file, response) {
  if( ! file ) {
    alert("Error Saving file: \nEmpty response from server.");
    return;
  }
  if( file.error ) {
    alert("Error Saving File ("+file.error.code+")\n"
        + file.error.message);
    console.log('Error code: ' + file.error.code);
    console.log('Error message: ' + file.error.message);
    return;
  }
  current_file = file;
  window.location.hash = "#file=" + current_file.id;
  if( share_requested ) {
    open_share_dialog();
  }
}

action_table.newdoc = function() {
  document.getElementById('filename').value = "New Drawing";
  current_file = null;
  window.location.hash = "";
  select_item(null);
  scene = create("scene");          // Add undo, or warn if file exists?
  windowResize();
  set_new_scene(scene);
}

action_table.copy_file = function() {
  current_file = null;
  action_table.save();
}

action_table.share_file = function() {
  if( ! authorized ) {
    return getAuthorization(action_table.share_file);
  }
  share_requested = true;
  action_table.save();
}

function open_share_dialog() {
  share_requested = false;
  if( ! file_share) {
    share_init();
  }
  file_share.setItemIds(current_file.id);
  file_share.showSettingsDialog();
}


/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

var type2constructor = {};

// Register a constructor by name.  All json serializable objects must register.
function register(type, constructor) {
  if( type2constructor[type] ) {
    console.log("---- XXX---- XXX---- XXX---- XXX---- XXX---- XXX----");
    console.log("---- XXX --- trying to register "+type +" twice.");
    console.log("             one: "+type2constructor[type]  );
    console.log("             two: "+constructor  );
    console.log("---- XXX---- XXX---- XXX---- XXX---- XXX---- XXX----");
  }
  type2constructor[type] = constructor;
}

// Create a registered type by type name.
function create(type, arg1, arg2, arg3, arg4) {
  var value = eval(type2constructor[type]);
  value.type = type;
  return value;
}

// Unpack registered type from a json object.
function unpack(source) {
  var arg1 = "";
  var arg2 = "";
  var arg3 = "";
  var arg4 = "";
  var value = eval(type2constructor[source.type]);
  if( !value ) {
    console.log("Error unpacking "+source.type);
    return value;
  }
  if( value.unpack ) {
    return value.unpack(source);
  }
  for( var key in source) {
    value[key] = source[key];
  }
  return value;
}

var serialized_objects = [];    // Serialized objects in current stream.
function clean_serialize() {
  for(var i=0; i < serialized_objects.length; i++) {
    if( !serialized_objects[i] ) {
      // console.log("ERROR: missing serialized object "+i);
    } else {
      delete serialized_objects[i].serialized_index;
    }
  }
  serialized_objects = [];
}

function my_stringify(obj) {    // Call clean_serialize before and after.
  var data = JSON.stringify(obj, myreplacer, ' ');
  return data;
}

function my_parse(obj) {        // Call clean_serialize before and after.
  var data = JSON.parse(obj, myreviver);
  return data;
}

function myreplacer(key, value) {
  if( key.match(/_ns/)) {        // No Save.
    return undefined;
  }
  if( value && !isNaN(value.serialized_index)) {
    return { serialized_index: value.serialized_index };
  }
  if( value && value.type ) {
    value.serialized_index = serialized_objects.length;
    serialized_objects.push(value);
  }
  if( value && value.pack ) {
    var new_value = value.pack();
    new_value.serialized_index = value.serialized_index;
    return new_value;
  } else {
    return value;
  }
}

function myreviver(key, value) {
  if( value && !isNaN(value.serialized_index) && !value.type )  {
    return serialized_objects[value.serialized_index];
  }
  if( value && value.type ) {
    v2 = unpack(value);         // Create a new object, with the correct type.
    if( !isNaN(value.serialized_index) ) {
      v2.serialized_index = value.serialized_index;
      serialized_objects[v2.serialized_index] = v2;
    }
    return v2;
  }
  return value;
}

/******************************************************************************/
function LinkedList() {
  this.head = null;
  this.tail = null;
}
LinkedList.prototype.add = function(node) {
  if(this.head == null ) {
    this.head = node;
  } else {
    this.tail.next_ns = node;
  }
  node.next_ns = null;
  node.prev_ns = this.tail;
  this.tail = node;
}
LinkedList.prototype.remove = function(node) {
  if( ! node ) return;
  if( this.head == node ) {
    this.head = node.next_ns;
  } else {
    node.prev_ns.next_ns = node.next_ns;
  }
  if( this.tail == node ) {
    this.tail = node.prev_ns;
  } else {
    node.next_ns.prev_ns = node.prev_ns;
  }
}
LinkedList.prototype.pack = function() {
  var ret = {type: "list", list:[]};
  var node = this.head;
  while( node ) {
    ret.list.push(node);
    node = node.next_ns;
  }
  return ret;
}
LinkedList.prototype.unpack = function(source) {
  var value = create("list");
  for(var i=0; i < source.list.length; i++) {
    value.add( source.list[i]);
  }
  return value;
}
register("list", "new LinkedList()");


/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
