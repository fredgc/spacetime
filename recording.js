// This javascript code implements recording a drawing.

function check_recording_keys(event, key) {
  if( event.keyCode == 191 ) { // slash key.
    console.log("Page down key hit.");
    recording.next_page();
  }

  if( key == '1' ) {            // DEBUG ONLY.  print out
    if( menu_hover_allowed ) {
      recording.add( create("hover_out_all", "#menu"));
    }
    menu_hover_allowed = ! menu_hover_allowed;
    console.log("key 1: allow hover is :" + menu_hover_allowed);
    recording.pager.display();
  }
  if( key == '2' ) {            // DEBUG ONLY.  print out
    console.log("key 2");
  }

  // if( key == '1' ) {            // DEBUG ONLY.  print out
  //   var stack = undo_stack.debug();
  //   console.log("Undo Stack. count="+stack.count);
  //   for( var item = stack.head; item; item = item.prev) {
  //     console.log("  "+item.time + ") "+ item.action.type );
  //   }
  // }
  // if( key == '2' ) {            // DEBUG ONLY.  print out
  //   console.log("List of items:");
  //   for(var item=scene.drawables.head; item; item = item.next_ns) {
  //     var props = " ";
  //     for(var i=0; i < properties.list.length; i++) {
  //       var name = properties.list[i].name;
  //       props += name +"="+ item[name] + ", ";
  //     }
  //     console.log( item.name + ": "+ item.type
  //         +" (" + item.coords.x+", "+item.coords.t+")" + props);
  //   }
  // }

}

action_table.recorder = function() {
  $('.playback').hide();
  $('.recording').show();
  if( playback ) {
    playback.stop_and_delete();
  }
  windowResize();
}

action_table.recorder2 = function() {
  $('.playback').show();
  $('.recording').hide();
  if( playback ) {
    playback.stop_and_delete();
  }
  windowResize();
  var filename = requestFilename();
  console.log("Planning to record actions for '"+filename + "'");
  if( filename ) {
    jQuery.ajax({
      url: "lessons/"+ filename + '.rec',
      dataType: 'html',
      success: function(data) {
        recording = new Recording2(filename, data);
      },
      fail: function(jqXHR, textStatus, errorThrown) {
        console.log("Could not load "+file+": "+errorThrown);
      }
    });
  }
}

action_table.start_recording = function() {
  if( recording ) {
    console.log('stop recording.');
    $('#start_recording').html("Start Rec");
    recording.stop();
  } else {
    var filename = requestFilename();
    console.log("You picked file '"+filename + "'");
    if( filename ) {
      console.log('start recording.');
      $('#start_recording').html("Stop Rec");
      recording = new Recording(filename);
    }
  }
}

function requestFilename() {
  function pad(x) {
    if( x < 10 ) {
      return "0"+x;
    } else {
      return  ""+x;
    }
  }
  var now = new Date();
  var yr = now.getFullYear();
  var mon = pad(now.getMonth()+1);
  var day = pad(now.getDate());
  var hr = pad(now.getHours());
  var min = pad(now.getMinutes());
  var filename = "lesson" + "-" + yr + mon + day + "-" + hr + ":" + min ;
  var match = window.location.hash.match(/#(.+)/);
  if( match ) {
    filename = match[1];
  }
  return prompt("Enter Filename:", filename);
}

function Recording(filename) {
  this.add = function(event) {
    var t = (+new Date() - this.start); // miliseconds.
    if( this.data.length > 0 ) {
      var prev = this.data[this.data.length-1];
      var dt = 100; // Skip minor changes every 100 ms. = 1/10 second.
      if( prev && event.maybe_skip && (t < prev.t + dt)
          && event.maybe_skip(prev.event) ) {
        return;
      }
    }
    this.data.push( { t: t, event: event });
  }
  this.next_page = function() {
    var t = (+new Date() - this.start); // miliseconds.
    recording.pager.add_time(t);
  }
  this.stop = function() {
    console.log("stopping: '"+this.filename+"'");
    this.add(create("playback", "stop"));
    var end = +new Date();
    this.duration = (end - this.start) * 0.001;
    console.log("Duration is "+this.duration);
    try {
      var xmlHttp = null;
      xmlHttp = new XMLHttpRequest();
      // xmlHttp.open( "GET", "http://127.0.0.1:8042/stop", false );
      var url = document.location.origin + "/recorder/stop";
      console.log("Stop recording url: "+url);
      xmlHttp.open( "GET", url, false );
      xmlHttp.send( null );
      console.log("stop response:" + xmlHttp.responseText );
    } catch(e) {
      console.log("stopRecording error:" + e );
    }
    recording = false;
    console.log("Saving recording before post.");
    clean_serialize();
    var data = my_stringify(this);
    clean_serialize();
    var url = "/recording/"+this.filename+".rec";
    console.log("Posting url:"+url);
    var request = $.ajax({
      url: url,
      type: "post",
      data: data
    });
    request.done(function(response, textStatus, jqXHR) {
      // console.log("Request done: "+response);
      // console.log("Requested file: "+filename);
      // console.log("status: "+textStatus);
      action_table.do_lesson(filename);
    });
    request.fail(function(jqXHR, textStatus, errorThrown) {
      alert("Recording actions failed:"+errorThrown);
      console.log("Request failed: "+errorThrown);
      console.log("Requested file: "+filename);
      console.log("status: "+textStatus);
    });
  }

  this.filename = filename;
  this.start = +new Date();
  set_new_scene();
  this.pager = create("pager", filename);
  this.range = { min_x: -5, max_x: 5, min_t: -2, max_t: 8};
  this.pager.advance_to(0);
  this.pager.display();
  this.data = [];
  this.add(create("playback", "start"));
  if( $("#view_subtitles").prop('checked') ) {
    window.open("lessons/" + filename + ".html", "subtitles");
  }

  try {
    var xmlHttp = null;
    xmlHttp = new XMLHttpRequest();
    // xmlHttp.open( "GET", "http://127.0.0.1:8042/start", false );
    var url = document.location.origin + "/recorder/start/"+this.filename;
    console.log("Start recording url: "+url);
    xmlHttp.open( "GET", url, false );
    xmlHttp.send( null );
    console.log("start response:" + xmlHttp.responseText );
  } catch(e) {
  }
}

function Recording2(filename, data_json) {
  this.add = function(event) {
    if( ! start_time ) return;
    var t = (+new Date() - start_time); // miliseconds.
    if( this.data.length > 0 ) {
      var prev = this.data[this.data.length-1];
      var dt = 100; // Skip minor changes every 100 ms. = 1/10 second.
      if( prev && event.maybe_skip && (t < prev.t + dt)
          && event.maybe_skip(prev.event) ) {
        return;
      }
    }
    this.data.push( { t: t, event: event });
  }

  this.next_page = function() {
    if( ! start_time ) return;
    var t = (+new Date() - start_time); // miliseconds.
    recording.pager.add_time(t);
  }

  this.stop = function() {
    console.log("stopping: '"+this.filename+"'");
    this.add(create("playback", "stop"));
    var end = +new Date();
    this.duration = (end - start_time) * 0.001;
    console.log("Duration is "+this.duration);
    recording = false;
    console.log("Saving recording before post.");
    clean_serialize();
    var data = my_stringify(this);
    clean_serialize();
    var url = "/recording/"+this.filename+".rec";
    console.log("Posting url:"+url);
    var request = $.ajax({
      url: url,
      type: "post",
      data: data
    });
    request.done(function(response, textStatus, jqXHR) {
      // console.log("Request done: "+response);
      // console.log("Requested file: "+filename);
      // console.log("status: "+textStatus);
      action_table.do_lesson(filename);
    });
    request.fail(function(jqXHR, textStatus, errorThrown) {
      alert("Recording actions failed:"+errorThrown);
      console.log("Request failed: "+errorThrown);
      console.log("Requested file: "+filename);
      console.log("status: "+textStatus);
    });

  }

  action_table.debug_page = function() {
    console.log("@@@ debug page time = " + (1000*current_time));
  }

  this.filename = filename;
  this.start = +new Date();
  var start_time = null;
  var current_time = 0;

  clean_serialize();
  this.old_data_ns = my_parse(data_json);
  clean_serialize();
  this.pager = this.old_data_ns.pager;
  if( ! this.pager ) this.pager = create("pager",filename);
  this.pager.filename = filename;
  this.pager.advance_to(0);
  this.pager.display();

  var audio = $('#audio');
  audio.bind("play", play_actions);
  audio.bind("pause", pause_actions);
  audio.bind("ended", ended_actions);
  audio.bind("timeupdate", play_time_update);
  audio.bind("seeked", play_time_update);
  var debug_sounds = "";       // Modified by test server.
  var sound_file =  debug_sounds + "lessons/"+filename+".mp3";
  audio.attr('src', sound_file);

  set_new_scene();
  this.data = [];
  this.add(create("playback", "start"));
  if( $("#view_subtitles").prop('checked') ) {
    window.open("lessons/" + filename + ".html", "subtitles");
  }

  function play_actions() {
    start_time = (+new Date());
  }

  function pause_actions() {
    console.log("That probably won't work.");
  }

  function ended_actions() {
    console.log("Done with recording.");
    recording.stop();
    audio.unbind("play", play_actions);
    audio.unbind("pause", pause_actions);
    audio.unbind("ended", ended_actions);
    audio.unbind("timeupdate", play_time_update);
    audio.unbind("seeked", play_time_update);
  }

  // This is called by the audio playback.  I use it to adjust
  // the start time -- this is important if we seek forward or backward.
  function play_time_update(event) {
    var new_time = $("#audio").prop("currentTime"); // seconds.
    total_time = $("#audio").prop("totalTime"); // seconds.
    if( new_time > total_time ) new_time = total_time;
    if( new_time < current_time ) {
      rewind(new_time);
    }
    current_time = new_time;    // seconds.
    start_time = (+new Date())  - current_time*1000; // miliseconds.
    recording.pager.advance_to(1000*current_time);
  }

  function rewind(t) {
    // console.log("REWIND DOESN'T WORK:"+t+", old="+current_time);
  }
}
